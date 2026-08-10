import SwiftUI

/// The PlayLand color palette. All screens should draw colors from here
/// instead of inlining `Color(red:green:blue:)` literals.
enum PlayLandColors {
    static let sunOrange = Color(red: 1.0, green: 0.58, blue: 0.16)
    static let leafGreen = Color(red: 0.22, green: 0.70, blue: 0.36)
    static let skyBlue = Color(red: 0.25, green: 0.62, blue: 0.93)
    static let berryPurple = Color(red: 0.58, green: 0.40, blue: 0.86)
    static let warmCream = Color(red: 1.0, green: 0.97, blue: 0.90)

    static let success = leafGreen
    static let warning = sunOrange
    static let danger = Color(red: 0.86, green: 0.30, blue: 0.30)

    static let cardBackground = Color(.systemBackground)
    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
}
