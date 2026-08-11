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

    init(happiness: Int, goal: Int) {
        let ratio = Double(happiness) / Double(goal)
        switch ratio {
        case ..<0.25: self = .sad
        case ..<0.5: self = .neutral
        case ..<1.0: self = .improving
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

    @State private var happiness = 0
    @State private var taps = 0
    @State private var isFinished = false
    /// A brief per-action reaction (eating, drinking, a dirty→clean beat)
    /// shown right after a care button tap, then cleared back to whatever
    /// `progressState` says. `nil` means "show the progress state."
    @State private var reactionState: BabisVisualState?

    private let goal = 100

    /// Babis' state from overall care progress alone: starts hungry,
    /// settles to neutral, then happy, then excited once the goal is met.
    private var progressState: BabisVisualState {
        if isFinished { return .excited }
        let ratio = Double(happiness) / Double(goal)
        switch ratio {
        case ..<0.34: return .hungry
        case ..<0.7: return .neutral
        default: return .happy
        }
    }

    private var displayState: BabisVisualState { reactionState ?? progressState }
    private var fallbackMood: FallbackMoodTreatment { FallbackMoodTreatment(happiness: happiness, goal: goal) }
    private var hasArtForDisplayState: Bool { BabisAssetResolver.hasSpecificAsset(for: displayState) }

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
                }
                .frame(height: 200)

                VStack(spacing: 6) {
                    ProgressView(value: Double(happiness), total: Double(goal))
                        .tint(PlayLandColors.leafGreen)
                    Text(Loc.t("dino.farm.happinessLabel", happiness, goal))
                        .font(PlayLandTypography.body)
                        .foregroundColor(PlayLandColors.secondaryText)
                }
                .padding(.horizontal, 30)

                HStack(spacing: 16) {
                    careButton(title: Loc.t("dino.farm.feed"), emoji: "🍓", amount: 20) { care(amount: 20, reaction: .eating) }
                    careButton(title: Loc.t("dino.farm.water"), emoji: "💧", amount: 15) { care(amount: 15, reaction: .drinking) }
                    careButton(title: Loc.t("dino.farm.clean"), emoji: "🧼", amount: 15) { performClean(amount: 15) }
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
            .animation(PlayLandAnimation.respecting(reduceMotion, PlayLandAnimation.bounce), value: happiness)
            .animation(PlayLandAnimation.respecting(reduceMotion, .easeInOut(duration: 0.2)), value: reactionState)
    }

    private var stars: Int {
        if taps <= 6 { return 3 }
        if taps <= 9 { return 2 }
        return 1
    }

    private func careButton(title: String, emoji: String, amount: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(emoji).font(.system(size: 30))
                Text(title).font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .frame(minHeight: PlayLandMetrics.minTouchTarget)
            .background(PlayLandColors.warmCream)
            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
            .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
        }
        .disabled(isFinished)
    }

    private func care(amount: Int, reaction: BabisVisualState) {
        taps += 1
        happiness = min(goal, happiness + amount)
        AudioManager.shared.play(.correct)
        showReaction(reaction, for: 0.9)
        finishIfGoalMet()
    }

    /// Cleaning gets its own two-beat reaction — a flash of "dirty" (being
    /// scrubbed) settling into "clean" — instead of a single static state.
    private func performClean(amount: Int) {
        taps += 1
        happiness = min(goal, happiness + amount)
        AudioManager.shared.play(.correct)

        withAnimation { reactionState = .dirty }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation { reactionState = .clean }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            withAnimation { reactionState = nil }
        }
        finishIfGoalMet()
    }

    private func showReaction(_ state: BabisVisualState, for duration: Double) {
        withAnimation { reactionState = state }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation { reactionState = nil }
        }
    }

    private func finishIfGoalMet() {
        guard happiness >= goal else { return }
        withAnimation { isFinished = true }
    }
}
