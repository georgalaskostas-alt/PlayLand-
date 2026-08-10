import SwiftUI

/// The title + one-line instruction shown at the top of every mini-game.
/// Consolidates a pattern that was previously duplicated verbatim in each
/// game file.
struct GameHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(PlayLandTypography.title)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(PlayLandTypography.body)
                .foregroundColor(PlayLandColors.secondaryText)
                .multilineTextAlignment(.center)
        }
    }
}
