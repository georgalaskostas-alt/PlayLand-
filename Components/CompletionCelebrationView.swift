import SwiftUI

/// The celebration panel shown when a game, story, chapter or RPG
/// challenge is finished: art, a headline, an optional message, an
/// optional reward item, a star result and a continue button. Used by
/// every mini-game, the story/chapter flows, and chest rewards.
struct CompletionCelebrationView: View {
    let title: String
    let message: String
    let stars: Int
    let buttonTitle: String
    let action: () -> Void

    /// Defaults to the badges sheet (games/stories); chest rewards pass
    /// `AppAssets.PlannedProps.chestOpen` instead.
    var imageAssetName: String = AppAssets.Badges.sheet
    /// When set, shows "you found this many of this item" below the
    /// message — used by chest/challenge rewards, unused (nil) elsewhere.
    var rewardItemId: String?
    var rewardItemCount: Int = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: 20) {
            AppAssets.image(imageAssetName)
                .resizable()
                .scaledToFit()
                .frame(height: 110)

            Text(title)
                .font(PlayLandTypography.display)
                .multilineTextAlignment(.center)

            Text(message)
                .font(PlayLandTypography.body)
                .foregroundColor(PlayLandColors.secondaryText)
                .multilineTextAlignment(.center)

            if let rewardItemId, let item = ItemLibrary.item(withId: rewardItemId) {
                HStack(spacing: 8) {
                    item.icon.frame(width: 32, height: 32)
                    Text("×\(rewardItemCount) \(Loc.t(item.nameKey))")
                        .font(PlayLandTypography.body.weight(.semibold))
                }
                .accessibilityElement(children: .combine)
            }

            StarCounter(stars: stars)

            PlayLandPrimaryButton(title: buttonTitle, color: PlayLandColors.sunOrange, action: action)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge)
                .fill(PlayLandColors.cardBackground)
                .shadow(color: .black.opacity(0.2), radius: 20)
        )
        .padding(24)
        .scaleEffect(hasAppeared ? 1.0 : 0.85)
        .opacity(hasAppeared ? 1.0 : 0)
        .onAppear {
            AudioManager.shared.play(.gameCompletion)
            SpeechManager.shared.speak(text: "\(title). \(message)")
            withAnimation(PlayLandAnimation.respecting(reduceMotion, PlayLandAnimation.celebration)) {
                hasAppeared = true
            }
        }
    }
}
