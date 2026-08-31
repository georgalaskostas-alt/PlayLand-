import SwiftUI
import UIKit
import CoreImage

/// Displays one of the 30 exact line-art panels supplied for PlayLand.
/// The source stays as the compact 1-bit sprite sheet. Each requested panel is
/// cropped and rendered through Core Image into a normal RGB bitmap, then cached.
/// This avoids the previous broken raw-byte interpretation of the PNG provider.
struct ArtStudioExactPageView: View {
    let index: Int

    var body: some View {
        Image(uiImage: ArtStudioExactSheet.panel(at: index))
            .resizable()
            .renderingMode(.original)
            .interpolation(.high)
            .scaledToFit()
            .aspectRatio(15.0 / 11.0, contentMode: .fit)
            .background(Color.white)
            .preferredColorScheme(.light)
    }
}

private enum ArtStudioExactSheet {
    private static let columns = 6
    private static let rows = 5
    private static let cache = NSCache<NSNumber, UIImage>()
    private static let ciContext = CIContext(options: [
        .cacheIntermediates: true,
        .useSoftwareRenderer: false
    ])

    static func panel(at rawIndex: Int) -> UIImage {
        let index = min(max(rawIndex, 0), columns * rows - 1)
        let key = NSNumber(value: index)
        if let cached = cache.object(forKey: key) { return cached }

        guard let source = UIImage(named: "artstudio_30_sheet")?.withRenderingMode(.alwaysOriginal),
              let cgImage = source.cgImage else { return fallback }

        let panelWidth = cgImage.width / columns
        let panelHeight = cgImage.height / rows
        let column = index % columns
        let row = index / columns
        let cropRect = CGRect(
            x: column * panelWidth,
            y: row * panelHeight,
            width: panelWidth,
            height: panelHeight
        )

        guard let cropped = cgImage.cropping(to: cropRect) else { return fallback }

        // IMPORTANT: dataProvider.data for a PNG is not a safe way to interpret
        // the final bitmap pixel-by-pixel. Let Core Image decode/render the
        // monochrome crop into a standard RGB buffer instead.
        let ciImage = CIImage(cgImage: cropped)
        let extent = CGRect(x: 0, y: 0, width: cropped.width, height: cropped.height)
        let translated = ciImage.transformed(by: CGAffineTransform(
            translationX: -ciImage.extent.origin.x,
            y: -ciImage.extent.origin.y
        ))

        let image: UIImage
        if let rendered = ciContext.createCGImage(
            translated,
            from: extent,
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        ) {
            image = UIImage(cgImage: rendered, scale: 1, orientation: .up)
                .withRenderingMode(.alwaysOriginal)
        } else {
            image = fallback
        }

        cache.setObject(image, forKey: key)
        return image
    }

    private static var fallback: UIImage {
        let size = CGSize(width: 240, height: 176)
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { renderer in
            renderer.cgContext.setFillColor(UIColor.white.cgColor)
            renderer.cgContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
