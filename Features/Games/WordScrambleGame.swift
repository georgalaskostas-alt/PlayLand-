import SwiftUI

struct WordScrambleGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    @State private var words: [ScrambleWord] = []
    @State private var currentIndex = 0
    @State private var scrambledLetters: [Character] = []
    @State private var placedIndices: [Int] = []
    @State private var score = 0
    @State private var isFinished = false
    @State private var showWrong = false

    private var currentWord: ScrambleWord? {
        words.indices.contains(currentIndex) ? words[currentIndex] : nil
    }

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                GameHeader(title: Loc.t("game.wordScramble.title"), subtitle: Loc.t("game.wordScramble.instruction"))

                if let currentWord {
                    HStack(spacing: 10) {
                        Text(currentWord.emoji)
                            .font(.system(size: 70))
                        SpeakerButton(text: currentWord.answer)
                    }

                    HStack(spacing: 8) {
                        ForEach(0..<currentWord.answer.count, id: \.self) { slot in
                            Text(slot < placedIndices.count ? String(scrambledLetters[placedIndices[slot]]) : "_")
                                .font(.title.weight(.bold))
                                .frame(width: 40, height: 50)
                                .background(showWrong ? Color.red.opacity(0.3) : PlayLandColors.leafGreen.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusSmall))
                        }
                    }

                    HStack(spacing: 10) {
                        ForEach(Array(scrambledLetters.enumerated()), id: \.offset) { index, letter in
                            Button(action: { placeLetter(at: index) }) {
                                Text(String(letter))
                                    .font(.title.weight(.bold))
                                    .frame(width: 44, height: 54)
                                    .background(PlayLandColors.sunOrange.opacity(0.25))
                                    .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusSmall))
                            }
                            .disabled(placedIndices.contains(index))
                        }
                    }

                    PlayLandSecondaryButton(title: Loc.t("action.clear")) { placedIndices = [] }
                }

                Spacer()
            }
            .padding()
            .onAppear(perform: setupIfNeeded)
            .onChange(of: placedIndices) { newValue in
                guard let currentWord else { return }
                if newValue.count == currentWord.answer.count {
                    checkAnswer()
                }
            }

            if isFinished {
                CompletionCelebrationView(
                    title: Loc.t("game.wordScramble.completeTitle"),
                    message: Loc.t("game.wordScramble.completeMessage", score, words.count),
                    stars: score,
                    buttonTitle: Loc.t("action.continue"),
                    action: {
                        progressManager.completeGame("word_scramble", stars: score)
                        dismiss()
                    }
                )
            }
        }
    }

    private func placeLetter(at index: Int) {
        guard let currentWord else { return }
        guard !placedIndices.contains(index), placedIndices.count < currentWord.answer.count else { return }
        placedIndices.append(index)
    }

    private func checkAnswer() {
        guard let currentWord else { return }
        let built = String(placedIndices.map { scrambledLetters[$0] })
        if built == currentWord.answer {
            score += 1
            AudioManager.shared.play(.correct)
            advance()
        } else {
            showWrong = true
            AudioManager.shared.play(.wrong)
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

    private func setupIfNeeded() {
        if words.isEmpty {
            words = LearningContentProvider.scrambleWords(for: appSettings.resolvedLanguage)
        }
        setupWord(index: currentIndex)
    }

    private func setupWord(index: Int) {
        guard words.indices.contains(index) else { return }
        currentIndex = index
        scrambledLetters = Array(words[index].answer).shuffled()
        placedIndices = []
        showWrong = false
    }
}
