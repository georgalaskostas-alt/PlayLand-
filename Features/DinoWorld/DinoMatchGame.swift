import SwiftUI

private struct MatchCard: Identifiable {
    let id: Int
    let imageName: String
    var isFaceUp = false
    var isMatched = false
}

struct DinoMatchGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @Environment(\.dismiss) var dismiss

    private let images = [AppAssets.Characters.babis, AppAssets.Characters.kotsifi, AppAssets.Characters.fox]

    @State private var cards: [MatchCard] = []
    @State private var faceUpIndices: [Int] = []
    @State private var moves = 0
    @State private var isFinished = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                GameHeader(title: "Dino Match", subtitle: "Flip the cards and find every pair!")

                LazyVGrid(columns: Array(repeating: GridItem(spacing: 12), count: 3), spacing: 12) {
                    ForEach(cards) { card in
                        Button(action: { flip(card) }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium)
                                    .fill(card.isMatched ? PlayLandColors.leafGreen.opacity(0.2) : PlayLandColors.skyBlue.opacity(0.15))

                                if card.isFaceUp || card.isMatched {
                                    AppAssets.image(card.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .padding(10)
                                } else {
                                    Text("❓")
                                        .font(.system(size: 34))
                                }
                            }
                            .frame(height: 100)
                        }
                        .disabled(card.isFaceUp || card.isMatched)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .onAppear(perform: setupCards)

            if isFinished {
                CompletionCelebrationView(
                    title: "All Matched!",
                    message: "You found every pair in \(moves) moves.",
                    stars: stars,
                    buttonTitle: "Nice work!",
                    action: {
                        progressManager.completeGame("dino_match", stars: stars)
                        dismiss()
                    }
                )
            }
        }
    }

    private var stars: Int {
        if moves <= 5 { return 3 }
        if moves <= 8 { return 2 }
        return 1
    }

    private func setupCards() {
        let deck = (images + images).shuffled()
        cards = deck.enumerated().map { MatchCard(id: $0.offset, imageName: $0.element) }
        faceUpIndices = []
        moves = 0
        isFinished = false
    }

    private func flip(_ card: MatchCard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        guard faceUpIndices.count < 2 else { return }

        cards[index].isFaceUp = true
        faceUpIndices.append(index)

        if faceUpIndices.count == 2 {
            moves += 1
            let first = faceUpIndices[0]
            let second = faceUpIndices[1]

            if cards[first].imageName == cards[second].imageName {
                cards[first].isMatched = true
                cards[second].isMatched = true
                faceUpIndices = []
                if cards.allSatisfy({ $0.isMatched }) {
                    withAnimation { isFinished = true }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    cards[first].isFaceUp = false
                    cards[second].isFaceUp = false
                    faceUpIndices = []
                }
            }
        }
    }
}
