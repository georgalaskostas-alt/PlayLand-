import SwiftUI
import UIKit

/// Displays one of the 30 exact line-art panels supplied for PlayLand.
/// The source asset is a 1-bit monochrome sprite sheet. Asset-catalog decoding
/// can expose it with mask-like semantics, which previously produced solid-black
/// rectangles. We rebuild the bitmap explicitly as a grayscale image (not a mask),
/// then crop and cache the requested panel.
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

    private static let normalizedSheet: CGImage? = {
        guard let source = UIImage(named: "artstudio_30_sheet")?.withRenderingMode(.alwaysOriginal),
              let cg = source.cgImage else { return nil }

        // For the 1-bit sheet, construct a true grayscale CGImage from the same
        // decoded sample buffer. Using CGImage(maskWidth:...) is intentionally
        // avoided because mask semantics invert/alpha-map the samples.
        if cg.bitsPerComponent == 1,
           cg.bitsPerPixel == 1,
           let provider = cg.dataProvider,
           let gray = CGImage(
                width: cg.width,
                height: cg.height,
                bitsPerComponent: 1,
                bitsPerPixel: 1,
                bytesPerRow: cg.bytesPerRow,
                space: CGColorSpaceCreateDeviceGray(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
                provider: provider,
                decode: [0, 1],
                shouldInterpolate: false,
                intent: .defaultIntent
           ) {
            return gray
        }

        return cg
    }()

    static func panel(at rawIndex: Int) -> UIImage {
        let index = min(max(rawIndex, 0), columns * rows - 1)
        let key = NSNumber(value: index)
        if let cached = cache.object(forKey: key) { return cached }

        guard let sheet = normalizedSheet else { return fallback }

        let panelWidth = sheet.width / columns
        let panelHeight = sheet.height / rows
        let column = index % columns
        let row = index / columns
        let cropRect = CGRect(
            x: column * panelWidth,
            y: row * panelHeight,
            width: panelWidth,
            height: panelHeight
        )

        guard let cropped = sheet.cropping(to: cropRect) else { return fallback }

        // Render into a standard opaque RGB bitmap. From this point on SwiftUI
        // receives an ordinary image: white paper and black line art.
        let size = CGSize(width: cropped.width, height: cropped.height)
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        format.scale = 1

        let image = UIGraphicsImageRenderer(size: size, format: format).image { renderer in
            let ctx = renderer.cgContext
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.fill(CGRect(origin: .zero, size: size))
            ctx.interpolationQuality = .none
            ctx.saveGState()
            ctx.translateBy(x: 0, y: size.height)
            ctx.scaleBy(x: 1, y: -1)
            ctx.draw(cropped, in: CGRect(origin: .zero, size: size))
            ctx.restoreGState()
        }.withRenderingMode(.alwaysOriginal)

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
