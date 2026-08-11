import SwiftUI

struct WordMatchingGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    /// See `MemoryGame.onChallengeComplete`.
    var onChallengeComplete: ((Int) -> Void)?

    @State private var pairs: [MatchWordPair] = []
    @State private var words: [String] = []
    @State private var selectedEmoji: String?
    @State private var selectedWord: String?
    @State private var matched: Set<String> = []
    @State private var mistakes = 0
    @State private var isFinished = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                GameHeader(title: Loc.t("game.wordMatching.title"), subtitle: Loc.t("game.wordMatching.instruction"))

                HStack(alignment: .top, spacing: 30) {
                    VStack(spacing: 14) {
                        ForEach(pairs, id: \.emoji) { pair in
                            tile(text: pair.emoji, isSelected: selectedEmoji == pair.emoji, isMatched: matched.contains(pair.emoji)) {
                                selectedEmoji = pair.emoji
                                SpeechManager.shared.speak(text: pair.word)
                                tryMatch()
                            }
                        }
                    }

                    VStack(spacing: 14) {
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

                Spacer()
            }
            .padding()
            .onAppear(perform: setup)

            if isFinished {
                CompletionCelebrationView(
                    title: Loc.t("game.wordMatching.completeTitle"),
                    message: Loc.t("game.wordMatching.completeMessage", mistakes),
                    stars: stars,
                    buttonTitle: Loc.t("action.continue"),
                    action: {
                        progressManager.completeGame("word_matching", stars: stars)
                        if let onChallengeComplete {
                            onChallengeComplete(stars)
                        } else {
                            dismiss()
                        }
                    }
                )
            }
        }
    }

    private var stars: Int {
        if mistakes == 0 { return 3 }
        if mistakes <= 2 { return 2 }
        return 1
    }

    private func setup() {
        pairs = LearningContentProvider.matchWordPairs(for: appSettings.resolvedLanguage)
        words = pairs.map { $0.word }.shuffled()
        matched = []
        selectedEmoji = nil
        selectedWord = nil
        mistakes = 0
        isFinished = false
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
            AudioManager.shared.play(.wrong)
        }
        selectedEmoji = nil
        selectedWord = nil

        if matched.count == pairs.count * 2 {
            withAnimation { isFinished = true }
        }
    }
}
