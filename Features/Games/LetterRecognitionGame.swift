import SwiftUI

struct LetterRecognitionGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    var onChallengeComplete: ((Int) -> Void)?

    @State private var allQuestions: [LetterQuestion] = []
    @State private var levelIndex = 0
    @State private var currentQuestion = 0
    @State private var levelWrongAttempts = 0
    @State private var totalWrongAttempts = 0
    @State private var showLevelComplete = false
    @State private var showGameComplete = false

    private let totalLevels = 6

    private var levelQuestions: [LetterQuestion] {
        guard !allQuestions.isEmpty else { return [] }
        let chunkSize = Int(ceil(Double(allQuestions.count) / Double(totalLevels)))
        let start = min(levelIndex * chunkSize, allQuestions.count)
        let end = min(start + chunkSize, allQuestions.count)
        guard start < end else { return [] }
        return Array(allQuestions[start..<end])
    }

    private var levelStars: Int {
        if levelWrongAttempts == 0 { return 3 }
        if levelWrongAttempts <= 2 { return 2 }
        return 1
    }

    private var overallStars: Int {
        if totalWrongAttempts <= 2 { return 3 }
        if totalWrongAttempts <= 6 { return 2 }
        return 1
    }

    private var levelLabel: String {
        appSettings.resolvedLanguage == .greek
            ? "Επίπεδο \(levelIndex + 1) από \(totalLevels)"
            : "Level \(levelIndex + 1) of \(totalLevels)"
    }

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                GameHeader(
                    title: Loc.t("game.letterRecognition.title"),
                    subtitle: Loc.t("game.letterRecognition.instruction")
                )

                if !allQuestions.isEmpty && !levelQuestions.isEmpty {
                    HStack {
                        Text(levelLabel)
                            .font(PlayLandTypography.heading)
                            .foregroundColor(PlayLandColors.sunOrange)

                        Spacer()

                        Text(Loc.t("game.letterRecognition.questionOf", min(currentQuestion + 1, levelQuestions.count), levelQuestions.count))
                            .font(PlayLandTypography.caption)
                            .foregroundColor(PlayLandColors.secondaryText)
                    }

                    ProgressView(value: Double(levelIndex * 100 + Int((Double(currentQuestion) / Double(max(levelQuestions.count, 1))) * 100)), total: Double(totalLevels * 100))
                        .tint(PlayLandColors.leafGreen)

                    if currentQuestion < levelQuestions.count {
                        LetterQuestionView(question: levelQuestions[currentQuestion]) { isCorrect in
                            handleAnswer(isCorrect)
                        }
                        .id(levelQuestions[currentQuestion].id)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding()
            .onAppear(perform: setupIfNeeded)

            if showLevelComplete {
                CompletionCelebrationView(
                    title: appSettings.resolvedLanguage == .greek ? "Μπράβο! Επίπεδο ολοκληρώθηκε" : "Great job! Level complete",
                    message: appSettings.resolvedLanguage == .greek
                        ? "Προχωράμε στο επόμενο επίπεδο με νέα γράμματα."
                        : "Next level brings new letters.",
                    stars: levelStars,
                    buttonTitle: Loc.t("action.continue"),
                    action: advanceLevel
                )
            }

            if showGameComplete {
                CompletionCelebrationView(
                    title: Loc.t("game.letterRecognition.completeTitle"),
                    message: appSettings.resolvedLanguage == .greek
                        ? "Ολοκλήρωσες και τα \(totalLevels) επίπεδα της αναγνώρισης γραμμάτων!"
                        : "You completed all \(totalLevels) letter-recognition levels!",
                    stars: overallStars,
                    buttonTitle: Loc.t("action.continue"),
                    action: finishGame
                )
            }
        }
    }

    private func setupIfNeeded() {
        guard allQuestions.isEmpty else { return }
        allQuestions = LearningContentProvider.letterQuestions(for: appSettings.resolvedLanguage)
    }

    private func handleAnswer(_ isCorrect: Bool) {
        if isCorrect {
            AudioManager.shared.play(.correct)
            if currentQuestion + 1 >= levelQuestions.count {
                if levelIndex + 1 >= totalLevels || (levelIndex + 1) * Int(ceil(Double(allQuestions.count) / Double(totalLevels))) >= allQuestions.count {
                    showGameComplete = true
                } else {
                    showLevelComplete = true
                }
            } else {
                withAnimation {
                    currentQuestion += 1
                }
            }
        } else {
            levelWrongAttempts += 1
            totalWrongAttempts += 1
            AudioManager.shared.play(.wrong)
            // Deliberately stay on the same question. A wrong letter must never
            // be accepted as progress; the child gets feedback and tries again.
        }
    }

    private func advanceLevel() {
        showLevelComplete = false
        levelIndex += 1
        currentQuestion = 0
        levelWrongAttempts = 0
    }

    private func finishGame() {
        progressManager.completeGame("letter_recognition", stars: overallStars)
        if let onChallengeComplete {
            onChallengeComplete(overallStars)
        } else {
            dismiss()
        }
    }
}

struct LetterQuestionView: View {
    let question: LetterQuestion
    let onAnswer: (Bool) -> Void

    @EnvironmentObject var appSettings: AppSettings
    @State private var selected: Int?
    @State private var feedback: String?
    @State private var locked = false

    var body: some View {
        VStack(spacing: 18) {
            Text(question.letter)
                .font(.system(size: 90, weight: .heavy, design: .rounded))
                .foregroundColor(PlayLandColors.sunOrange)

            HStack(spacing: 10) {
                Text(Loc.t("game.letterRecognition.instruction"))
                    .font(PlayLandTypography.heading)
                SpeakerButton(text: Loc.t("game.letterRecognition.spokenPrompt", question.letter))
            }

            if let feedback {
                Text(feedback)
                    .font(PlayLandTypography.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(selected == question.correct ? PlayLandColors.leafGreen : .red)
                    .transition(.opacity)
            }

            VStack(spacing: 12) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    Button(action: { choose(index) }) {
                        Text(option)
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .frame(minHeight: PlayLandMetrics.minTouchTarget)
                            .background(buttonBackground(for: index))
                            .foregroundColor(buttonForeground(for: index))
                            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
                    }
                    .disabled(locked)
                    .accessibilityHint(Text(Loc.t("game.letterRecognition.instruction")))
                }
            }
        }
        .padding()
        .onAppear {
            SpeechManager.shared.speak(text: Loc.t("game.letterRecognition.spokenPrompt", question.letter))
        }
    }

    private func choose(_ index: Int) {
        guard !locked else { return }
        selected = index
        let isCorrect = index == question.correct

        if isCorrect {
            locked = true
            feedback = appSettings.resolvedLanguage == .greek ? "Σωστά! Μπράβο!" : "Correct! Great job!"
            SpeechManager.shared.speak(text: feedback ?? "")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                onAnswer(true)
            }
        } else {
            locked = true
            feedback = appSettings.resolvedLanguage == .greek
                ? "Όχι ακόμα. Κοίτα ποια λέξη αρχίζει από το γράμμα \(question.letter) και προσπάθησε ξανά."
                : "Not yet. Find the word that starts with \(question.letter) and try again."
            SpeechManager.shared.speak(text: feedback ?? "")
            onAnswer(false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
                withAnimation {
                    selected = nil
                    feedback = nil
                    locked = false
                }
            }
        }
    }

    private func buttonBackground(for index: Int) -> Color {
        guard selected == index else { return PlayLandColors.skyBlue.opacity(0.15) }
        return index == question.correct ? PlayLandColors.leafGreen : .red.opacity(0.85)
    }

    private func buttonForeground(for index: Int) -> Color {
        selected == index ? .white : PlayLandColors.skyBlue
    }
}
