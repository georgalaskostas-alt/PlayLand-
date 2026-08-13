import SwiftUI

/// The dark, rounded speech bubble used for narration in interactive
/// stories/chapters. Centralizes a pattern that used to be hand-rolled.
///
/// `.frame(maxWidth: .infinity)` + `.fixedSize(horizontal: false, vertical:
/// true)` are load-bearing here, not decoration: without them this `Text`
/// sizes to its own ideal (unwrapped, single-line) width, and a long
/// sentence would render past the edge of whatever offers this view its
/// width instead of wrapping.
///
/// `.padding(16)` comes *before* `.frame(maxWidth: .infinity, ...)`, not
/// after: padding applied outside an already-fully-expanded
/// `maxWidth: .infinity` frame adds 32pt (16 on each side) *on top of*
/// whatever width was offered, so the bubble reports itself 32pt wider
/// than its parent actually gave it — which was a real, confirmed
/// contributor to a real-device horizontal-overflow report (the excess
/// only ever got caught by a distant ancestor's `.clipped()`, which
/// center-crops rather than reflowing, cutting off leading characters).
/// Padding first, then expand-to-fill, keeps the reported size exactly
/// equal to what was offered.
struct CharacterDialogueBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(PlayLandTypography.body)
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            // TEMPORARY — see DesignSystem/LayoutDebugTemp.swift. Measures
            // the raw Text's own bounds, before padding/frame are applied,
            // so it's possible to tell whether the Text itself is already
            // wider than intended at this point vs. becoming so later.
            .debugLayout("narrationText", .yellow)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
            // TEMPORARY — see DesignSystem/LayoutDebugTemp.swift.
            .debugLayout("dialogueBubble", .purple)
    }
}
