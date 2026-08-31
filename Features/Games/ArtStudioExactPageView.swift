import SwiftUI
import UIKit

/// Displays one of the 30 exact line-art panels supplied for PlayLand.
/// The source remains the compact 1-bit sheet, but panels are decoded lazily
/// and cached one-by-one so opening Art Studio is fast and the asset catalog
/// never has to distill an invalid RGB placeholder.
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

        let image: UIImage
        if cgImage.bitsPerPixel == 1,
           cgImage.bitsPerComponent == 1,
           let provider = cgImage.dataProvider,
           let cfData = provider.data {
            image = decode1BitPanel(
                data: cfData as Data,
                sourceBytesPerRow: cgImage.bytesPerRow,
                originX: column * panelWidth,
                originY: row * panelHeight,
                width: panelWidth,
                height: panelHeight
            )
        } else {
            let crop = CGRect(x: column * panelWidth, y: row * panelHeight, width: panelWidth, height: panelHeight)
            if let cropped = cgImage.cropping(to: crop) {
                image = UIImage(cgImage: cropped, scale: 1, orientation: .up).withRenderingMode(.alwaysOriginal)
            } else {
                image = fallback
            }
        }

        cache.setObject(image, forKey: key)
        return image
    }

    private static func decode1BitPanel(
        data: Data,
        sourceBytesPerRow: Int,
        originX: Int,
        originY: Int,
        width: Int,
        height: Int
    ) -> UIImage {
        let outputBytesPerRow = width * 4
        var rgba = Data(count: outputBytesPerRow * height)

        data.withUnsafeBytes { srcRaw in
            rgba.withUnsafeMutableBytes { dstRaw in
                guard let src = srcRaw.bindMemory(to: UInt8.self).baseAddress,
                      let dst = dstRaw.bindMemory(to: UInt8.self).baseAddress else { return }

                for y in 0..<height {
                    let sourceY = originY + y
                    for x in 0..<width {
                        let sourceX = originX + x
                        let sourceByte = sourceY * sourceBytesPerRow + (sourceX >> 3)
                        let bit = 7 - (sourceX & 7)
                        let sample = (src[sourceByte] >> bit) & 1
                        let value: UInt8 = sample == 0 ? 0 : 255
                        let out = y * outputBytesPerRow + x * 4
                        dst[out] = value
                        dst[out + 1] = value
                        dst[out + 2] = value
                        dst[out + 3] = 255
                    }
                }
            }
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let provider = CGDataProvider(data: rgba as CFData),
              let cg = CGImage(
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

        return UIImage(cgImage: cg, scale: 1, orientation: .up).withRenderingMode(.alwaysOriginal)
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
