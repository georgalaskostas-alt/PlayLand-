import SwiftUI

struct ArtStudioExactPageView: View {
    let index: Int

    var body: some View {
        GeometryReader { proxy in
            let availableWidth = max(proxy.size.width - 16, 0)
            let availableHeight = max(proxy.size.height - 16, 0)
            let sourceAspect: CGFloat = 15.0 / 11.0

            let fittedWidth = min(availableWidth, availableHeight * sourceAspect)
            let fittedHeight = fittedWidth / sourceAspect

            Group {
                if index < 30 {
                    Image(String(format: "artstudio_page_%02d", index))
                        .resizable()
                        .renderingMode(.original)
                        .interpolation(.high)
                        .scaledToFit()
                } else {
                    ArtStudioProceduralPageView(index: index - 30)
                }
            }
            .frame(width: fittedWidth, height: fittedHeight, alignment: .center)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
        .background(Color.white)
        .preferredColorScheme(.light)
        .onAppear {
            OrientationController.allowAll()
        }
    }
}
