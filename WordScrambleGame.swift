import SwiftUI

private struct ScrambleWord {
    let answer: String
    let emoji: String
}

struct WordScrambleGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @Environment(\.dismiss) var dismiss

    private let words = [
        ScrambleWord(answer: "APPLE", emoji: "🍎"),
        ScrambleWord(answer: "BIRD", emoji: "🐦"),
        ScrambleWord(answer: "FOX", emoji: "🦊")
    ]

    @State private var currentIndex = 0
    @State private var scrambledLetters: [Character] = []
    @State private var placedIndices: [Int] = []
    @State private var score = 0
    @State private var isFinished = false
    @State private var showWrong = false

    private var currentWord: ScrambleWord { words[currentIndex] }

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                Text("Word Scramble")
                    .font(.largeTitle.bold())

                Text("Tap the letters in the right order!")
                    .font(.headline)
                    .foregroundColor(.secondary)

                if currentIndex < words.count {
                    Text(currentWord.emoji)
                        .font(.system(size: 70))

                    HStack(spacing: 8) {
                        ForEach(0..<currentWord.answer.count, id: \.self) { slot in
                            Text(slot < placedIndices.count ? String(scrambledLetters[placedIndices[slot]]) : "_")
                                .font(.title.weight(.bold))
                                .frame(width: 40, height: 50)
                                .background(showWrong ? Color.red.opacity(0.3) : PlayLandTheme.leafGreen.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }

                    HStack(spacing: 10) {
                        ForEach(Array(scrambledLetters.enumerated()), id: \.offset) { index, letter in
                            Button(action: { placeLetter(at: index) }) {
                                Text(String(letter))
                                    .font(.title.weight(.bold))
                                    .frame(width: 44, height: 54)
                                    .background(PlayLandTheme.sunOrange.opacity(0.25))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .disabled(placedIndices.contains(index))
                        }
                    }

                    Button("Clear") { placedIndices = [] }
                        .buttonStyle(PlayfulButtonStyle(color: .gray))
                }

                Spacer()
            }
            .padding()
            .onAppear { setupWord(index: 0) }
            .onChange(of: placedIndices) { newValue in
                if newValue.count == currentWord.answer.count {
                    checkAnswer()
                }
            }

            if isFinished {
                CompletionBadgeView(
                    title: "Unscrambled!",
                    message: "You solved \(score) out of \(words.count) words.",
                    stars: score,
                    buttonTitle: "Continue",
                    action: {
                        progressManager.completeGame("word_scramble", stars: score)
                        dismiss()
                    }
                )
            }
        }
    }

    private func placeLetter(at index: Int) {
        guard !placedIndices.contains(index), placedIndices.count < currentWord.answer.count else { return }
        placedIndices.append(index)
    }

    private func checkAnswer() {
        let built = String(placedIndices.map { scrambledLetters[$0] })
        if built == currentWord.answer {
            score += 1
            advance()
        } else {
            showWrong = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showWrong = false
                placedIndices = []
            }
        }
    }

    private func advance() {
        let nextIndex = currentIndex + 1
        if nextIndex >= words.count {
            withAnimation { isFinished = true }
        } else {
            setupWord(index: nextIndex)
        }
    }

    private func setupWord(index: Int) {
        currentIndex = index
        scrambledLetters = Array(words[index].answer).shuffled()
        placedIndices = []
        showWrong = false
    }
}
