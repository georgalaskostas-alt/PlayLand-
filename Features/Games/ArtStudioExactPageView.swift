import SwiftUI
import UIKit

/// Displays one of the 30 exact line-art panels supplied for PlayLand.
/// The source image is a 6 x 5 sprite sheet. We crop each panel with Core Graphics
/// and redraw it into an opaque RGB bitmap so 1-bit monochrome PNGs are never
/// interpreted as template/mask images by SwiftUI or the asset pipeline.
struct ArtStudioExactPageView: View {
    let index: Int

    var body: some View {
        Image(uiImage: ArtStudioExactSheet.panel(at: index))
            .resizable()
            .renderingMode(.original)
            .interpolation(.high)
            .scaledToFit()
            .aspectRatio(18.0 / 11.0, contentMode: .fit)
            .background(Color.white)
    }
}

private enum ArtStudioExactSheet {
    private static let columns = 6
    private static let rows = 5

    static let panels: [UIImage] = {
        guard let source = UIImage(named: "artstudio_30_sheet")?.withRenderingMode(.alwaysOriginal),
              let cgImage = source.cgImage else {
            return Array(repeating: fallback, count: columns * rows)
        }

        let pixelWidth = cgImage.width
        let pixelHeight = cgImage.height
        let panelWidth = pixelWidth / columns
        let panelHeight = pixelHeight / rows

        return (0..<(columns * rows)).map { index in
            let column = index % columns
            let row = index / columns
            let cropRect = CGRect(
                x: column * panelWidth,
                y: row * panelHeight,
                width: panelWidth,
                height: panelHeight
            )

            guard let cropped = cgImage.cropping(to: cropRect) else { return fallback }

            // Force the cropped monochrome source into a normal opaque RGB image.
            // This prevents the all-black rectangles seen when the 1-bit source is
            // interpreted as an image mask/template on device.
            let size = CGSize(width: cropped.width, height: cropped.height)
            let format = UIGraphicsImageRendererFormat()
            format.opaque = true
            format.scale = 1
            let renderer = UIGraphicsImageRenderer(size: size, format: format)

            return renderer.image { context in
                UIColor.white.setFill()
                context.fill(CGRect(origin: .zero, size: size))
                UIImage(cgImage: cropped, scale: 1, orientation: .up)
                    .draw(in: CGRect(origin: .zero, size: size))
            }.withRenderingMode(.alwaysOriginal)
        }
    }()

    static func panel(at index: Int) -> UIImage {
        panels[min(max(index, 0), panels.count - 1)]
    }

    private static var fallback: UIImage {
        let size = CGSize(width: 240, height: 176)
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
