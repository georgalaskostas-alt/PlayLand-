import SwiftUI

private struct WordPair {
    let emoji: String
    let word: String
}

struct WordMatchingGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @Environment(\.dismiss) var dismiss

    private let pairs = [
        WordPair(emoji: "🦖", word: "DINO"),
        WordPair(emoji: "🐦", word: "BIRD"),
        WordPair(emoji: "🦊", word: "FOX"),
        WordPair(emoji: "🌳", word: "TREE")
    ]

    @State private var words: [String] = []
    @State private var selectedEmoji: String?
    @State private var selectedWord: String?
    @State private var matched: Set<String> = []
    @State private var mistakes = 0
    @State private var isFinished = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Word Matching")
                    .font(.largeTitle.bold())

                Text("Match each picture with its word!")
                    .font(.headline)
                    .foregroundColor(.secondary)

                HStack(alignment: .top, spacing: 30) {
                    VStack(spacing: 14) {
                        ForEach(pairs, id: \.emoji) { pair in
                            tile(text: pair.emoji, isSelected: selectedEmoji == pair.emoji, isMatched: matched.contains(pair.emoji)) {
                                selectedEmoji = pair.emoji
                                tryMatch()
                            }
                        }
                    }

                    VStack(spacing: 14) {
                        ForEach(words, id: \.self) { word in
                            tile(text: word, isSelected: selectedWord == word, isMatched: matched.contains(word)) {
                                selectedWord = word
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
                CompletionBadgeView(
                    title: "Perfect Matching!",
                    message: "You matched everything with \(mistakes) mistakes.",
                    stars: stars,
                    buttonTitle: "Continue",
                    action: {
                        progressManager.completeGame("word_matching", stars: stars)
                        dismiss()
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
                .background(isMatched ? PlayLandTheme.leafGreen.opacity(0.3) : (isSelected ? PlayLandTheme.sunOrange.opacity(0.3) : PlayLandTheme.skyBlue.opacity(0.12)))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isMatched)
    }

    private func tryMatch() {
        guard let emoji = selectedEmoji, let word = selectedWord else { return }
        if let pair = pairs.first(where: { $0.emoji == emoji }), pair.word == word {
            matched.insert(emoji)
            matched.insert(word)
        } else {
            mistakes += 1
        }
        selectedEmoji = nil
        selectedWord = nil

        if matched.count == pairs.count * 2 {
            withAnimation { isFinished = true }
        }
    }
}
