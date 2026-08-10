import SwiftUI

/// Rounded, high-contrast type scale sized for early readers.
/// Prefer these over inline `.font(.system(size:...))` calls.
///
/// Each level maps to a semantic `Font.TextStyle` (rather than a fixed
/// point size) so it scales with the user's Dynamic Type setting — a
/// parent or child using a larger system text size gets larger PlayLand
/// text too, instead of every screen staying frozen at one fixed size.
enum PlayLandTypography {
    static let display = Font.system(.largeTitle, design: .rounded).weight(.heavy)
    static let title = Font.system(.title, design: .rounded).weight(.bold)
    static let heading = Font.system(.title3, design: .rounded).weight(.bold)
    static let body = Font.system(.body, design: .rounded).weight(.medium)
    static let caption = Font.system(.caption, design: .rounded).weight(.semibold)
}
