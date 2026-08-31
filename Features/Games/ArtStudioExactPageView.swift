import SwiftUI
import UIKit

/// Displays one of the 30 exact line-art panels supplied for PlayLand.
/// The supplied PNG is a 1-bit grayscale sheet. We decode its pixels directly
/// into an 8-bit RGBA bitmap so neither SwiftUI nor Core Graphics can treat it
/// as a template/mask and turn the whole panel black.
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

        // The shipped sheet is 1-bit grayscale. Read the decompressed bitmap
        // samples directly, preserving 0=black ink and 1=white paper.
        if cgImage.bitsPerPixel == 1,
           cgImage.bitsPerComponent == 1,
           let provider = cgImage.dataProvider,
           let cfData = provider.data {
            let data = cfData as Data
            let bytesPerRow = cgImage.bytesPerRow

            return (0..<(columns * rows)).map { index in
                let column = index % columns
                let row = index / columns
                let originX = column * panelWidth
                let originY = row * panelHeight
                return makeRGBPanel(
                    sourceData: data,
                    sourceBytesPerRow: bytesPerRow,
                    originX: originX,
                    originY: originY,
                    width: panelWidth,
                    height: panelHeight
                )
            }
        }

        // Safety path for a future RGB version of the asset.
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
            return UIImage(cgImage: cropped, scale: 1, orientation: .up).withRenderingMode(.alwaysOriginal)
        }
    }()

    private static func makeRGBPanel(
        sourceData: Data,
        sourceBytesPerRow: Int,
        originX: Int,
        originY: Int,
        width: Int,
        height: Int
    ) -> UIImage {
        let bytesPerPixel = 4
        let outputBytesPerRow = width * bytesPerPixel
        var rgba = Data(count: outputBytesPerRow * height)

        sourceData.withUnsafeBytes { sourceRaw in
            rgba.withUnsafeMutableBytes { outputRaw in
                guard let source = sourceRaw.bindMemory(to: UInt8.self).baseAddress,
                      let output = outputRaw.bindMemory(to: UInt8.self).baseAddress else { return }

                for y in 0..<height {
                    let sourceY = originY + y
                    for x in 0..<width {
                        let sourceX = originX + x
                        let sourceByteIndex = sourceY * sourceBytesPerRow + (sourceX >> 3)
                        let bitIndex = 7 - (sourceX & 7)
                        let sample = (source[sourceByteIndex] >> bitIndex) & 1
                        let value: UInt8 = sample == 0 ? 0 : 255

                        let out = y * outputBytesPerRow + x * bytesPerPixel
                        output[out] = value
                        output[out + 1] = value
                        output[out + 2] = value
                        output[out + 3] = 255
                    }
                }
            }
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let provider = CGDataProvider(data: rgba as CFData),
              let image = CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: outputBytesPerRow,
                space: colorSpace,
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
                provider: provider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent
              ) else { return fallback }

        return UIImage(cgImage: image, scale: 1, orientation: .up).withRenderingMode(.alwaysOriginal)
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
