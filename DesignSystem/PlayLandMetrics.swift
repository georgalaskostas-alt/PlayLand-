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

    /// Fixed, intentional (never raw-PNG-driven) logical render sizes for
    /// the RPG world. Every world image is wrapped in `.resizable()
    /// .scaledToFit().frame(width:height:)` using one of these, so a large
    /// transparent source PNG can never make a world object render
    /// oversized. Tap/hit targets stay independent of these — see
    /// `LocationExploreView`'s `.contentShape(Rectangle())` usage — so
    /// generous transparent padding in the art never shrinks or enlarges
    /// what's actually tappable.
    static let worldSceneryVisualSize: CGFloat = 96
    /// Small accent props (Dino Farm bowls/brush/splash/bubbles) shown
    /// alongside, not in place of, the character.
    static let worldPropAccentSize: CGFloat = 52
}
