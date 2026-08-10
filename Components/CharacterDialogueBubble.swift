import SwiftUI

/// The dark, rounded speech bubble used for narration and character
/// dialogue (Interactive stories, Explore Mode object taps, the Fox Cave
/// cutscene). Centralizes a pattern that used to be hand-rolled per screen.
struct CharacterDialogueBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(PlayLandTypography.heading)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(18)
            .background(Color.black.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
    }
}
