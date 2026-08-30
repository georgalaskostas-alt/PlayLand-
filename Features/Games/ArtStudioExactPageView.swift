import SwiftUI

/// Displays one of the 30 exact line-art panels supplied for PlayLand.
/// The source asset is a 6 x 5 sprite sheet containing the selected coloring pages.
struct ArtStudioExactPageView: View {
    let index: Int

    var body: some View {
        GeometryReader { proxy in
            let safeIndex = min(max(index, 0), 29)
            let column = safeIndex % 6
            let row = safeIndex / 6
            let w = proxy.size.width
            let h = proxy.size.height

            Image("artstudio_30_sheet")
                .renderingMode(.original)
                .resizable()
                .interpolation(.high)
                .frame(width: w * 6, height: h * 5, alignment: .topLeading)
                .offset(x: -CGFloat(column) * w, y: -CGFloat(row) * h)
        }
        .aspectRatio(18.0 / 13.2, contentMode: .fit)
        .clipped()
        .background(Color.white)
    }
}
