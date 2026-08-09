import SwiftUI

enum PlayLandTheme {
    static let sunOrange = Color(red: 1.0, green: 0.58, blue: 0.16)
    static let leafGreen = Color(red: 0.22, green: 0.70, blue: 0.36)
    static let skyBlue = Color(red: 0.25, green: 0.62, blue: 0.93)
    static let berryPurple = Color(red: 0.58, green: 0.40, blue: 0.86)
    static let warmCream = Color(red: 1.0, green: 0.97, blue: 0.90)
}

struct PlayfulButtonStyle: ButtonStyle {
    var color: Color = PlayLandTheme.leafGreen

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 36)
            .padding(.vertical, 14)
            .background(color)
            .clipShape(Capsule())
            .shadow(color: color.opacity(0.4), radius: 6, y: 3)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct ChoiceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(PlayLandTheme.skyBlue.opacity(configuration.isPressed ? 0.75 : 0.9))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct StarRatingView: View {
    let stars: Int
    let maxStars: Int

    init(stars: Int, maxStars: Int = 3) {
        self.stars = stars
        self.maxStars = maxStars
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<maxStars, id: \.self) { index in
                Image("ui_star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .opacity(index < stars ? 1.0 : 0.25)
            }
        }
    }
}

struct RoundedIconTile: View {
    let imageName: String
    var size: CGFloat = 60
    var background: Color = .white

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: size * 0.7, height: size * 0.7)
            .frame(width: size, height: size)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
    }
}

struct CompletionBadgeView: View {
    let title: String
    let message: String
    let stars: Int
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image("badges")
                .resizable()
                .scaledToFit()
                .frame(height: 110)

            Text(title)
                .font(.largeTitle.bold())

            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            StarRatingView(stars: stars)

            Button(action: action) {
                Text(buttonTitle)
            }
            .buttonStyle(PlayfulButtonStyle(color: PlayLandTheme.sunOrange))
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.2), radius: 20)
        )
        .padding(24)
    }
}
