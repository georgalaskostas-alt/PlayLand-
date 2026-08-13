import SwiftUI

/// The dark, rounded speech bubble used for narration in interactive
/// stories/chapters. Centralizes a pattern that used to be hand-rolled.
///
/// The Text is given `.frame(maxWidth: .infinity, alignment: .leading)`
/// *before* `.fixedSize(horizontal: false, vertical: true)`, so it first
/// claims exactly the finite width its parent offers, then wraps within
/// that width and grows only vertically. Padding and background are
/// applied last, around the already-correctly-sized text.
///
/// This view was never actually the confirmed source of the horizontal
/// overflow a real-device diagnostic build tracked down — the real cause
/// was `InteractiveSceneView` placing this bubble in an `HStack` shared
/// with `SpeakerButton`, which let it claim more width than it was
/// offered even though its own modifiers were fine in isolation. See
/// `InteractiveSceneView.panelContent` for the fix: this bubble is now
/// given the parent's full width directly (the same width the choice
/// buttons receive), with `SpeakerButton` layered on top as a `ZStack`
/// overlay that never participates in this view's width proposal.
struct CharacterDialogueBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(PlayLandTypography.body)
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(16)
            .background(Color.black.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
    }
}
