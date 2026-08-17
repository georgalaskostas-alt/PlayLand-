import SwiftUI

private struct SortCreature: Identifiable {
    let id: Int
    let imageName: String
    let name: String
    let isBig: Bool
    var sorted = false
}

struct DinoSortGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    var onChallengeComplete: ((Int) -> Void)?

    @State private var level = 1
    @State private var creatures: [SortCreature] = []
    @State private var selectedId: Int?
    @State private var mistakes = 0
    @State private var totalMistakes = 0
    @State private var showLevelComplete = false
    @State private var isFinished = false

    private let totalLevels = 6

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    GameHeader(title: Loc.t("dino.sort.title"), subtitle: Loc.t("dino.sort.instruction"))

                    HStack {
                        Text(levelLabel)
                            .font(PlayLandTypography.heading)
                            .foregroundColor(PlayLandColors.sunOrange)
                        Spacer()
                        Text(creatureCountLabel)
                            .font(PlayLandTypography.caption)
                            .foregroundColor(PlayLandColors.secondaryText)
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: min(4, max(2, creatures.count))), spacing: 8) {
                        ForEach(creatures) { creature in
                            if !creature.sorted {
                                Button(action: { selectedId = creature.id }) {
                                    AppAssets.image(creature.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 68)
                                        .padding(6)
                                        .frame(maxWidth: .infinity)
                                        .background(selectedId == creature.id ? PlayLandColors.sunOrange.opacity(0.3) : PlayLandColors.skyBlue.opacity(0.08))
                                        .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)

                    HStack(spacing: 20) {
                        sortBin(title: Loc.t("dino.sort.small"), emoji: "🐦", isBig: false)
                        sortBin(title: Loc.t("dino.sort.big"), emoji: "🦕", isBig: true)
                    }
                    .padding(.horizontal)

                    Text(Loc.t("dino.sort.mistakes", mistakes))
                        .font(PlayLandTypography.body)
                        .foregroundColor(PlayLandColors.secondaryText)
                }
                .padding()
            }
            .onAppear(perform: setupLevel)

            if showLevelComplete {
                CompletionCelebrationView(
                    title: levelCompleteTitle,
                    message: levelCompleteMessage,
                    stars: levelStars,
                    buttonTitle: level < totalLevels ? nextLevelTitle : Loc.t("action.continue"),
                    action: advanceLevel
                )
            }

            if isFinished {
                CompletionCelebrationView(
                    title: Loc.t("dino.sort.completeTitle"),
                    message: finalMessage,
                    stars: finalStars,
                    buttonTitle: Loc.t("dino.sort.completeButton"),
                    action: {
                        progressManager.completeGame("dino_sort", stars: finalStars)
                        if let onChallengeComplete { onChallengeComplete(finalStars) } else { dismiss() }
                    }
                )
            }
        }
    }

    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }
    private var levelLabel: String { isGreek ? "Επίπεδο \(level) από \(totalLevels)" : "Level \(level) of \(totalLevels)" }
    private var creatureCountLabel: String { isGreek ? "\(creatures.count) χαρακτήρες" : "\(creatures.count) characters" }
    private var levelCompleteTitle: String { isGreek ? "Σωστή ταξινόμηση!" : "Great sorting!" }
    private var levelCompleteMessage: String { isGreek ? "Στην επόμενη πίστα θα έχεις περισσότερους χαρακτήρες." : "The next level has more characters." }
    private var nextLevelTitle: String { isGreek ? "Επόμενη πίστα" : "Next level" }
    private var finalMessage: String { isGreek ? "Ολοκλήρωσες και τα \(totalLevels) επίπεδα ταξινόμησης." : "You completed all \(totalLevels) sorting levels." }
    private var levelStars: Int { mistakes == 0 ? 3 : (mistakes <= 2 ? 2 : 1) }
    private var finalStars: Int { totalMistakes <= 3 ? 3 : (totalMistakes <= 8 ? 2 : 1) }

    private func pool() -> [SortCreature] {
        [
            SortCreature(id: 0, imageName: AppAssets.Characters.babis, name: "Babis", isBig: true),
            SortCreature(id: 1, imageName: AppAssets.Characters.babisSide, name: "Babis", isBig: true),
            SortCreature(id: 2, imageName: "babis_happy", name: "Babis", isBig: true),
            SortCreature(id: 3, imageName: "babis_hungry", name: "Babis", isBig: true),
            SortCreature(id: 4, imageName: AppAssets.Characters.kotsifi, name: "Kotsifi", isBig: false),
            SortCreature(id: 5, imageName: AppAssets.Characters.kotsifiSide, name: "Kotsifi", isBig: false),
            SortCreature(id: 6, imageName: "kotsifi_happy", name: "Kotsifi", isBig: false),
            SortCreature(id: 7, imageName: AppAssets.Characters.fox, name: "Fox", isBig: false),
            SortCreature(id: 8, imageName: "fox_friendly", name: "Fox", isBig: false)
        ]
    }

    private func setupLevel() {
        // 6 creatures on the first level, growing to the full available pool.
        let count = min(pool().count, 5 + level)
        creatures = Array(pool().shuffled().prefix(count)).enumerated().map { offset, value in
            SortCreature(id: offset, imageName: value.imageName, name: value.name, isBig: value.isBig)
        }
        selectedId = nil
        mistakes = 0
        showLevelComplete = false
    }

    private func sortBin(title: String, emoji: String, isBig: Bool) -> some View {
        Button(action: { sort(intoBig: isBig) }) {
            VStack(spacing: 8) {
                Text(emoji).font(.system(size: 40))
                Text(title).font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .frame(minHeight: PlayLandMetrics.primaryTouchTarget)
            .background(PlayLandColors.warmCream)
            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge))
            .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
        }
        .disabled(selectedId == nil)
    }

    private func sort(intoBig big: Bool) {
        guard let selectedId, let index = creatures.firstIndex(where: { $0.id == selectedId }) else { return }
        if creatures[index].isBig == big {
            creatures[index].sorted = true
            AudioManager.shared.play(.correct)
        } else {
            mistakes += 1
            totalMistakes += 1
            AudioManager.shared.play(.wrong)
        }
        self.selectedId = nil
        if creatures.allSatisfy({ $0.sorted }) { withAnimation { showLevelComplete = true } }
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
