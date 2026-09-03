import SwiftUI

struct ArtStudioExactPageView: View {
    let index: Int

    var body: some View {
        Image(uiImage: ArtStudioDirectPages.image(at: index % 3))
            .resizable()
            .renderingMode(.original)
            .interpolation(.high)
            .scaledToFit()
            .aspectRatio(15.0 / 11.0, contentMode: .fit)
            .background(Color.white)
            .preferredColorScheme(.light)
    }
}
