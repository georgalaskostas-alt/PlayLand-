import SwiftUI

/// Babis' emotional state, driven entirely by `happiness`. The game must
/// never show Babis as already happy before the child has done anything —
/// the single `babis_dinosaur` art asset is drawn smiling, so mood is
/// communicated with saturation, position and motion instead of a
/// different character pose (see the final report for the character-state
/// art assets that would let mood use real artwork instead).
enum DinoMood: Equatable {
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

    private let goal = 100

    private var mood: DinoMood { DinoMood(happiness: happiness, goal: goal) }

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                GameHeader(title: Loc.t("dino.farm.title"), subtitle: Loc.t("dino.farm.instruction"))

                ZStack(alignment: .topTrailing) {
                    AppAssets.image(AppAssets.Characters.babis)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .saturation(mood.saturation)
                        .offset(y: mood.verticalOffset)
                        .scaleEffect(mood == .happy ? 1.08 : 1.0)
                        .animation(PlayLandAnimation.respecting(reduceMotion, PlayLandAnimation.bounce), value: happiness)

                    if mood.showsThoughtBubble {
                        Text("💭")
                            .font(.system(size: 34))
                            .offset(x: 10, y: mood.verticalOffset - 10)
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
                    careButton(title: Loc.t("dino.farm.feed"), emoji: "🍃", amount: 20)
                    careButton(title: Loc.t("dino.farm.clean"), emoji: "🧼", amount: 15)
                    careButton(title: Loc.t("dino.farm.play"), emoji: "🎾", amount: 15)
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

    private var stars: Int {
        if taps <= 6 { return 3 }
        if taps <= 9 { return 2 }
        return 1
    }

    private func careButton(title: String, emoji: String, amount: Int) -> some View {
        Button(action: { care(amount: amount) }) {
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

    private func care(amount: Int) {
        taps += 1
        happiness = min(goal, happiness + amount)
        AudioManager.shared.play(.correct)
        if happiness >= goal {
            withAnimation { isFinished = true }
        }
    }
}
