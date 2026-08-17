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

    @State private var level = 1
    @State private var tiles: [DigTile] = []
    @State private var bonesFound = 0
    @State private var taps = 0
    @State private var totalTaps = 0
    @State private var showLevelComplete = false
    @State private var isFinished = false

    private let totalLevels = 6

    /// The dig now starts at 16 tiles and grows to 25 tiles, so each site feels
    /// like a real excavation instead of a quick 3x3 tap board.
    private var gridSide: Int {
        switch level {
        case 1...2: return 4
        default: return 5
        }
    }

    private var gridSize: Int { gridSide * gridSide }
    private var totalBones: Int { min(gridSize - 5, 4 + level) }
    private var tileHeight: CGFloat { gridSide == 4 ? 72 : 58 }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    GameHeader(title: Loc.t("dino.dig.title"), subtitle: Loc.t("dino.dig.instruction", totalBones))
                    Text(levelLabel)
                        .font(PlayLandTypography.heading)
                        .foregroundColor(PlayLandColors.sunOrange)
                    Text("🦴 \(bonesFound)/\(totalBones)")
                        .font(PlayLandTypography.heading)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: gridSide), spacing: 8) {
                        ForEach(tiles) { tile in
                            Button(action: { dig(tile) }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium)
                                        .fill(tile.isRevealed ? (tile.hasBone ? PlayLandColors.sunOrange.opacity(0.25) : Color.brown.opacity(0.15)) : Color.brown.opacity(0.55))
                                    Text(tile.isRevealed ? (tile.hasBone ? "🦴" : "🪨") : "⛏️")
                                        .font(.system(size: gridSide == 4 ? 30 : 25))
                                }
                                .frame(height: tileHeight)
                            }
                            .disabled(tile.isRevealed)
                        }
                    }
                    .padding(.horizontal, 8)

                    Text(siteSizeLabel)
                        .font(PlayLandTypography.caption)
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
                    title: Loc.t("dino.dig.completeTitle"),
                    message: finalMessage,
                    stars: finalStars,
                    buttonTitle: Loc.t("dino.dig.completeButton"),
                    action: {
                        progressManager.completeGame("dino_dig", stars: finalStars)
                        dismiss()
                    }
                )
            }
        }
    }

    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }
    private var levelLabel: String { isGreek ? "Ανασκαφή \(level) από \(totalLevels)" : "Dig site \(level) of \(totalLevels)" }
    private var siteSizeLabel: String { isGreek ? "Πεδίο \(gridSize) θέσεων" : "\(gridSize)-tile excavation" }
    private var levelCompleteTitle: String { isGreek ? "Βρήκες τα απολιθώματα!" : "Fossils found!" }
    private var levelCompleteMessage: String { isGreek ? "Η επόμενη ανασκαφή είναι μεγαλύτερη και πιο δύσκολη." : "The next dig site is larger and more challenging." }
    private var nextLevelTitle: String { isGreek ? "Επόμενη ανασκαφή" : "Next dig" }
    private var finalMessage: String { isGreek ? "Ολοκλήρωσες και τις \(totalLevels) μεγάλες ανασκαφές!" : "You completed all \(totalLevels) large dig sites!" }
    private var levelStars: Int { taps <= totalBones + 3 ? 3 : (taps <= totalBones + 7 ? 2 : 1) }
    private var finalStars: Int { totalTaps <= 80 ? 3 : (totalTaps <= 110 ? 2 : 1) }

    private func setupLevel() {
        var boneIndices = Set<Int>()
        while boneIndices.count < totalBones { boneIndices.insert(Int.random(in: 0..<gridSize)) }
        tiles = (0..<gridSize).map { DigTile(id: $0, hasBone: boneIndices.contains($0)) }
        bonesFound = 0
        taps = 0
        showLevelComplete = false
    }

    private func dig(_ tile: DigTile) {
        guard let index = tiles.firstIndex(where: { $0.id == tile.id }), !tiles[index].isRevealed else { return }
        tiles[index].isRevealed = true
        taps += 1
        totalTaps += 1
        if tiles[index].hasBone {
            bonesFound += 1
            AudioManager.shared.play(.correct)
        }
        if bonesFound == totalBones { withAnimation { showLevelComplete = true } }
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
