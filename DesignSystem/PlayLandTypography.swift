import SwiftUI

/// Rounded, high-contrast type scale sized for early readers.
/// Prefer these over inline `.font(.system(size:...))` calls.
enum PlayLandTypography {
    static let display = Font.system(size: 40, weight: .heavy, design: .rounded)
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let heading = Font.system(size: 22, weight: .bold, design: .rounded)
    static let body = Font.system(size: 18, weight: .medium, design: .rounded)
    static let caption = Font.system(size: 14, weight: .semibold, design: .rounded)
}
