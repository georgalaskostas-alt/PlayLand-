import SwiftUI
import UIKit

/// Displays one of the 30 exact line-art panels supplied for PlayLand.
/// The source image is a 6 x 5 sprite sheet. Some iOS/Xcode combinations decode
/// the 1-bit source as an image mask. We explicitly invert that mask so the white
/// paper stays white and only the drawing strokes are painted black.
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

            if cropped.isMask,
               let provider = cropped.dataProvider,
               let invertedMask = CGImage(
                    maskWidth: cropped.width,
                    height: cropped.height,
                    bitsPerComponent: cropped.bitsPerComponent,
                    bitsPerPixel: cropped.bitsPerPixel,
                    bytesPerRow: cropped.bytesPerRow,
                    provider: provider,
                    decode: [1, 0],
                    shouldInterpolate: false
               ) {
                // The original sheet has white background values and black line values.
                // A normal CG mask would paint the white background. Inverting the mask
                // makes only the actual black line art opaque.
                ctx.saveGState()
                ctx.translateBy(x: 0, y: size.height)
                ctx.scaleBy(x: 1, y: -1)
                ctx.clip(to: rect, mask: invertedMask)
                ctx.setFillColor(UIColor.black.cgColor)
                ctx.fill(rect)
                ctx.restoreGState()
            } else {
                // Normal RGB/gray source: draw it directly into the opaque white bitmap.
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
