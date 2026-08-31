import SwiftUI
import UIKit

/// Displays one of the 30 exact line-art panels supplied for PlayLand.
/// The source is a 6 x 5 monochrome sprite sheet. We explicitly treat 1-bit
/// images as masks so iOS cannot render the whole panel as a black rectangle.
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
            .preferredColorScheme(.light)
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

        let panelWidth = cgImage.width / columns
        let panelHeight = cgImage.height / rows

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
            return renderPanel(cropped)
        }
    }()

    private static func renderPanel(_ cropped: CGImage) -> UIImage {
        let size = CGSize(width: cropped.width, height: cropped.height)
        let rect = CGRect(origin: .zero, size: size)
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        format.scale = 1

        return UIGraphicsImageRenderer(size: size, format: format).image { renderer in
            let ctx = renderer.cgContext
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.fill(rect)

            // PNG decoders do not always set isMask=true for 1-bit artwork.
            // Treat any 1-bit source as a mask explicitly. In this sheet 0 = ink
            // and 1 = paper, so the normal decode maps only the black line pixels.
            if (cropped.isMask || cropped.bitsPerPixel == 1),
               let provider = cropped.dataProvider,
               let lineMask = CGImage(
                    maskWidth: cropped.width,
                    height: cropped.height,
                    bitsPerComponent: 1,
                    bitsPerPixel: 1,
                    bytesPerRow: cropped.bytesPerRow,
                    provider: provider,
                    decode: [0, 1],
                    shouldInterpolate: false
               ) {
                ctx.saveGState()
                ctx.translateBy(x: 0, y: size.height)
                ctx.scaleBy(x: 1, y: -1)
                ctx.clip(to: rect, mask: lineMask)
                ctx.setFillColor(UIColor.black.cgColor)
                ctx.fill(rect)
                ctx.restoreGState()
            } else {
                ctx.saveGState()
                ctx.translateBy(x: 0, y: size.height)
                ctx.scaleBy(x: 1, y: -1)
                ctx.interpolationQuality = .high
                ctx.draw(cropped, in: rect)
                ctx.restoreGState()
            }
        }.withRenderingMode(.alwaysOriginal)
    }

    static func panel(at index: Int) -> UIImage {
        panels[min(max(index, 0), panels.count - 1)]
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
