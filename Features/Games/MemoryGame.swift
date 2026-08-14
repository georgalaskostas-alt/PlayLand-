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

    var onChallengeComplete: ((Int) -> Void)?

    private let symbolPool = ["🦖", "🦕", "🥚", "🌿", "🍃", "🦴", "🍎", "💧", "🪵", "💎", "🦊", "🐦"]
    private let totalLevels = 5

    @State private var level = 1
    @State private var cards: [MemoryCard] = []
    @State private var faceUpIndices: [Int] = []
    @State private var moves = 0
    @State private var totalMoves = 0
    @State private var showLevelComplete = false
    @State private var showGameComplete = false

    private var pairCount: Int { min(3 + level, 8) }

    private var levelStars: Int {
        let ideal = pairCount
        if moves <= ideal + 2 { return 3 }
        if moves <= ideal + 6 { return 2 }
        return 1
    }

    private var overallStars: Int {
        if totalMoves <= 45 { return 3 }
        if totalMoves <= 65 { return 2 }
        return 1
    }

    private var levelLabel: String {
        appSettings.resolvedLanguage == .greek ? "Επίπεδο \(level) από \(totalLevels)" : "Level \(level) of \(totalLevels)"
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    GameHeader(title: Loc.t("game.memoryGame.title"), subtitle: Loc.t("game.memoryGame.instruction"))

                    HStack {
                        Text(levelLabel)
                            .font(PlayLandTypography.heading)
                            .foregroundColor(PlayLandColors.sunOrange)
                        Spacer()
                        Text(appSettings.resolvedLanguage == .greek ? "Κινήσεις: \(moves)" : "Moves: \(moves)")
                            .font(PlayLandTypography.caption)
                            .foregroundColor(PlayLandColors.secondaryText)
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 10), count: level >= 4 ? 4 : 3), spacing: 10) {
                        ForEach(cards) { card in
                            Button(action: { flip(card) }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusSmall)
                                        .fill(card.isMatched ? PlayLandColors.leafGreen.opacity(0.25) : PlayLandColors.skyBlue.opacity(0.15))

                                    Text(card.isFaceUp || card.isMatched ? card.symbol : "❔")
                                        .font(.system(size: 30))
                                }
                                .frame(height: 72)
                            }
                            .disabled(card.isFaceUp || card.isMatched || faceUpIndices.count >= 2)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .onAppear(perform: setupCards)

            if showLevelComplete {
                CompletionCelebrationView(
                    title: appSettings.resolvedLanguage == .greek ? "Επίπεδο ολοκληρώθηκε!" : "Level complete!",
                    message: appSettings.resolvedLanguage == .greek ? "Βρήκες όλα τα ζευγάρια. Η επόμενη πίστα είναι δυσκολότερη!" : "You found every pair. The next level is harder!",
                    stars: levelStars,
                    buttonTitle: Loc.t("action.continue"),
                    action: nextLevel
                )
            }

            if showGameComplete {
                CompletionCelebrationView(
                    title: Loc.t("game.memoryGame.completeTitle"),
                    message: appSettings.resolvedLanguage == .greek ? "Ολοκλήρωσες και τα \(totalLevels) επίπεδα μνήμης!" : "You completed all \(totalLevels) memory levels!",
                    stars: overallStars,
                    buttonTitle: Loc.t("action.continue"),
                    action: finishGame
                )
            }
        }
    }

    private func setupCards() {
        let selectedSymbols = Array(symbolPool.prefix(pairCount))
        let deck = (selectedSymbols + selectedSymbols).shuffled()
        cards = deck.enumerated().map { MemoryCard(id: $0.offset, symbol: $0.element) }
        faceUpIndices = []
        moves = 0
        showLevelComplete = false
    }

    private func flip(_ card: MemoryCard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        guard faceUpIndices.count < 2 else { return }

        cards[index].isFaceUp = true
        faceUpIndices.append(index)

        if faceUpIndices.count == 2 {
            moves += 1
            totalMoves += 1
            let first = faceUpIndices[0]
            let second = faceUpIndices[1]

            if cards[first].symbol == cards[second].symbol {
                cards[first].isMatched = true
                cards[second].isMatched = true
                faceUpIndices = []
                AudioManager.shared.play(.correct)
                if cards.allSatisfy({ $0.isMatched }) {
                    withAnimation {
                        if level >= totalLevels {
                            showGameComplete = true
                        } else {
                            showLevelComplete = true
                        }
                    }
                }
            } else {
                AudioManager.shared.play(.wrong)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    guard cards.indices.contains(first), cards.indices.contains(second) else { return }
                    cards[first].isFaceUp = false
                    cards[second].isFaceUp = false
                    faceUpIndices = []
                }
            }
        }
    }

    private func nextLevel() {
        level += 1
        setupCards()
    }

    private func finishGame() {
        progressManager.completeGame("memory_game", stars: overallStars)
        if let onChallengeComplete {
            onChallengeComplete(overallStars)
        } else {
            dismiss()
        }
    }
}
