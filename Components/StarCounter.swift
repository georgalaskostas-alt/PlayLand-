import SwiftUI

/// A row of star glyphs indicating a score out of `maxStars`, used on
/// completion screens and on game cards to show a player's best result.
struct StarCounter: View {
    let stars: Int
    var maxStars: Int = 3
    var size: CGFloat = 28

    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<maxStars, id: \.self) { index in
                AppAssets.image(AppAssets.PlannedUI.star)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .opacity(index < stars ? 1.0 : 0.25)
                    .scaleEffect(hasAppeared || index >= stars ? 1.0 : 0.6)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Loc.t("accessibility.starsEarned", stars, maxStars))
        .onAppear {
            withAnimation(PlayLandAnimation.respecting(reduceMotion, PlayLandAnimation.bounce).delay(0.1)) {
                hasAppeared = true
            }
        }
    }
}
