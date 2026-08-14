import SwiftUI

private enum CareNeed: CaseIterable, Equatable {
    case cleaning, food, water
}

struct DinoFarmGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var level = 1
    @State private var careOrder: [CareNeed] = [.cleaning, .food, .water]
    @State private var completedNeeds: Set<Int> = []
    @State private var currentNeedIndex = 0
    @State private var reactionState: BabisVisualState?
    @State private var hintText: String?
    @State private var mistakes = 0
    @State private var totalMistakes = 0
    @State private var shakeOffset: CGFloat = 0
    @State private var showLevelComplete = false
    @State private var isFinished = false

    private let totalLevels = 5
    private let reactionDuration = 0.8

    private var activeNeed: CareNeed? {
        careOrder.indices.contains(currentNeedIndex) ? careOrder[currentNeedIndex] : nil
    }

    private var persistentState: BabisVisualState {
        guard let activeNeed else { return .happy }
        switch activeNeed {
        case .cleaning: return .dirty
        case .food: return .hungry
        case .water: return .thirsty
        }
    }

    private var displayState: BabisVisualState { reactionState ?? (isFinished ? .excited : persistentState) }
    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }
    private var levelLabel: String { isGreek ? "Φροντίδα \(level) από \(totalLevels)" : "Care session \(level) of \(totalLevels)" }
    private var levelCompleteTitle: String { isGreek ? "Ο Μπάμπης είναι χαρούμενος!" : "Babis is happy!" }
    private var levelCompleteMessage: String { isGreek ? "Η επόμενη μέρα θα έχει διαφορετική σειρά αναγκών." : "The next day has a different care order." }
    private var nextTitle: String { isGreek ? "Επόμενη μέρα" : "Next day" }
    private var finalMessage: String { isGreek ? "Φρόντισες σωστά τον Μπάμπη για 5 ολόκληρες μέρες." : "You cared for Babis for 5 full days." }
    private var levelStars: Int { mistakes == 0 ? 3 : (mistakes <= 2 ? 2 : 1) }
    private var finalStars: Int { totalMistakes <= 2 ? 3 : (totalMistakes <= 6 ? 2 : 1) }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(title: Loc.t("dino.farm.title"), subtitle: Loc.t("dino.farm.instruction"))
                    Text(levelLabel)
                        .font(PlayLandTypography.heading)
                        .foregroundColor(PlayLandColors.sunOrange)

                    ZStack(alignment: .bottomLeading) {
                        BabisAssetResolver.image(for: displayState)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 220)
                            .offset(x: shakeOffset)
                            .animation(PlayLandAnimation.respecting(reduceMotion, .easeInOut(duration: 0.2)), value: reactionState)

                        if let prop = accentProp, AppAssets.exists(prop) {
                            AppAssets.image(prop)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(maxWidth: .infinity)

                    if let hintText {
                        Text(hintText)
                            .font(PlayLandTypography.body)
                            .multilineTextAlignment(.center)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
                    }

                    ProgressView(value: Double(currentNeedIndex), total: Double(CareNeed.allCases.count))
                        .tint(PlayLandColors.leafGreen)
                        .padding(.horizontal, 24)

                    HStack(spacing: 12) {
                        careButton(title: Loc.t("dino.farm.feed"), asset: AppAssets.DinoFarmProps.foodBowlEmpty, fallback: "🍓", need: .food)
                        careButton(title: Loc.t("dino.farm.water"), asset: AppAssets.DinoFarmProps.waterBowlEmpty, fallback: "💧", need: .water)
                        careButton(title: Loc.t("dino.farm.clean"), asset: AppAssets.DinoFarmProps.cleaningBrush, fallback: "🧼", need: .cleaning)
                    }
                }
                .padding()
            }
            .onAppear(perform: setupLevel)

            if showLevelComplete {
                CompletionCelebrationView(
                    title: levelCompleteTitle,
                    message: levelCompleteMessage,
                    stars: levelStars,
                    buttonTitle: level < totalLevels ? nextTitle : Loc.t("action.continue"),
                    action: advanceLevel
                )
            }

            if isFinished {
                CompletionCelebrationView(
                    title: Loc.t("dino.farm.completeTitle"),
                    message: finalMessage,
                    stars: finalStars,
                    buttonTitle: Loc.t("dino.farm.completeButton"),
                    action: {
                        progressManager.completeGame("dino_farm", stars: finalStars)
                        dismiss()
                    }
                )
            }
        }
    }

    private var accentProp: String? {
        guard let reactionState else { return activeNeed == .cleaning ? AppAssets.DinoFarmProps.mudSplash : nil }
        switch reactionState {
        case .eating: return AppAssets.DinoFarmProps.foodBowlFull
        case .drinking: return AppAssets.DinoFarmProps.waterBowlFull
        case .clean: return AppAssets.DinoFarmProps.soapBubbles
        default: return nil
        }
    }

    private func careButton(title: String, asset: String, fallback: String, need: CareNeed) -> some View {
        Button(action: { attempt(need) }) {
            VStack(spacing: 6) {
                if AppAssets.exists(asset) {
                    AppAssets.image(asset).resizable().scaledToFit().frame(width: 36, height: 36)
                } else {
                    Text(fallback).font(.system(size: 30))
                }
                Text(title).font(.subheadline.weight(.semibold)).multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .frame(minHeight: PlayLandMetrics.primaryTouchTarget)
            .background(PlayLandColors.warmCream)
            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
            .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
        }
        .disabled(showLevelComplete || isFinished || completedNeeds.contains(index(of: need)))
    }

    private func index(of need: CareNeed) -> Int { CareNeed.allCases.firstIndex(of: need) ?? -1 }

    private func attempt(_ need: CareNeed) {
        guard let activeNeed else { return }
        if need == activeNeed {
            hintText = nil
            AudioManager.shared.play(.correct)
            completedNeeds.insert(index(of: need))
            showReaction(for: need)
            currentNeedIndex += 1
            if currentNeedIndex >= careOrder.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + reactionDuration) {
                    withAnimation { showLevelComplete = true }
                }
            }
        } else {
            mistakes += 1
            totalMistakes += 1
            AudioManager.shared.play(.wrong)
            let text = hint(for: activeNeed)
            withAnimation { hintText = text }
            SpeechManager.shared.speak(text: text)
            gentleShake()
        }
    }

    private func hint(for need: CareNeed) -> String {
        if isGreek {
            switch need {
            case .cleaning: return "Κοίτα προσεκτικά τον Μπάμπη. Μήπως χρειάζεται να καθαριστεί;"
            case .food: return "Κοίτα την έκφρασή του. Μήπως πεινάει;"
            case .water: return "Κοίτα τον Μπάμπη. Μήπως διψάει;"
            }
        } else {
            switch need {
            case .cleaning: return "Look closely at Babis. Does he need cleaning?"
            case .food: return "Look at his expression. Could he be hungry?"
            case .water: return "Look at Babis. Could he be thirsty?"
            }
        }
    }

    private func showReaction(for need: CareNeed) {
        let state: BabisVisualState = need == .food ? .eating : (need == .water ? .drinking : .clean)
        withAnimation { reactionState = state }
        DispatchQueue.main.asyncAfter(deadline: .now() + reactionDuration) { withAnimation { reactionState = nil } }
    }

    private func gentleShake() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 0.08)) { shakeOffset = 8 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { withAnimation(.easeInOut(duration: 0.08)) { shakeOffset = -8 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) { withAnimation(.easeInOut(duration: 0.08)) { shakeOffset = 0 } }
    }

    private func setupLevel() {
        switch level {
        case 1: careOrder = [.cleaning, .food, .water]
        case 2: careOrder = [.food, .water, .cleaning]
        case 3: careOrder = [.water, .cleaning, .food]
        default: careOrder = CareNeed.allCases.shuffled()
        }
        completedNeeds = []
        currentNeedIndex = 0
        mistakes = 0
        hintText = nil
        reactionState = nil
        showLevelComplete = false
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
}
