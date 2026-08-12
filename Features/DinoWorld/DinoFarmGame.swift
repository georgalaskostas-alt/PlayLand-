import SwiftUI

/// Grayscale/offset treatment used ONLY as a fallback while a
/// `BabisVisualState` has no dedicated artwork yet (see
/// `BabisAssetResolver`). Once real art exists for a state, `DinoFarmGame`
/// renders it directly and this treatment is skipped entirely — it must
/// never be presented as if it were the intended premium look.
private enum FallbackMoodTreatment: Equatable {
    case sad
    case neutral
    case improving
    case happy

    /// Keyed off how many of the 3 care needs are still unmet (0-3), not a
    /// continuous meter — there is no continuous meter anymore.
    init(remainingNeeds: Int) {
        switch remainingNeeds {
        case 3: self = .sad
        case 2: self = .neutral
        case 1: self = .improving
        default: self = .happy
        }
    }

    var saturation: Double {
        switch self {
        case .sad: return 0.25
        case .neutral: return 0.55
        case .improving: return 0.85
        case .happy: return 1.0
        }
    }

    var verticalOffset: CGFloat {
        switch self {
        case .sad: return 22
        case .neutral: return 12
        case .improving: return 4
        case .happy: return 0
        }
    }

    var showsThoughtBubble: Bool { self != .happy }
}

/// One care need Babis can have. Exactly one is "active" (the one the
/// child must currently identify) at a time — see `DinoFarmGame.activeNeed`.
private enum CareNeed {
    case cleaning
    case food
    case water
}

struct DinoFarmGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The 3 care needs. All start `true` — unsatisfied and visible —
    /// the instant the screen appears, so Babis's need is communicated
    /// BEFORE the child does anything, never only after a tap.
    @State private var needsFood = true
    @State private var needsWater = true
    @State private var needsCleaning = true
    @State private var isFinished = false
    /// A brief per-action reaction (eating, drinking, a "just been
    /// scrubbed" beat) shown right after a correct choice, then cleared
    /// back to whatever `progressState` says. `nil` means "show the
    /// persistent need/progress state."
    @State private var reactionState: BabisVisualState?

    /// Wrong guesses for the *current* active need only — resets to 0 the
    /// moment the child gets it right, so each need's hints start fresh.
    /// Drives which of the 2 hint tiers is shown.
    @State private var hintAttempts = 0
    /// Wrong guesses across the whole session — never resets. Drives the
    /// final star rating, since resetting per-need wouldn't reward a child
    /// who reasoned through the whole visit without ever guessing.
    @State private var totalWrongAttempts = 0
    /// The hint currently shown near Babis, or `nil` between guesses.
    @State private var hintText: String?
    /// A short, non-punishing wobble played on a wrong guess — never a red
    /// X or a failure sound, just a gentle "hmm, not that" nudge.
    @State private var shakeOffset: CGFloat = 0

    private let reactionDuration = 0.9
    private let totalNeeds = 3

    private var satisfiedNeeds: Int {
        totalNeeds - [needsFood, needsWater, needsCleaning].filter { $0 }.count
    }

    /// The one need the child should currently be reasoning about — dirty
    /// first (the most visually obvious problem), then hunger, then
    /// thirst. `nil` once every need is satisfied.
    private var activeNeed: CareNeed? {
        if needsCleaning { return .cleaning }
        if needsFood { return .food }
        if needsWater { return .water }
        return nil
    }

    /// Babis' persistent state from the active need alone — this is the
    /// visual "question" the child must read and answer; it's never
    /// spelled out anywhere in a text label.
    private var progressState: BabisVisualState {
        if isFinished { return .excited }
        switch activeNeed {
        case .cleaning: return .dirty
        case .food: return .hungry
        case .water: return .thirsty
        case nil: return .happy
        }
    }

    private var displayState: BabisVisualState { reactionState ?? progressState }
    private var fallbackMood: FallbackMoodTreatment { FallbackMoodTreatment(remainingNeeds: totalNeeds - satisfiedNeeds) }
    private var hasArtForDisplayState: Bool { BabisAssetResolver.hasSpecificAsset(for: displayState) }

    /// A VoiceOver-only description of Babis's current state. Sighted UI
    /// never shows this as visible text (that would hand the child the
    /// answer), but a non-visual player needs some way to receive the same
    /// information the artwork alone is conveying.
    private var accessibilityStateDescription: String {
        switch displayState {
        case .dirty: return Loc.t("dino.farm.state.dirty")
        case .hungry: return Loc.t("dino.farm.state.hungry")
        case .thirsty: return Loc.t("dino.farm.state.thirsty")
        case .excited: return Loc.t("dino.farm.state.excited")
        default: return Loc.t("dino.farm.state.happy")
        }
    }

    /// The accent prop shown alongside Babis: a transient confirmation for
    /// whichever action was just correctly chosen (a full bowl, a burst of
    /// bubbles), or — with no reaction playing — a persistent mud spot for
    /// as long as cleaning is still needed, reinforcing the need the same
    /// way the character art itself does.
    private var accentPropAsset: String? {
        if let reactionState {
            switch reactionState {
            case .eating: return AppAssets.DinoFarmProps.foodBowlFull
            case .drinking: return AppAssets.DinoFarmProps.waterBowlFull
            case .clean: return AppAssets.DinoFarmProps.soapBubbles
            default: return nil
            }
        }
        return needsCleaning ? AppAssets.DinoFarmProps.mudSplash : nil
    }

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                GameHeader(title: Loc.t("dino.farm.title"), subtitle: Loc.t("dino.farm.instruction"))

                ZStack(alignment: .topTrailing) {
                    babisArt

                    if !hasArtForDisplayState, !isFinished, fallbackMood.showsThoughtBubble {
                        Text("💭")
                            .font(.system(size: 34))
                            .offset(x: 10, y: fallbackMood.verticalOffset - 10)
                            .accessibilityHidden(true)
                    }

                    if let accentPropAsset, AppAssets.exists(accentPropAsset) {
                        VStack {
                            Spacer()
                            HStack {
                                AppAssets.image(accentPropAsset)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: PlayLandMetrics.worldPropAccentSize, height: PlayLandMetrics.worldPropAccentSize)
                                Spacer()
                            }
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.7)))
                        .accessibilityHidden(true)
                    }
                }
                .frame(height: 200)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(accessibilityStateDescription))

                if let hintText {
                    Text(hintText)
                        .font(PlayLandTypography.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(PlayLandColors.primaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
                        .padding(.horizontal, 24)
                        .transition(.opacity)
                }

                VStack(spacing: 6) {
                    ProgressView(value: Double(satisfiedNeeds), total: Double(totalNeeds))
                        .tint(PlayLandColors.leafGreen)
                    Text(Loc.t("dino.farm.needsLabel", satisfiedNeeds, totalNeeds))
                        .font(PlayLandTypography.body)
                        .foregroundColor(PlayLandColors.secondaryText)
                }
                .padding(.horizontal, 30)

                HStack(spacing: 16) {
                    careButton(title: Loc.t("dino.farm.feed"), assetName: AppAssets.DinoFarmProps.foodBowlEmpty, emoji: "🍓", isSatisfied: !needsFood) { attempt(.food) }
                    careButton(title: Loc.t("dino.farm.water"), assetName: AppAssets.DinoFarmProps.waterBowlEmpty, emoji: "💧", isSatisfied: !needsWater) { attempt(.water) }
                    careButton(title: Loc.t("dino.farm.clean"), assetName: AppAssets.DinoFarmProps.cleaningBrush, emoji: "🧼", isSatisfied: !needsCleaning) { attempt(.cleaning) }
                }

                Spacer()
            }
            .padding()

            if isFinished {
                CompletionCelebrationView(
                    title: Loc.t("dino.farm.completeTitle"),
                    message: Loc.t("dino.farm.completeMessage"),
                    stars: stars,
                    buttonTitle: Loc.t("dino.farm.completeButton"),
                    action: {
                        progressManager.completeGame("dino_farm", stars: stars)
                        dismiss()
                    }
                )
            }
        }
    }

    @ViewBuilder
    private var babisArt: some View {
        BabisAssetResolver.image(for: displayState)
            .resizable()
            .scaledToFit()
            .frame(height: 180)
            // Only the fallback (no dedicated art for this state yet) needs
            // desaturation and a vertical nudge to read as a distinct mood —
            // real artwork already conveys the mood on its own.
            .saturation(hasArtForDisplayState ? 1.0 : fallbackMood.saturation)
            .offset(x: shakeOffset, y: hasArtForDisplayState ? 0 : fallbackMood.verticalOffset)
            .scaleEffect(displayState == .excited ? 1.08 : 1.0)
            .animation(PlayLandAnimation.respecting(reduceMotion, PlayLandAnimation.bounce), value: satisfiedNeeds)
            .animation(PlayLandAnimation.respecting(reduceMotion, .easeInOut(duration: 0.2)), value: reactionState)
    }

    /// A wrong guess never costs a star in the moment — but going the
    /// whole visit without one means the child read every state
    /// correctly, which is worth recognizing more than random guessing.
    private var stars: Int {
        if totalWrongAttempts == 0 { return 3 }
        if totalWrongAttempts <= 2 { return 2 }
        return 1
    }

    @ViewBuilder
    private func careIcon(assetName: String, emoji: String) -> some View {
        if AppAssets.exists(assetName) {
            AppAssets.image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
        } else {
            Text(emoji).font(.system(size: 30))
        }
    }

    private func careButton(title: String, assetName: String, emoji: String, isSatisfied: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    careIcon(assetName: assetName, emoji: emoji)
                    if isSatisfied {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(PlayLandColors.leafGreen)
                            .background(Circle().fill(.white))
                            .offset(x: 8, y: -8)
                    }
                }
                Text(title).font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .frame(minHeight: PlayLandMetrics.minTouchTarget)
            .background(PlayLandColors.warmCream)
            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
            .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
            .opacity(isSatisfied ? 0.6 : 1.0)
        }
        .disabled(isFinished || isSatisfied)
    }

    /// The core reasoning check: `need` only succeeds if it matches
    /// `activeNeed` — the need Babis's current art is actually showing.
    /// Any other still-unmet need is a wrong guess, regardless of which
    /// one was tapped; already-satisfied needs can't be tapped at all
    /// (their button is disabled), so there's nothing to mis-tap there.
    private func attempt(_ need: CareNeed) {
        guard let activeNeed else { return }
        if need == activeNeed {
            handleCorrect(need)
        } else {
            handleIncorrect()
        }
    }

    private func handleCorrect(_ need: CareNeed) {
        hintAttempts = 0
        withAnimation { hintText = nil }
        AudioManager.shared.play(.correct)

        switch need {
        case .cleaning:
            needsCleaning = false
            showReaction(.clean)
        case .food:
            needsFood = false
            showReaction(.eating)
        case .water:
            needsWater = false
            showReaction(.drinking)
        }

        if !needsFood, !needsWater, !needsCleaning {
            finish()
        } else {
            SpeechManager.shared.speak(text: Loc.t(praiseKey(for: need)))
        }
    }

    /// A wrong guess never changes any need, never plays a reaction, and
    /// never advances anything — Babis stays exactly as he was. The child
    /// gets a gentle spoken nudge instead, escalating to a more specific
    /// hint only after a second miss on this same need.
    private func handleIncorrect() {
        guard let activeNeed else { return }
        hintAttempts += 1
        totalWrongAttempts += 1
        AudioManager.shared.play(.buttonTap)
        triggerGentleShake()

        let key = hintAttempts == 1 ? generalHintKey(for: activeNeed) : specificHintKey(for: activeNeed)
        let text = Loc.t(key)
        withAnimation { hintText = text }
        SpeechManager.shared.speak(text: text)
    }

    private func praiseKey(for need: CareNeed) -> String {
        switch need {
        case .cleaning: return "dino.farm.praise.dirty"
        case .food: return "dino.farm.praise.hungry"
        case .water: return "dino.farm.praise.thirsty"
        }
    }

    private func generalHintKey(for need: CareNeed) -> String {
        switch need {
        case .cleaning: return "dino.farm.hint.dirty.general"
        case .food: return "dino.farm.hint.hungry.general"
        case .water: return "dino.farm.hint.thirsty.general"
        }
    }

    private func specificHintKey(for need: CareNeed) -> String {
        switch need {
        case .cleaning: return "dino.farm.hint.dirty.specific"
        case .food: return "dino.farm.hint.hungry.specific"
        case .water: return "dino.farm.hint.thirsty.specific"
        }
    }

    private func showReaction(_ state: BabisVisualState) {
        withAnimation { reactionState = state }
        DispatchQueue.main.asyncAfter(deadline: .now() + reactionDuration) {
            withAnimation { reactionState = nil }
        }
    }

    private func triggerGentleShake() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 0.1)) { shakeOffset = 10 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) { shakeOffset = -10 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.1)) { shakeOffset = 0 }
        }
    }

    private func finish() {
        withAnimation { isFinished = true }
        // `isFinished` flips `displayState`/`progressState` to `.excited`
        // for the art; `CompletionCelebrationView` speaks the completion
        // title+message itself once it appears, so no separate spoken line
        // is triggered here — that would talk over it.
    }
}
