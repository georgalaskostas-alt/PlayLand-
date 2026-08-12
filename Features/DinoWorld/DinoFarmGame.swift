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
    @State private var taps = 0
    @State private var isFinished = false
    /// A brief per-action reaction (eating, drinking, a "just been
    /// scrubbed" beat) shown right after a care button tap, then cleared
    /// back to whatever `progressState` says. `nil` means "show the
    /// persistent need/progress state."
    @State private var reactionState: BabisVisualState?

    private let totalNeeds = 3

    private var satisfiedNeeds: Int {
        totalNeeds - [needsFood, needsWater, needsCleaning].filter { $0 }.count
    }

    /// Babis' persistent state from which needs are still unmet — dirty
    /// takes visual priority (the most immediately obvious problem), then
    /// hunger, then thirst, so exactly one state drives the character art
    /// even though several needs can be true at once. Never happy/excited
    /// until every need is satisfied.
    private var progressState: BabisVisualState {
        if isFinished { return .excited }
        if needsCleaning { return .dirty }
        if needsFood { return .hungry }
        if needsWater { return .thirsty }
        return .happy
    }

    private var displayState: BabisVisualState { reactionState ?? progressState }
    private var fallbackMood: FallbackMoodTreatment { FallbackMoodTreatment(remainingNeeds: totalNeeds - satisfiedNeeds) }
    private var hasArtForDisplayState: Bool { BabisAssetResolver.hasSpecificAsset(for: displayState) }

    /// The accent prop shown alongside Babis: a transient confirmation for
    /// whichever action was just tapped (a full bowl, a burst of bubbles),
    /// or — with no reaction playing — a persistent mud spot for as long
    /// as cleaning is still needed, reinforcing the need the same way the
    /// character art itself does.
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
            VStack(spacing: 24) {
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

                VStack(spacing: 6) {
                    ProgressView(value: Double(satisfiedNeeds), total: Double(totalNeeds))
                        .tint(PlayLandColors.leafGreen)
                    Text(Loc.t("dino.farm.needsLabel", satisfiedNeeds, totalNeeds))
                        .font(PlayLandTypography.body)
                        .foregroundColor(PlayLandColors.secondaryText)
                }
                .padding(.horizontal, 30)

                HStack(spacing: 16) {
                    careButton(title: Loc.t("dino.farm.feed"), assetName: AppAssets.DinoFarmProps.foodBowlEmpty, emoji: "🍓", isSatisfied: !needsFood, action: feed)
                    careButton(title: Loc.t("dino.farm.water"), assetName: AppAssets.DinoFarmProps.waterBowlEmpty, emoji: "💧", isSatisfied: !needsWater, action: water)
                    careButton(title: Loc.t("dino.farm.clean"), assetName: AppAssets.DinoFarmProps.cleaningBrush, emoji: "🧼", isSatisfied: !needsCleaning, action: clean)
                }

                Spacer()
            }
            .padding()

            if isFinished {
                CompletionCelebrationView(
                    title: Loc.t("dino.farm.completeTitle"),
                    message: Loc.t("dino.farm.completeMessage", taps),
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
            .offset(y: hasArtForDisplayState ? 0 : fallbackMood.verticalOffset)
            .scaleEffect(displayState == .excited ? 1.08 : 1.0)
            .animation(PlayLandAnimation.respecting(reduceMotion, PlayLandAnimation.bounce), value: satisfiedNeeds)
            .animation(PlayLandAnimation.respecting(reduceMotion, .easeInOut(duration: 0.2)), value: reactionState)
    }

    /// Satisfying all 3 needs in exactly 3 taps (one per need) earns the
    /// full 3 stars; extra, unnecessary taps cost a star the same way
    /// replaying any other game for a better score does.
    private var stars: Int {
        if taps <= 3 { return 3 }
        if taps <= 5 { return 2 }
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

    private func feed() {
        guard needsFood else { return }
        taps += 1
        AudioManager.shared.play(.correct)
        showReaction(.eating, for: 0.9)
        needsFood = false
        finishIfAllNeedsMet()
    }

    private func water() {
        guard needsWater else { return }
        taps += 1
        AudioManager.shared.play(.correct)
        showReaction(.drinking, for: 0.9)
        needsWater = false
        finishIfAllNeedsMet()
    }

    /// Babis is already shown dirty from the moment the screen appears —
    /// tapping Clean plays a short "just been scrubbed" confirmation and
    /// then reveals whatever need is next (or happy/excited if that was
    /// the last one). There's no separate "become dirty" step to play.
    private func clean() {
        guard needsCleaning else { return }
        taps += 1
        AudioManager.shared.play(.correct)
        showReaction(.clean, for: 0.9)
        needsCleaning = false
        finishIfAllNeedsMet()
    }

    private func showReaction(_ state: BabisVisualState, for duration: Double) {
        withAnimation { reactionState = state }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation { reactionState = nil }
        }
    }

    private func finishIfAllNeedsMet() {
        guard !needsFood, !needsWater, !needsCleaning else { return }
        withAnimation { isFinished = true }
    }
}
