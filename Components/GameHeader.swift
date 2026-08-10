import SwiftUI

/// The title + one-line instruction shown at the top of every mini-game.
/// Consolidates a pattern that was previously duplicated verbatim in each
/// game file. Speaks `subtitle` once when it first appears (so a child who
/// can't read yet still knows the objective) and offers a visible replay
/// button, since the same instruction must never be spoken twice at once.
struct GameHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(PlayLandTypography.title)
                .multilineTextAlignment(.center)

            HStack(spacing: 10) {
                Text(subtitle)
                    .font(PlayLandTypography.body)
                    .foregroundColor(PlayLandColors.secondaryText)
                    .multilineTextAlignment(.center)

                SpeakerButton(text: subtitle)
            }
        }
        .onAppear {
            SpeechManager.shared.speak(text: subtitle)
        }
    }
}
