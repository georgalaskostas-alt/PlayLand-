import SwiftUI
import UIKit

/// Displays one of the 30 exact line-art panels supplied for PlayLand.
/// The source asset is now a normal RGB PNG, so we only crop each panel once.
/// No per-pixel conversion or monochrome-mask decoding happens at runtime.
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

    static let panels: [UIImage] = {
        guard let source = UIImage(named: "artstudio_30_sheet_rgb")?.withRenderingMode(.alwaysOriginal),
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
            return UIImage(cgImage: cropped, scale: 1, orientation: .up)
                .withRenderingMode(.alwaysOriginal)
        }
    }()

    static func panel(at index: Int) -> UIImage {
        guard !panels.isEmpty else { return fallback }
        return panels[min(max(index, 0), panels.count - 1)]
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
