import SwiftUI

struct WordScrambleGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    var onChallengeComplete: ((Int) -> Void)?

    @State private var words: [ScrambleWord] = []
    @State private var level = 1
    @State private var currentIndex = 0
    @State private var scrambledLetters: [Character] = []
    @State private var placedIndices: [Int] = []
    @State private var correctInLevel = 0
    @State private var mistakes = 0
    @State private var totalMistakes = 0
    @State private var showWrong = false
    @State private var showLevelComplete = false
    @State private var isFinished = false

    private let totalLevels = 6

    private var currentWord: ScrambleWord? {
        words.indices.contains(currentIndex) ? words[currentIndex] : nil
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    GameHeader(title: Loc.t("game.wordScramble.title"), subtitle: Loc.t("game.wordScramble.instruction"))

                    HStack {
                        Text(levelLabel)
                            .font(PlayLandTypography.heading)
                            .foregroundColor(PlayLandColors.sunOrange)
                        Spacer()
                        Text(progressLabel)
                            .font(PlayLandTypography.caption)
                            .foregroundColor(PlayLandColors.secondaryText)
                    }

                    if let currentWord {
                        HStack(spacing: 10) {
                            Text(currentWord.emoji).font(.system(size: 70))
                            SpeakerButton(text: currentWord.answer)
                        }

                        FlowLayout(spacing: 8) {
                            ForEach(0..<currentWord.answer.count, id: \.self) { slot in
                                Text(slot < placedIndices.count ? String(scrambledLetters[placedIndices[slot]]) : "_")
                                    .font(.title2.weight(.bold))
                                    .frame(width: 40, height: 50)
                                    .background(showWrong ? Color.red.opacity(0.3) : PlayLandColors.leafGreen.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusSmall))
                            }
                        }

                        FlowLayout(spacing: 8) {
                            ForEach(Array(scrambledLetters.enumerated()), id: \.offset) { index, letter in
                                Button(action: { placeLetter(at: index) }) {
                                    Text(String(letter))
                                        .font(.title2.weight(.bold))
                                        .frame(width: 44, height: 52)
                                        .background(PlayLandColors.sunOrange.opacity(0.25))
                                        .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusSmall))
                                }
                                .disabled(placedIndices.contains(index))
                            }
                        }

                        PlayLandSecondaryButton(title: Loc.t("action.clear")) { placedIndices = [] }
                    }
                }
                .padding()
            }
            .onAppear(perform: setupLevel)
            .onChange(of: placedIndices) { newValue in
                guard let currentWord else { return }
                if newValue.count == currentWord.answer.count { checkAnswer() }
            }

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
                    title: Loc.t("game.wordScramble.completeTitle"),
                    message: finalMessage,
                    stars: finalStars,
                    buttonTitle: Loc.t("action.continue"),
                    action: finishGame
                )
            }
        }
    }

    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }
    private var levelLabel: String { isGreek ? "Επίπεδο \(level) από \(totalLevels)" : "Level \(level) of \(totalLevels)" }
    private var progressLabel: String { isGreek ? "Λέξη \(min(currentIndex + 1, words.count))/\(words.count)" : "Word \(min(currentIndex + 1, words.count))/\(words.count)" }
    private var levelCompleteTitle: String { isGreek ? "Επίπεδο ολοκληρώθηκε!" : "Level complete!" }
    private var levelCompleteMessage: String { isGreek ? "Μπράβο! Το επόμενο επίπεδο έχει περισσότερες και δυσκολότερες λέξεις." : "Great job! The next level has more and harder words." }
    private var continueTitle: String { isGreek ? "Επόμενο επίπεδο" : "Next level" }
    private var finalMessage: String { isGreek ? "Ολοκλήρωσες όλα τα επίπεδα με \(totalMistakes) λάθη." : "You completed every level with \(totalMistakes) mistakes." }

    // 4, 5, 6, 7, 7, 7 words per level instead of very short rounds.
    private var wordsPerLevel: Int { min(7, 3 + level) }
    private var levelStars: Int { mistakes == 0 ? 3 : (mistakes <= 2 ? 2 : 1) }
    private var finalStars: Int { totalMistakes <= 3 ? 3 : (totalMistakes <= 8 ? 2 : 1) }

    private func placeLetter(at index: Int) {
        guard let currentWord else { return }
        guard !placedIndices.contains(index), placedIndices.count < currentWord.answer.count else { return }
        placedIndices.append(index)
    }

    private func checkAnswer() {
        guard let currentWord else { return }
        let built = String(placedIndices.map { scrambledLetters[$0] })
        if built == currentWord.answer {
            correctInLevel += 1
            AudioManager.shared.play(.correct)
            advanceWord()
        } else {
            mistakes += 1
            totalMistakes += 1
            showWrong = true
            AudioManager.shared.play(.wrong)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showWrong = false
                placedIndices = []
            }
        }
    }

    private func advanceWord() {
        if correctInLevel >= words.count {
            withAnimation { showLevelComplete = true }
            return
        }
        setupWord(index: currentIndex + 1)
    }

    private func setupLevel() {
        let all = LearningContentProvider.scrambleWords(for: appSettings.resolvedLanguage)
        guard !all.isEmpty else { return }
        var pool: [ScrambleWord] = []
        while pool.count < wordsPerLevel {
            pool.append(contentsOf: all.shuffled())
        }
        words = Array(pool.prefix(wordsPerLevel))
        currentIndex = 0
        correctInLevel = 0
        mistakes = 0
        showLevelComplete = false
        setupWord(index: 0)
    }

    private func setupWord(index: Int) {
        guard words.indices.contains(index) else { return }
        currentIndex = index
        scrambledLetters = Array(words[index].answer).shuffled()
        if scrambledLetters == Array(words[index].answer), scrambledLetters.count > 1 { scrambledLetters.swapAt(0, 1) }
        placedIndices = []
        showWrong = false
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
        progressManager.completeGame("word_scramble", stars: finalStars)
        if let onChallengeComplete { onChallengeComplete(finalStars) } else { dismiss() }
    }
}
