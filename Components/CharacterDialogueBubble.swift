import SwiftUI

/// The dark, rounded speech bubble used for narration in interactive
/// stories/chapters. Centralizes a pattern that used to be hand-rolled.
///
/// `.frame(maxWidth: .infinity)` + `.fixedSize(horizontal: false, vertical:
/// true)` are load-bearing here, not decoration: without them this `Text`
/// sizes to its own ideal (unwrapped, single-line) width. Nested inside a
/// `ScrollView` — which does not itself constrain the cross-axis width of
/// its content — that ideal width wins, and a long sentence (a longer
/// German/Greek translation, in practice) renders past the right edge of
/// the screen instead of wrapping. Explicitly claiming the full width
/// offered by the parent, then letting height grow freely, is what makes
/// wrapping happen instead.
struct CharacterDialogueBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(PlayLandTypography.body)
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.black.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
    }
}
