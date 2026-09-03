import SwiftUI

struct ArtStudioExactPageView: View {
    let index: Int

    var body: some View {
        Group {
            if index < 30 {
                Image(uiImage: ArtStudioDirectPages.image(at: index))
                    .resizable()
                    .renderingMode(.original)
                    .interpolation(.high)
                    .scaledToFit()
            } else {
                ArtStudioProceduralPageView(index: index - 30)
            }
        }
        .aspectRatio(15.0 / 11.0, contentMode: .fit)
        .background(Color.white)
        .preferredColorScheme(.light)
    }
}
