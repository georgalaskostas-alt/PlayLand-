import SwiftUI

/// Shared animation curves so interactions feel consistent across the app.
/// Callers that respect `accessibilityReduceMotion` should fall back to
/// `.none` (or a plain `.linear(duration: 0.01)`) instead of using these directly.
enum PlayLandAnimation {
    static let quick = Animation.spring(response: 0.25, dampingFraction: 0.65)
    static let bounce = Animation.spring(response: 0.4, dampingFraction: 0.55)
    static let celebration = Animation.spring(response: 0.55, dampingFraction: 0.6)

    /// Returns `animation` unless the user has Reduce Motion enabled, in which
    /// case a near-instant linear animation is used so state still updates
    /// without the spring/bounce motion.
    static func respecting(_ reduceMotion: Bool, _ animation: Animation) -> Animation {
        reduceMotion ? .linear(duration: 0.01) : animation
    }
}
