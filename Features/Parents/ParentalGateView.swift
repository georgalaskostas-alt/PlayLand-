import SwiftUI

struct ParentalGateView: View {
    @State private var mathQuestion = ""
    @State private var correctAnswer = 0
    @State private var userAnswer = ""
    @State private var isUnlocked = false
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings

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
            .navigationTitle(Loc.t("parent.navTitle"))
            .onAppear { generateQuestion() }
        }
    }

    private func generateQuestion() {
        let n1 = Int.random(in: 5...20)
        let n2 = Int.random(in: 5...20)
        correctAnswer = n1 + n2
        mathQuestion = Loc.t("parent.gate.question", n1, n2)
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
            AppAssets.image(AppAssets.PlannedUI.lock)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)

            Text(Loc.t("parent.gate.title")).font(PlayLandTypography.title)
            Text(Loc.t("parent.gate.subtitle")).font(PlayLandTypography.body).foregroundColor(PlayLandColors.secondaryText)

            Text(question).font(.title2).fontWeight(.bold).foregroundColor(PlayLandColors.skyBlue)

            TextField(Loc.t("parent.gate.answerField"), text: $answer)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.center)
                .frame(width: 200)
                .frame(minHeight: PlayLandMetrics.minTouchTarget)

            PlayLandPrimaryButton(title: Loc.t("action.unlock"), color: PlayLandColors.sunOrange, action: onSubmit)
        }
        .padding()
    }
}

struct ParentSettingsView: View {
    @ObservedObject var progressManager: ProgressViewModel
    @ObservedObject private var appSettings = AppSettings.shared
    let onLock: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                AppAssets.image(AppAssets.PlannedUI.check)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text(Loc.t("parent.unlocked")).font(PlayLandTypography.heading).foregroundColor(PlayLandColors.leafGreen)
            }
            .padding()
            .background(PlayLandColors.leafGreen.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusSmall))

            Form {
                Section(header: Text(Loc.t("parent.progress.header"))) {
                    HStack { Text(Loc.t("parent.progress.games")); Spacer(); Text("\(progressManager.completedGames.count)") }
                    HStack { Text(Loc.t("parent.progress.stories")); Spacer(); Text("\(progressManager.completedStories.count)") }
                    HStack { Text(Loc.t("parent.progress.chapters")); Spacer(); Text("\(progressManager.completedChapters.count)") }
                    HStack {
                        Text(Loc.t("parent.progress.stars"))
                        Spacer()
                        Text("\(progressManager.totalStars)")
                        AppAssets.image(AppAssets.PlannedUI.star)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                    }
                }

                Section(header: Text(Loc.t("parent.badges.header"))) {
                    AppAssets.image(AppAssets.Badges.sheet)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 90)
                        .frame(maxWidth: .infinity)
                }

                Section(header: Text(Loc.t("parent.settings.header"))) {
                    Toggle(Loc.t("parent.settings.narration"), isOn: $appSettings.isNarrationEnabled)
                    Toggle(Loc.t("parent.settings.soundEffects"), isOn: $appSettings.isSoundEffectsEnabled)

                    Picker(Loc.t("parent.settings.language"), selection: $appSettings.language) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                }

                Section {
                    Button(action: { progressManager.resetProgress() }) {
                        Text(Loc.t("action.resetProgress"))
                    }
                    .foregroundColor(.red)

                    Button(action: onLock) {
                        HStack {
                            AppAssets.image(AppAssets.PlannedUI.lock)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                            Text(Loc.t("action.lock"))
                        }
                    }
                    .foregroundColor(PlayLandColors.sunOrange)
                }
            }
        }
        .padding()
    }
}
