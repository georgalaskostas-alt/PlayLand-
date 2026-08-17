import SwiftUI

private struct MatchCard: Identifiable {
    let id: Int
    let imageName: String
    var isFaceUp = false
    var isMatched = false
}

struct DinoMatchGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    private let imagePool = [
        AppAssets.Characters.babis,
        AppAssets.Characters.kotsifi,
        AppAssets.Characters.fox,
        "babis_happy",
        "babis_hungry",
        "kotsifi_happy",
        "kotsifi_surprised",
        "fox_friendly"
    ]
    private let totalLevels = 6

    @State private var level = 1
    @State private var cards: [MatchCard] = []
    @State private var faceUpIndices: [Int] = []
    @State private var moves = 0
    @State private var totalMoves = 0
    @State private var showLevelComplete = false
    @State private var isFinished = false

    // Starts at 4 pairs / 8 cards and grows to all 8 pairs / 16 cards.
    private var pairCount: Int { min(imagePool.count, 3 + level) }
    private var columns: Int { pairCount <= 4 ? 3 : 4 }
    private var cardHeight: CGFloat { pairCount >= 7 ? 76 : (columns == 3 ? 96 : 84) }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    GameHeader(title: Loc.t("dino.match.title"), subtitle: Loc.t("dino.match.instruction"))
                    Text(levelLabel)
                        .font(PlayLandTypography.heading)
                        .foregroundColor(PlayLandColors.sunOrange)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columns), spacing: 8) {
                        ForEach(cards) { card in
                            Button(action: { flip(card) }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium)
                                        .fill(card.isMatched ? PlayLandColors.leafGreen.opacity(0.2) : PlayLandColors.skyBlue.opacity(0.15))
                                    if card.isFaceUp || card.isMatched {
                                        AppAssets.image(card.imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .padding(6)
                                    } else {
                                        Text("❓").font(.system(size: 28))
                                    }
                                }
                                .frame(height: cardHeight)
                            }
                            .disabled(card.isFaceUp || card.isMatched || faceUpIndices.count >= 2)
                        }
                    }
                    .padding(.horizontal, 6)

                    Text(isGreek ? "Κινήσεις: \(moves)" : "Moves: \(moves)")
                        .font(PlayLandTypography.body)
                }
                .padding()
            }
            .onAppear(perform: setupLevel)

            if showLevelComplete {
                CompletionCelebrationView(
                    title: levelCompleteTitle,
                    message: levelCompleteMessage,
                    stars: levelStars,
                    buttonTitle: level < totalLevels ? nextLevelTitle : Loc.t("action.continue"),
                    action: advanceLevel
                )
            }

            if isFinished {
                CompletionCelebrationView(
                    title: Loc.t("dino.match.completeTitle"),
                    message: finalMessage,
                    stars: finalStars,
                    buttonTitle: Loc.t("dino.match.completeButton"),
                    action: {
                        progressManager.completeGame("dino_match", stars: finalStars)
                        dismiss()
                    }
                )
            }
        }
    }

    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }
    private var levelLabel: String { isGreek ? "Επίπεδο \(level) από \(totalLevels) — \(pairCount) ζευγάρια" : "Level \(level) of \(totalLevels) — \(pairCount) pairs" }
    private var levelCompleteTitle: String { isGreek ? "Τα βρήκες όλα!" : "All pairs found!" }
    private var levelCompleteMessage: String { isGreek ? "Στην επόμενη πίστα υπάρχουν περισσότερες κάρτες." : "The next board has more cards." }
    private var nextLevelTitle: String { isGreek ? "Επόμενη πίστα" : "Next level" }
    private var finalMessage: String { isGreek ? "Ολοκλήρωσες και τα \(totalLevels) επίπεδα μνήμης." : "You completed all \(totalLevels) memory levels." }
    private var levelStars: Int { moves <= pairCount + 3 ? 3 : (moves <= pairCount * 2 + 2 ? 2 : 1) }
    private var finalStars: Int { totalMoves <= 70 ? 3 : (totalMoves <= 100 ? 2 : 1) }

    private func setupLevel() {
        let chosen = Array(imagePool.shuffled().prefix(pairCount))
        let deck = (chosen + chosen).shuffled()
        cards = deck.enumerated().map { MatchCard(id: $0.offset, imageName: $0.element) }
        faceUpIndices = []
        moves = 0
        showLevelComplete = false
    }

    private func flip(_ card: MatchCard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        guard faceUpIndices.count < 2 else { return }
        cards[index].isFaceUp = true
        faceUpIndices.append(index)

        if faceUpIndices.count == 2 {
            moves += 1
            totalMoves += 1
            let first = faceUpIndices[0]
            let second = faceUpIndices[1]
            if cards[first].imageName == cards[second].imageName {
                cards[first].isMatched = true
                cards[second].isMatched = true
                faceUpIndices = []
                AudioManager.shared.play(.correct)
                if cards.allSatisfy({ $0.isMatched }) { withAnimation { showLevelComplete = true } }
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

    private func advanceLevel() {
        if level >= totalLevels {
            showLevelComplete = false
            isFinished = true
        } else {
            level += 1
            setupLevel()
        }
    }
}
