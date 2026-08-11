import SwiftUI

struct LetterRecognitionGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    /// See `MemoryGame.onChallengeComplete`.
    var onChallengeComplete: ((Int) -> Void)?

    @State private var questions: [LetterQuestion] = []
    @State private var currentQuestion = 0
    @State private var score = 0

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                GameHeader(
                    title: Loc.t("game.letterRecognition.title"),
                    subtitle: Loc.t("game.letterRecognition.instruction")
                )

                if !questions.isEmpty {
                    if currentQuestion < questions.count {
                        Text(Loc.t("game.letterRecognition.questionOf", currentQuestion + 1, questions.count))
                            .font(PlayLandTypography.caption)
                            .foregroundColor(PlayLandColors.secondaryText)

                        LetterQuestionView(question: questions[currentQuestion]) { isCorrect in
                            if isCorrect {
                                score += 1
                                AudioManager.shared.play(.correct)
                            } else {
                                AudioManager.shared.play(.wrong)
                            }
                            withAnimation {
                                currentQuestion += 1
                            }
                        }
                        .id(questions[currentQuestion].id)
                    }
                }
                Spacer()
            }
            .padding()
            .onAppear(perform: setupIfNeeded)

            if !questions.isEmpty && currentQuestion >= questions.count {
                CompletionCelebrationView(
                    title: Loc.t("game.letterRecognition.completeTitle"),
                    message: Loc.t("game.letterRecognition.completeMessage", score, questions.count),
                    stars: stars,
                    buttonTitle: Loc.t("action.continue"),
                    action: {
                        progressManager.completeGame("letter_recognition", stars: stars)
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
        if score >= questions.count { return 3 }
        if score >= (questions.count + 1) / 2 { return 2 }
        return 1
    }

    private func setupIfNeeded() {
        guard questions.isEmpty else { return }
        questions = LearningContentProvider.letterQuestions(for: appSettings.resolvedLanguage)
    }
}

struct LetterQuestionView: View {
    let question: LetterQuestion
    let onAnswer: (Bool) -> Void
    @State private var selected: Int?

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

            VStack(spacing: 12) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    Button(action: {
                        guard selected == nil else { return }
                        selected = index
                        onAnswer(index == question.correct)
                    }) {
                        Text(option)
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .frame(minHeight: PlayLandMetrics.minTouchTarget)
                            .background(selected == index ? PlayLandColors.leafGreen : PlayLandColors.skyBlue.opacity(0.15))
                            .foregroundColor(selected == index ? .white : PlayLandColors.skyBlue)
                            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
                    }
                    .disabled(selected != nil)
                    .accessibilityHint(Text(Loc.t("game.letterRecognition.instruction")))
                }
            }
        }
        .padding()
        .onAppear {
            SpeechManager.shared.speak(text: Loc.t("game.letterRecognition.spokenPrompt", question.letter))
        }
    }
}
