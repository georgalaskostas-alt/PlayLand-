import CoreGraphics

/// Shared spacing, corner-radius and touch-target constants so layout
/// values aren't duplicated (and drift) across screens.
enum PlayLandMetrics {
    static let cornerRadiusLarge: CGFloat = 28
    static let cornerRadiusMedium: CGFloat = 18
    static let cornerRadiusSmall: CGFloat = 12

    static let spacingLarge: CGFloat = 24
    static let spacingMedium: CGFloat = 16
    static let spacingSmall: CGFloat = 8

    /// Apple's baseline minimum hit target.
    static let minTouchTarget: CGFloat = 44
    /// The size used for primary, "big kid-friendly" actions.
    static let primaryTouchTarget: CGFloat = 64

    static let cardShadowRadius: CGFloat = 10
}
