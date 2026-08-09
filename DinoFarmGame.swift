import SwiftUI

struct DinoFarmGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @Environment(\.dismiss) var dismiss

    @State private var happiness = 0
    @State private var taps = 0
    @State private var isFinished = false

    private let goal = 100

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                Text("Dino Farm")
                    .font(.largeTitle.bold())

                Text("Take care of Babis until he's fully happy!")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Image("babis_dinosaur")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .scaleEffect(happiness >= goal ? 1.08 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: happiness)

                VStack(spacing: 6) {
                    ProgressView(value: Double(happiness), total: Double(goal))
                        .tint(PlayLandTheme.leafGreen)
                    Text("Happiness: \(happiness)/\(goal)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 30)

                HStack(spacing: 16) {
                    careButton(title: "Feed", emoji: "🍃", amount: 20)
                    careButton(title: "Clean", emoji: "🧼", amount: 15)
                    careButton(title: "Play", emoji: "🎾", amount: 15)
                }

                Spacer()
            }
            .padding()

            if isFinished {
                CompletionBadgeView(
                    title: "Babis is Happy!",
                    message: "You cared for Babis with \(taps) actions.",
                    stars: stars,
                    buttonTitle: "Great job!",
                    action: {
                        progressManager.completeGame("dino_farm", stars: stars)
                        dismiss()
                    }
                )
            }
        }
    }

    private var stars: Int {
        if taps <= 6 { return 3 }
        if taps <= 9 { return 2 }
        return 1
    }

    private func careButton(title: String, emoji: String, amount: Int) -> some View {
        Button(action: { care(amount: amount) }) {
            VStack(spacing: 6) {
                Text(emoji).font(.system(size: 30))
                Text(title).font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(PlayLandTheme.warmCream)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
        }
        .disabled(isFinished)
    }

    private func care(amount: Int) {
        taps += 1
        happiness = min(goal, happiness + amount)
        if happiness >= goal {
            withAnimation { isFinished = true }
        }
    }
}
