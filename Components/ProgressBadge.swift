import SwiftUI

/// A small "Completed!" pill shown on games, stories and chapters. Pairs an
/// icon with text so completion is never communicated by color alone.
struct ProgressBadge: View {
    var text: String = "Completed!"

    var body: some View {
        HStack(spacing: 4) {
            AppAssets.image(AppAssets.PlannedUI.check)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
            Text(text)
                .font(PlayLandTypography.caption)
        }
        .foregroundColor(PlayLandColors.success)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }
}
