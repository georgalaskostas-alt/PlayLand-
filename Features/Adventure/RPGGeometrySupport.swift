import CoreGraphics

extension CGPoint {
    init(x: Int, y: Int) {
        self.init(x: CGFloat(x), y: CGFloat(y))
    }
}
