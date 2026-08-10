import SwiftUI

/// A full-bleed background image with an optional dark scrim, used by every
/// full-screen scene (stories, chapters, explore mode, the adventure hub).
struct PlayLandBackground: View {
    let imageName: String
    var scrimOpacity: Double = 0.18

    var body: some View {
        AppAssets.image(imageName)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .overlay(Color.black.opacity(scrimOpacity).ignoresSafeArea())
    }
}
