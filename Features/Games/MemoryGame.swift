import SwiftUI

private struct MemoryCard: Identifiable {
    let id: Int
    let symbol: String
    var isFaceUp = false
    var isMatched = false
}

struct MemoryGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    private let symbols = ["🦖", "🦕", "🥚", "🌿", "🍃", "🦴"]

    @State private var cards: [MemoryCard] = []
    @State private var faceUpIndices: [Int] = []
    @State private var moves = 0
    @State private var isFinished = false

    var body: some View {
        ZStack {
            ScrollView {
            VStack(spacing: 20) {
                GameHeader(title: Loc.t("game.memoryGame.title"), subtitle: Loc.t("game.memoryGame.instruction"))

                LazyVGrid(columns: Array(repeating: GridItem(spacing: 10), count: 4), spacing: 10) {
                    ForEach(cards) { card in
                        Button(action: { flip(card) }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusSmall)
                                    .fill(card.isMatched ? PlayLandColors.leafGreen.opacity(0.25) : PlayLandColors.skyBlue.opacity(0.15))

                                Text(card.isFaceUp || card.isMatched ? card.symbol : "❔")
                                    .font(.system(size: 28))
                            }
                            .frame(height: 70)
                        }
                        .disabled(card.isFaceUp || card.isMatched)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .onAppear(perform: setupCards)
            }

            if isFinished {
                CompletionCelebrationView(
                    title: Loc.t("game.memoryGame.completeTitle"),
                    message: Loc.t("game.memoryGame.completeMessage", moves),
                    stars: stars,
                    buttonTitle: Loc.t("action.continue"),
                    action: {
                        progressManager.completeGame("memory_game", stars: stars)
                        dismiss()
                    }
                )
            }
        }
    }

    private var stars: Int {
        if moves <= 8 { return 3 }
        if moves <= 12 { return 2 }
        return 1
    }

    private func setupCards() {
        let deck = (symbols + symbols).shuffled()
        cards = deck.enumerated().map { MemoryCard(id: $0.offset, symbol: $0.element) }
        faceUpIndices = []
        moves = 0
        isFinished = false
    }

    private func flip(_ card: MemoryCard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        guard faceUpIndices.count < 2 else { return }

        cards[index].isFaceUp = true
        faceUpIndices.append(index)

        if faceUpIndices.count == 2 {
            moves += 1
            let first = faceUpIndices[0]
            let second = faceUpIndices[1]

            if cards[first].symbol == cards[second].symbol {
                cards[first].isMatched = true
                cards[second].isMatched = true
                faceUpIndices = []
                AudioManager.shared.play(.correct)
                if cards.allSatisfy({ $0.isMatched }) {
                    withAnimation { isFinished = true }
                }
            } else {
                AudioManager.shared.play(.wrong)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    cards[first].isFaceUp = false
                    cards[second].isFaceUp = false
                    faceUpIndices = []
                }
            }
        }
    }
}
