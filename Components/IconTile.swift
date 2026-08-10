import SwiftUI

/// A square, rounded icon chip used in list rows (game icons, adventure
/// mode icons). Falls back gracefully via `AppAssets.image` if the named
/// asset hasn't been added to the catalog yet.
struct IconTile: View {
    let imageName: String
    var size: CGFloat = 60
    var background: Color = .white

    var body: some View {
        AppAssets.image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: size * 0.7, height: size * 0.7)
            .frame(width: size, height: size)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
            // Purely decorative next to a text label — hidden so VoiceOver
            // doesn't read a missing-asset placeholder's system name aloud.
            .accessibilityHidden(true)
    }
}
