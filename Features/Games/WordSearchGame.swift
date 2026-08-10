import SwiftUI

private struct CellPos: Hashable {
    let row: Int
    let col: Int
}

struct WordSearchGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @Environment(\.dismiss) var dismiss

    private let targetWords = ["DINO", "BIRD", "FOX"]
    private let columns = 5
    private let rows = 5

    @State private var grid: [[Character]] = []
    @State private var selection: [CellPos] = []
    @State private var foundWords: Set<String> = []
    @State private var foundCells: Set<CellPos> = []
    @State private var showWrong = false
    @State private var mistakes = 0
    @State private var isFinished = false

    var body: some View {
        ZStack {
            VStack(spacing: 18) {
                GameHeader(title: "Word Search", subtitle: "Tap the letters in order to spell a word!")

                HStack(spacing: 12) {
                    ForEach(targetWords, id: \.self) { word in
                        Text(word)
                            .font(.subheadline.weight(.bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(foundWords.contains(word) ? PlayLandColors.leafGreen.opacity(0.3) : PlayLandColors.skyBlue.opacity(0.12))
                            .strikethrough(foundWords.contains(word))
                            .clipShape(Capsule())
                    }
                }

                VStack(spacing: 8) {
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(spacing: 8) {
                            ForEach(0..<columns, id: \.self) { col in
                                letterCell(row: row, col: col)
                            }
                        }
                    }
                }

                HStack(spacing: 16) {
                    PlayLandSecondaryButton(title: "Clear") { selection = [] }

                    PlayLandPrimaryButton(title: "Check Word", color: PlayLandColors.skyBlue) { checkSelection() }
                        .disabled(selection.isEmpty)
                }

                Spacer()
            }
            .padding()
            .onAppear(perform: setupGrid)

            if isFinished {
                CompletionCelebrationView(
                    title: "Words Found!",
                    message: "You found every word with \(mistakes) mistakes.",
                    stars: stars,
                    buttonTitle: "Continue",
                    action: {
                        progressManager.completeGame("word_search", stars: stars)
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

    private func letterCell(row: Int, col: Int) -> some View {
        let pos = CellPos(row: row, col: col)
        let isSelected = selection.contains(pos)
        let isFound = foundCells.contains(pos)

        return Button(action: { tap(pos) }) {
            Text(grid.isEmpty ? "" : String(grid[row][col]))
                .font(.title3.weight(.bold))
                .frame(width: 48, height: 48)
                .background(
                    isFound ? PlayLandColors.leafGreen.opacity(0.35)
                    : (isSelected ? (showWrong ? Color.red.opacity(0.4) : PlayLandColors.sunOrange.opacity(0.4)) : PlayLandColors.skyBlue.opacity(0.1))
                )
                .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusSmall))
        }
        .disabled(isFound)
    }

    private func tap(_ pos: CellPos) {
        if selection.last == pos {
            selection.removeLast()
        } else if !selection.contains(pos) {
            selection.append(pos)
        }
    }

    private func checkSelection() {
        let letters = String(selection.map { grid[$0.row][$0.col] })
        if let word = targetWords.first(where: { $0 == letters && !foundWords.contains($0) }) {
            foundWords.insert(word)
            foundCells.formUnion(selection)
            selection = []
            if foundWords.count == targetWords.count {
                withAnimation { isFinished = true }
            }
        } else {
            mistakes += 1
            showWrong = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showWrong = false
                selection = []
            }
        }
    }

    private func setupGrid() {
        var newGrid: [[Character]] = (0..<rows).map { _ in
            (0..<columns).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".randomElement()! }
        }
        for (index, word) in targetWords.enumerated() where index < rows {
            for (col, letter) in word.enumerated() where col < columns {
                newGrid[index][col] = letter
            }
        }
        grid = newGrid
        selection = []
        foundWords = []
        foundCells = []
        mistakes = 0
        isFinished = false
    }
}
