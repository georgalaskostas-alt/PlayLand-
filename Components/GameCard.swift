import SwiftUI

/// The standard row/card used to present a game, dino-world activity or
/// story in a list: icon, title, description, a completion badge, and the
/// player's best star result for that item (if any).
struct GameCard: View {
    let item: MenuItem
    let isCompleted: Bool
    var bestStars: Int = 0

    var body: some View {
        HStack(spacing: 14) {
            IconTile(imageName: item.iconImageName, background: PlayLandColors.warmCream)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(PlayLandTypography.heading)
                Text(item.description)
                    .font(PlayLandTypography.body)
                    .foregroundColor(PlayLandColors.secondaryText)
                    .lineLimit(2)

                if isCompleted {
                    ProgressBadge()
                }
            }

            Spacer()

            if bestStars > 0 {
                StarCounter(stars: bestStars, size: 18)
            }
        }
        .padding(.vertical, 6)
    }
}

/// The story-list equivalent of `GameCard`, using a cover image instead of
/// a small icon and a flat "+5" star reward instead of a best-score tally.
struct StoryCard: View {
    let item: StoryItem
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 14) {
            AppAssets.image(item.coverImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(PlayLandTypography.heading)
                Text(item.description)
                    .font(PlayLandTypography.body)
                    .foregroundColor(PlayLandColors.secondaryText)
                    .lineLimit(2)

                if isCompleted {
                    ProgressBadge()
                }
            }

            Spacer()

            if isCompleted {
                VStack(spacing: 2) {
                    AppAssets.image(AppAssets.PlannedUI.star)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                    Text("+5")
                        .font(PlayLandTypography.caption)
                        .foregroundColor(PlayLandColors.warning)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
