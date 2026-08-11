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

    /// See `MemoryGame.onChallengeComplete`.
    var onChallengeComplete: ((Int) -> Void)?

    @State private var creatures: [SortCreature] = [
        SortCreature(id: 0, imageName: AppAssets.Characters.babis, name: "Babis", isBig: true),
        SortCreature(id: 1, imageName: AppAssets.Characters.babisSide, name: "Babis", isBig: true),
        SortCreature(id: 2, imageName: AppAssets.Characters.kotsifi, name: "Kotsifi", isBig: false),
        SortCreature(id: 3, imageName: AppAssets.Characters.kotsifiSide, name: "Kotsifi", isBig: false),
        SortCreature(id: 4, imageName: AppAssets.Characters.fox, name: "Alepou", isBig: false)
    ]
    @State private var selectedId: Int?
    @State private var mistakes = 0
    @State private var isFinished = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                GameHeader(title: Loc.t("dino.sort.title"), subtitle: Loc.t("dino.sort.instruction"))

                LazyVGrid(columns: Array(repeating: GridItem(spacing: 12), count: 5), spacing: 12) {
                    ForEach(creatures) { creature in
                        if !creature.sorted {
                            Button(action: { selectedId = creature.id }) {
                                AppAssets.image(creature.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(6)
                                    .background(selectedId == creature.id ? PlayLandColors.sunOrange.opacity(0.3) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
                            }
                        }
                    }
                }
                .frame(height: 90)
                .padding(.horizontal)

                HStack(spacing: 20) {
                    sortBin(title: Loc.t("dino.sort.small"), emoji: "🐦", isBig: false)
                    sortBin(title: Loc.t("dino.sort.big"), emoji: "🦕", isBig: true)
                }
                .padding(.horizontal)

                Text(Loc.t("dino.sort.mistakes", mistakes))
                    .font(PlayLandTypography.body)
                    .foregroundColor(PlayLandColors.secondaryText)

                Spacer()
            }
            .padding()

            if isFinished {
                CompletionCelebrationView(
                    title: Loc.t("dino.sort.completeTitle"),
                    message: Loc.t("dino.sort.completeMessage", mistakes),
                    stars: stars,
                    buttonTitle: Loc.t("dino.sort.completeButton"),
                    action: {
                        progressManager.completeGame("dino_sort", stars: stars)
                        if let onChallengeComplete {
                            onChallengeComplete(stars)
                        } else {
                            dismiss()
                        }
                    }
                )
            }
        }
    }

    private var stars: Int {
        if mistakes == 0 { return 3 }
        if mistakes <= 2 { return 2 }
        return 1
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
            AudioManager.shared.play(.wrong)
        }
        self.selectedId = nil

        if creatures.allSatisfy({ $0.sorted }) {
            withAnimation { isFinished = true }
        }
    }
}
