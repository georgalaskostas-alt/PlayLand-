import UIKit

@MainActor
enum ArtStudioImageNormalizer {
    private static let cache = NSCache<NSNumber, UIImage>()
    private static let targetSize = CGSize(width: 240, height: 176)

    static func centeredImage(at index: Int) -> UIImage {
        let key = NSNumber(value: index)
        if let cached = cache.object(forKey: key) { return cached }

        let source = ArtStudioDirectPages.image(at: index)
        let normalized = normalize(source)
        cache.setObject(normalized, forKey: key)
        return normalized
    }

    private static func normalize(_ source: UIImage) -> UIImage {
        guard let cgImage = source.cgImage,
              let provider = cgImage.dataProvider,
              let data = provider.data,
              let bytes = CFDataGetBytePtr(data) else {
            return source
        }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = cgImage.bytesPerRow
        let bitsPerPixel = cgImage.bitsPerPixel
        let bytesPerPixel = max(bitsPerPixel / 8, 1)

        var minX = width
        var minY = height
        var maxX = -1
        var maxY = -1

        // Find the visible ink bounds and ignore near-white paper.
        for y in 0..<height {
            for x in 0..<width {
                let offset = y * bytesPerRow + x * bytesPerPixel
                let isInk: Bool

                if bytesPerPixel >= 3 {
                    let r = bytes[offset]
                    let g = bytes[offset + 1]
                    let b = bytes[offset + 2]
                    isInk = r < 242 || g < 242 || b < 242
                } else {
                    isInk = bytes[offset] < 242
                }

                if isInk {
                    minX = min(minX, x)
                    minY = min(minY, y)
                    maxX = max(maxX, x)
                    maxY = max(maxY, y)
                }
            }
        }

        guard maxX >= minX, maxY >= minY else { return source }

        // Add a small safety border around the detected drawing.
        let padding = 4
        minX = max(0, minX - padding)
        minY = max(0, minY - padding)
        maxX = min(width - 1, maxX + padding)
        maxY = min(height - 1, maxY + padding)

        let cropRect = CGRect(
            x: minX,
            y: minY,
            width: maxX - minX + 1,
            height: maxY - minY + 1
        )

        guard let cropped = cgImage.cropping(to: cropRect) else { return source }

        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        format.scale = 1

        return UIGraphicsImageRenderer(size: targetSize, format: format).image { renderer in
            let ctx = renderer.cgContext
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.fill(CGRect(origin: .zero, size: targetSize))

            let outerMargin: CGFloat = 12
            let available = CGSize(
                width: targetSize.width - outerMargin * 2,
                height: targetSize.height - outerMargin * 2
            )
            let cropSize = CGSize(width: cropped.width, height: cropped.height)
            let scale = min(available.width / cropSize.width, available.height / cropSize.height)
            let drawSize = CGSize(width: cropSize.width * scale, height: cropSize.height * scale)
            let drawRect = CGRect(
                x: (targetSize.width - drawSize.width) / 2,
                y: (targetSize.height - drawSize.height) / 2,
                width: drawSize.width,
                height: drawSize.height
            )

            ctx.interpolationQuality = .high
            ctx.saveGState()
            ctx.translateBy(x: 0, y: targetSize.height)
            ctx.scaleBy(x: 1, y: -1)
            let flipped = CGRect(
                x: drawRect.minX,
                y: targetSize.height - drawRect.maxY,
                width: drawRect.width,
                height: drawRect.height
            )
            ctx.draw(cropped, in: flipped)
            ctx.restoreGState()
        }.withRenderingMode(.alwaysOriginal)
    }
}
