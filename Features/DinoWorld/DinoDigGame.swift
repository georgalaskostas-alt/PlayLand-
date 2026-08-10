import SwiftUI

private struct DigTile: Identifiable {
    let id: Int
    let hasBone: Bool
    var isRevealed = false
}

struct DinoDigGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    private let totalBones = 5
    private let gridSize = 9

    @State private var tiles: [DigTile] = []
    @State private var bonesFound = 0
    @State private var taps = 0
    @State private var isFinished = false

    var body: some View {
        ZStack {
            ScrollView {
            VStack(spacing: 20) {
                GameHeader(title: Loc.t("dino.dig.title"), subtitle: Loc.t("dino.dig.instruction", totalBones))

                HStack {
                    Text("🦴 \(bonesFound)/\(totalBones)")
                        .font(PlayLandTypography.heading)
                        .foregroundColor(PlayLandColors.sunOrange)
                }

                LazyVGrid(columns: Array(repeating: GridItem(spacing: 12), count: 3), spacing: 12) {
                    ForEach(tiles) { tile in
                        Button(action: { dig(tile) }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium)
                                    .fill(tile.isRevealed
                                          ? (tile.hasBone ? PlayLandColors.sunOrange.opacity(0.25) : Color.brown.opacity(0.15))
                                          : Color.brown.opacity(0.55))

                                Text(tile.isRevealed ? (tile.hasBone ? "🦴" : "🪨") : "⛏️")
                                    .font(.system(size: 34))
                            }
                            .frame(height: 90)
                        }
                        .disabled(tile.isRevealed)
                        .accessibilityLabel(Text(tile.isRevealed ? (tile.hasBone ? "🦴" : "🪨") : Loc.t("dino.dig.title")))
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .onAppear(perform: setupTiles)
            }

            if isFinished {
                CompletionCelebrationView(
                    title: Loc.t("dino.dig.completeTitle"),
                    message: Loc.t("dino.dig.completeMessage", taps),
                    stars: stars,
                    buttonTitle: Loc.t("dino.dig.completeButton"),
                    action: {
                        progressManager.completeGame("dino_dig", stars: stars)
                        dismiss()
                    }
                )
            }
        }
    }

    private var stars: Int {
        if taps <= gridSize { return 3 }
        if taps <= gridSize + 3 { return 2 }
        return 1
    }

    private func setupTiles() {
        var boneIndices = Set<Int>()
        while boneIndices.count < totalBones {
            boneIndices.insert(Int.random(in: 0..<gridSize))
        }
        tiles = (0..<gridSize).map { DigTile(id: $0, hasBone: boneIndices.contains($0)) }
        bonesFound = 0
        taps = 0
        isFinished = false
    }

    private func dig(_ tile: DigTile) {
        guard let index = tiles.firstIndex(where: { $0.id == tile.id }), !tiles[index].isRevealed else { return }
        tiles[index].isRevealed = true
        taps += 1
        if tiles[index].hasBone {
            bonesFound += 1
            AudioManager.shared.play(.correct)
        }
        if bonesFound == totalBones {
            withAnimation { isFinished = true }
        }
    }
}
