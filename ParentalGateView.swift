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
                        answer: $userAnswer,
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
    @Binding var answer: String
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image("ui_lock")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)

            Text("Parental Gate").font(.title).fontWeight(.bold)
            Text("Solve this to continue").font(.subheadline).foregroundColor(.secondary)

            Text(question).font(.title2).fontWeight(.bold).foregroundColor(PlayLandTheme.skyBlue)

            TextField("Answer", text: $answer)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.center)
                .frame(width: 200)

            Button("Unlock", action: onSubmit)
                .buttonStyle(PlayfulButtonStyle(color: PlayLandTheme.sunOrange))
        }
        .padding()
    }
}

struct ParentSettingsView: View {
    @ObservedObject var progressManager: ProgressViewModel
    let onLock: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image("ui_check")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text("Unlocked!").font(.headline).foregroundColor(PlayLandTheme.leafGreen)
            }
            .padding()
            .background(PlayLandTheme.leafGreen.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Form {
                Section(header: Text("Progress")) {
                    HStack { Text("Games Completed"); Spacer(); Text("\(progressManager.completedGames.count)") }
                    HStack { Text("Stories Completed"); Spacer(); Text("\(progressManager.completedStories.count)") }
                    HStack {
                        Text("Total Stars")
                        Spacer()
                        Text("\(progressManager.totalStars)")
                        Image("ui_star")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                    }
                }

                Section(header: Text("Badges")) {
                    Image("badges")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 90)
                        .frame(maxWidth: .infinity)
                }

                Section {
                    Button(action: { progressManager.resetProgress() }) {
                        Text("Reset Progress")
                    }
                    .foregroundColor(.red)

                    Button(action: onLock) {
                        HStack {
                            Image("ui_lock")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                            Text("Lock")
                        }
                    }
                    .foregroundColor(PlayLandTheme.sunOrange)
                }
            }
        }
        .padding()
    }
}
