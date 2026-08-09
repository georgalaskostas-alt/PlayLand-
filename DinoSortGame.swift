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
    @Environment(\.dismiss) var dismiss

    @State private var creatures: [SortCreature] = [
        SortCreature(id: 0, imageName: "babis_dinosaur", name: "Babis", isBig: true),
        SortCreature(id: 1, imageName: "babis_dinosaur_side", name: "Babis", isBig: true),
        SortCreature(id: 2, imageName: "kotsifi_bird", name: "Kotsifi", isBig: false),
        SortCreature(id: 3, imageName: "kotsifi_bird_side", name: "Kotsifi", isBig: false),
        SortCreature(id: 4, imageName: "alepou_fox", name: "Alepou", isBig: false)
    ]
    @State private var selectedId: Int?
    @State private var mistakes = 0
    @State private var isFinished = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Dino Sort")
                    .font(.largeTitle.bold())

                Text("Tap a friend, then tap Big or Small!")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                LazyVGrid(columns: Array(repeating: GridItem(spacing: 12), count: 5), spacing: 12) {
                    ForEach(creatures) { creature in
                        if !creature.sorted {
                            Button(action: { selectedId = creature.id }) {
                                Image(creature.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(6)
                                    .background(selectedId == creature.id ? PlayLandTheme.sunOrange.opacity(0.3) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }
                }
                .frame(height: 90)
                .padding(.horizontal)

                HStack(spacing: 20) {
                    sortBin(title: "Small", emoji: "🐦", isBig: false)
                    sortBin(title: "Big", emoji: "🦕", isBig: true)
                }
                .padding(.horizontal)

                Text("Mistakes: \(mistakes)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()

            if isFinished {
                CompletionBadgeView(
                    title: "All Sorted!",
                    message: "You sorted everyone with \(mistakes) mistakes.",
                    stars: stars,
                    buttonTitle: "Well done!",
                    action: {
                        progressManager.completeGame("dino_sort", stars: stars)
                        dismiss()
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
            .background(PlayLandTheme.warmCream)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
        }
        .disabled(selectedId == nil)
    }

    private func sort(intoBig big: Bool) {
        guard let selectedId, let index = creatures.firstIndex(where: { $0.id == selectedId }) else { return }

        if creatures[index].isBig == big {
            creatures[index].sorted = true
        } else {
            mistakes += 1
        }
        self.selectedId = nil

        if creatures.allSatisfy({ $0.sorted }) {
            withAnimation { isFinished = true }
        }
    }
}
