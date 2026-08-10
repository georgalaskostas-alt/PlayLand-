import SwiftUI

/// The base rounded, softly-shadowed surface used by every card-style
/// container in the app (game cards, adventure mode rows, completion panels).
struct PlayLandCard<Content: View>: View {
    var cornerRadius: CGFloat = PlayLandMetrics.cornerRadiusMedium
    var padding: CGFloat = PlayLandMetrics.spacingMedium
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(PlayLandColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.12), radius: PlayLandMetrics.cardShadowRadius, y: 4)
    }
}
