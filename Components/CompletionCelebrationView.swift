import SwiftUI

/// The celebration panel shown when a game, story or chapter is finished:
/// badge art, a headline, an optional message, a star result and a
/// continue button. Used by every mini-game and by the story/chapter flows.
struct CompletionCelebrationView: View {
    let title: String
    let message: String
    let stars: Int
    let buttonTitle: String
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: 20) {
            AppAssets.image(AppAssets.Badges.sheet)
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
            withAnimation(PlayLandAnimation.respecting(reduceMotion, PlayLandAnimation.celebration)) {
                hasAppeared = true
            }
        }
    }
}
