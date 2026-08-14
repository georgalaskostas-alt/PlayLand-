import SwiftUI

struct WordMatchingGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    var onChallengeComplete: ((Int) -> Void)?

    @State private var level = 1
    @State private var pairs: [MatchWordPair] = []
    @State private var words: [String] = []
    @State private var selectedEmoji: String?
    @State private var selectedWord: String?
    @State private var matched: Set<String> = []
    @State private var mistakes = 0
    @State private var totalMistakes = 0
    @State private var showLevelComplete = false
    @State private var isFinished = false

    private let totalLevels = 5

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    GameHeader(title: Loc.t("game.wordMatching.title"), subtitle: Loc.t("game.wordMatching.instruction"))
                    Text(levelLabel)
                        .font(PlayLandTypography.heading)
                        .foregroundColor(PlayLandColors.sunOrange)

                    HStack(alignment: .top, spacing: 24) {
                        VStack(spacing: 12) {
                            ForEach(pairs, id: \.emoji) { pair in
                                tile(text: pair.emoji, isSelected: selectedEmoji == pair.emoji, isMatched: matched.contains(pair.emoji)) {
                                    selectedEmoji = pair.emoji
                                    SpeechManager.shared.speak(text: pair.word)
                                    tryMatch()
                                }
                            }
                        }
                        VStack(spacing: 12) {
                            ForEach(words, id: \.self) { word in
                                tile(text: word, isSelected: selectedWord == word, isMatched: matched.contains(word)) {
                                    selectedWord = word
                                    SpeechManager.shared.speak(text: word)
                                    tryMatch()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .onAppear(perform: setupLevel)

            if showLevelComplete {
                CompletionCelebrationView(
                    title: levelCompleteTitle,
                    message: levelCompleteMessage,
                    stars: levelStars,
                    buttonTitle: level < totalLevels ? continueTitle : Loc.t("action.continue"),
                    action: advanceLevel
                )
            }

            if isFinished {
                CompletionCelebrationView(
                    title: Loc.t("game.wordMatching.completeTitle"),
                    message: Loc.t("game.wordMatching.completeMessage", totalMistakes),
                    stars: finalStars,
                    buttonTitle: Loc.t("action.continue"),
                    action: finishGame
                )
            }
        }
    }

    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }
    private var levelLabel: String { isGreek ? "Επίπεδο \(level) από \(totalLevels)" : "Level \(level) of \(totalLevels)" }
    private var levelCompleteTitle: String { isGreek ? "Επίπεδο ολοκληρώθηκε!" : "Level complete!" }
    private var levelCompleteMessage: String { isGreek ? "Συνέχισε στο επόμενο επίπεδο." : "Keep going to the next level." }
    private var continueTitle: String { isGreek ? "Επόμενο επίπεδο" : "Next level" }

    private var levelStars: Int {
        if mistakes == 0 { return 3 }
        if mistakes <= 2 { return 2 }
        return 1
    }

    private var finalStars: Int {
        if totalMistakes <= 2 { return 3 }
        if totalMistakes <= 6 { return 2 }
        return 1
    }

    private func setupLevel() {
        let all = LearningContentProvider.matchWordPairs(for: appSettings.resolvedLanguage)
        let desiredCount = min(all.count, max(2, 2 + level))
        pairs = Array(all.shuffled().prefix(desiredCount))
        words = pairs.map(\.word).shuffled()
        matched = []
        selectedEmoji = nil
        selectedWord = nil
        mistakes = 0
        showLevelComplete = false
    }

    private func tile(text: String, isSelected: Bool, isMatched: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.title2.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding()
                .frame(minHeight: PlayLandMetrics.minTouchTarget)
                .background(isMatched ? PlayLandColors.leafGreen.opacity(0.3) : (isSelected ? PlayLandColors.sunOrange.opacity(0.3) : PlayLandColors.skyBlue.opacity(0.12)))
                .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
        }
        .disabled(isMatched)
    }

    private func tryMatch() {
        guard let emoji = selectedEmoji, let word = selectedWord else { return }
        if let pair = pairs.first(where: { $0.emoji == emoji }), pair.word == word {
            matched.insert(emoji)
            matched.insert(word)
            AudioManager.shared.play(.correct)
        } else {
            mistakes += 1
            totalMistakes += 1
            AudioManager.shared.play(.wrong)
        }
        selectedEmoji = nil
        selectedWord = nil

        if matched.count == pairs.count * 2 {
            withAnimation { showLevelComplete = true }
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

    private func finishGame() {
        progressManager.completeGame("word_matching", stars: finalStars)
        if let onChallengeComplete { onChallengeComplete(finalStars) } else { dismiss() }
    }
}
