import SwiftUI

struct LetterRecognitionGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var currentQuestion = 0
    @State private var score = 0
    
    let questions = [
        Question(letter: "A", options: ["Apple", "Ball", "Cat"], correct: 0),
        Question(letter: "B", options: ["Dog", "Ball", "Elephant"], correct: 1),
        Question(letter: "C", options: ["Apple", "Cat", "Fish"], correct: 1)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Letter Recognition").font(.title).fontWeight(.bold)
            
            if currentQuestion < questions.count {
                QuestionView(question: questions[currentQuestion]) { isCorrect in
                    if isCorrect { score += 1 }
                    currentQuestion += 1
                }
            } else {
                ResultView(score: score, total: questions.count) {
                    progressManager.completeGame("letter_recognition", stars: score)
                    dismiss()
                }
            }
            Spacer()
        }.padding()
    }
}

struct Question: Identifiable {
    let id = UUID()
    let letter: String
    let options: [String]
    let correct: Int
}

struct QuestionView: View {
    let question: Question
    let onAnswer: (Bool) -> Void
    @State private var selected: Int?
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Which starts with \(question.letter)?").font(.headline)
            
            ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                Button(action: {
                    selected = index
                    onAnswer(index == question.correct)
                }) {
                    Text(option).font(.title2).padding()
                        .frame(maxWidth: .infinity)
                        .background(selected == index ? Color.green : Color.blue.opacity(0.2))
                        .foregroundColor(selected == index ? .white : .blue)
                        .cornerRadius(15)
                }
            }
        }.padding()
    }
}

struct ResultView: View {
    let score: Int
    let total: Int
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎉 Great!").font(.largeTitle)
            Text("Score: \(score)/\(total)").font(.title2)
            Button(action: onContinue) {
                Text("Continue").font(.headline).foregroundColor(.white)
                    .padding(.horizontal, 40).padding(.vertical, 15)
                    .background(Color.green).cornerRadius(25)
            }
        }.padding()
    }
}
