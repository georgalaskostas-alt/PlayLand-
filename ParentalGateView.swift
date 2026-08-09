import SwiftUI

struct ParentalGateView: View {
    @State private var mathQuestion = ""
    @State private var correctAnswer = 0
    @State private var userAnswer = ""
    @State private var isUnlocked = false
    @EnvironmentObject var progressManager: ProgressViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                if isUnlocked {
                    ParentSettingsView(progressManager: progressManager) {
                        isUnlocked = false
                        userAnswer = ""
                        generateQuestion()
                    }
                } else {
                    ParentalGateChallenge(
                        question: mathQuestion,
                        answer: userAnswer,
                        onAnswerChanged: { userAnswer = $0 },
                        onSubmit: checkAnswer
                    )
                }
            }
            .navigationTitle("Parents")
            .onAppear { generateQuestion() }
        }
    }
    
    private func generateQuestion() {
        let n1 = Int.random(in: 5...20)
        let n2 = Int.random(in: 5...20)
        correctAnswer = n1 + n2
        mathQuestion = "What is \(n1) + \(n2)?"
    }
    
    private func checkAnswer() {
        if let ans = Int(userAnswer), ans == correctAnswer {
            isUnlocked = true
        } else {
            generateQuestion()
            userAnswer = ""
        }
    }
}

struct ParentalGateChallenge: View {
    let question: String
    let answer: String
    let onAnswerChanged: (String) -> Void
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill").font(.system(size: 80)).foregroundColor(.orange)
            Text("Parental Gate").font(.title).fontWeight(.bold)
            Text("Answer to continue").font(.subheadline).foregroundColor(.gray)
            
            Text(question).font(.title2).fontWeight(.bold).foregroundColor(.blue)
            
            TextField("Answer", text: onAnswerChanged)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)
            
            Button(action: onSubmit) {
                Text("Unlock").font(.headline).foregroundColor(.white)
                    .padding(.horizontal, 40).padding(.vertical, 12)
                    .background(Color.orange).cornerRadius(25)
            }
        }.padding()
    }
}

struct ParentSettingsView: View {
    @ObservedObject var progressManager: ProgressViewModel
    let onLock: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                Text("Unlocked!").font(.headline).foregroundColor(.green)
            }.padding().background(Color.green.opacity(0.1)).cornerRadius(10)
            
            Form {
                Section(header: Text("📊 Progress")) {
                    HStack { Text("Games"); Spacer(); Text("\(progressManager.completedGames.count)") }
                    HStack { Text("Stories"); Spacer(); Text("\(progressManager.completedStories.count)") }
                    HStack { Text("Stars"); Spacer(); Text("\(progressManager.totalStars) ⭐") }
                }
                
                Section {
                    Button(action: onLock) {
                        HStack { Image(systemName: "lock.fill"); Text("Lock") }
                    }.foregroundColor(.orange)
                }
            }
        }.padding()
    }
}
