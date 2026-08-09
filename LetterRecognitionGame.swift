import SwiftUI

struct LetterRecognitionGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @Environment(\.dismiss) var dismiss

    @State private var currentQuestion = 0
    @State private var score = 0

    let questions = [
        LetterQuestion(letter: "A", options: ["Apple", "Ball", "Cat"], correct: 0),
        LetterQuestion(letter: "B", options: ["Dog", "Ball", "Elephant"], correct: 1),
        LetterQuestion(letter: "C", options: ["Apple", "Cat", "Fish"], correct: 1),
        LetterQuestion(letter: "D", options: ["Dog", "Goat", "Hen"], correct: 0),
        LetterQuestion(letter: "F", options: ["Ant", "Fish", "Owl"], correct: 1)
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                Text("Letter Recognition")
                    .font(.largeTitle.bold())

                if currentQuestion < questions.count {
                    Text("Question \(currentQuestion + 1) of \(questions.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    LetterQuestionView(question: questions[currentQuestion]) { isCorrect in
                        if isCorrect { score += 1 }
                        withAnimation {
                            currentQuestion += 1
                        }
                    }
                    .id(questions[currentQuestion].id)
                }
                Spacer()
            }
            .padding()

            if currentQuestion >= questions.count {
                CompletionBadgeView(
                    title: "Great Job!",
                    message: "You got \(score) out of \(questions.count) correct.",
                    stars: stars,
                    buttonTitle: "Continue",
                    action: {
                        progressManager.completeGame("letter_recognition", stars: stars)
                        dismiss()
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
}

struct LetterQuestion: Identifiable {
    let id = UUID()
    let letter: String
    let options: [String]
    let correct: Int
}

struct LetterQuestionView: View {
    let question: LetterQuestion
    let onAnswer: (Bool) -> Void
    @State private var selected: Int?

    var body: some View {
        VStack(spacing: 18) {
            Text(question.letter)
                .font(.system(size: 90, weight: .heavy, design: .rounded))
                .foregroundColor(PlayLandTheme.sunOrange)

            Text("Which word starts with this letter?")
                .font(.headline)

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
                            .background(selected == index ? PlayLandTheme.leafGreen : PlayLandTheme.skyBlue.opacity(0.15))
                            .foregroundColor(selected == index ? .white : PlayLandTheme.skyBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(selected != nil)
                }
            }
        }
        .padding()
    }
}
