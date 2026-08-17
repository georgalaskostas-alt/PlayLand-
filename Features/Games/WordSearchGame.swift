import SwiftUI

private struct CellPos: Hashable {
    let row: Int
    let col: Int
}

struct WordSearchGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    private let totalLevels = 6

    @State private var level = 1
    @State private var targetWords: [String] = []
    @State private var grid: [[Character]] = []
    @State private var selection: [CellPos] = []
    @State private var foundWords: Set<String> = []
    @State private var foundCells: Set<CellPos> = []
    @State private var showWrong = false
    @State private var mistakes = 0
    @State private var totalMistakes = 0
    @State private var showLevelComplete = false
    @State private var isFinished = false

    private var gridSize: Int { level <= 3 ? 7 : 8 }
    private var wordCount: Int { min(7, 2 + level) }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(title: Loc.t("game.wordSearch.title"), subtitle: Loc.t("game.wordSearch.instruction"))

                    HStack {
                        Text(levelLabel)
                            .font(PlayLandTypography.heading)
                            .foregroundColor(PlayLandColors.sunOrange)
                        Spacer()
                        Text(boardLabel)
                            .font(PlayLandTypography.caption)
                            .foregroundColor(PlayLandColors.secondaryText)
                    }

                    FlowLayout(spacing: 8) {
                        ForEach(targetWords, id: \.self) { word in
                            HStack(spacing: 4) {
                                Text(word).font(.subheadline.weight(.bold))
                                if !foundWords.contains(word) {
                                    SpeakerButton(text: Loc.t("game.wordSearch.findWord", word))
                                        .frame(width: 24, height: 24)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(foundWords.contains(word) ? PlayLandColors.leafGreen.opacity(0.3) : PlayLandColors.skyBlue.opacity(0.12))
                            .strikethrough(foundWords.contains(word))
                            .clipShape(Capsule())
                        }
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: gridSize), spacing: 4) {
                        ForEach(0..<(gridSize * gridSize), id: \.self) { flat in
                            letterCell(row: flat / gridSize, col: flat % gridSize)
                        }
                    }
                    .padding(.horizontal, 2)

                    HStack(spacing: 16) {
                        PlayLandSecondaryButton(title: Loc.t("action.clear")) { selection = [] }
                        PlayLandPrimaryButton(title: Loc.t("action.checkWord"), color: PlayLandColors.skyBlue) { checkSelection() }
                            .disabled(selection.isEmpty)
                    }
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
                    title: Loc.t("game.wordSearch.completeTitle"),
                    message: finalMessage,
                    stars: finalStars,
                    buttonTitle: Loc.t("action.continue"),
                    action: {
                        progressManager.completeGame("word_search", stars: finalStars)
                        dismiss()
                    }
                )
            }
        }
    }

    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }
    private var levelLabel: String { isGreek ? "Επίπεδο \(level) από \(totalLevels)" : "Level \(level) of \(totalLevels)" }
    private var boardLabel: String { isGreek ? "\(gridSize)×\(gridSize) · \(targetWords.count) λέξεις" : "\(gridSize)×\(gridSize) · \(targetWords.count) words" }
    private var levelCompleteTitle: String { isGreek ? "Βρήκες όλες τις λέξεις!" : "You found every word!" }
    private var levelCompleteMessage: String { isGreek ? "Η επόμενη πίστα έχει μεγαλύτερο πλέγμα και περισσότερες λέξεις." : "The next board has a larger grid and more words." }
    private var nextLevelTitle: String { isGreek ? "Επόμενη πίστα" : "Next level" }
    private var finalMessage: String { isGreek ? "Ολοκλήρωσες και τις \(totalLevels) πίστες με \(totalMistakes) λάθη." : "You completed all \(totalLevels) boards with \(totalMistakes) mistakes." }
    private var levelStars: Int { mistakes == 0 ? 3 : (mistakes <= 2 ? 2 : 1) }
    private var finalStars: Int { totalMistakes <= 3 ? 3 : (totalMistakes <= 8 ? 2 : 1) }

    private func letterCell(row: Int, col: Int) -> some View {
        let pos = CellPos(row: row, col: col)
        let isSelected = selection.contains(pos)
        let isFound = foundCells.contains(pos)

        return Button(action: { tap(pos) }) {
            Text(grid.isEmpty ? "" : String(grid[row][col]))
                .font((gridSize >= 8 ? Font.body : Font.title3).weight(.bold))
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(isFound ? PlayLandColors.leafGreen.opacity(0.35) : (isSelected ? (showWrong ? Color.red.opacity(0.4) : PlayLandColors.sunOrange.opacity(0.4)) : PlayLandColors.skyBlue.opacity(0.1)))
                .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusSmall))
        }
        .disabled(isFound)
    }

    private func tap(_ pos: CellPos) {
        if selection.last == pos {
            selection.removeLast()
            return
        }
        guard !selection.contains(pos) else { return }
        if let last = selection.last {
            let sameRow = last.row == pos.row && abs(last.col - pos.col) == 1
            let sameColumn = last.col == pos.col && abs(last.row - pos.row) == 1
            guard sameRow || sameColumn else { return }
        }
        selection.append(pos)
    }

    private func checkSelection() {
        let letters = String(selection.map { grid[$0.row][$0.col] })
        let reverse = String(letters.reversed())
        if let word = targetWords.first(where: { ($0 == letters || $0 == reverse) && !foundWords.contains($0) }) {
            foundWords.insert(word)
            foundCells.formUnion(selection)
            selection = []
            AudioManager.shared.play(.correct)
            if foundWords.count == targetWords.count { withAnimation { showLevelComplete = true } }
        } else {
            mistakes += 1
            totalMistakes += 1
            showWrong = true
            AudioManager.shared.play(.wrong)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showWrong = false
                selection = []
            }
        }
    }

    private func setupLevel() {
        let all = LearningContentProvider.searchWords(for: appSettings.resolvedLanguage).filter { $0.count <= gridSize }
        targetWords = Array(all.shuffled().prefix(min(wordCount, all.count)))
        let alphabet = appSettings.resolvedLanguage == .greek ? "ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ" : "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

        var newGrid: [[Character]] = (0..<gridSize).map { _ in (0..<gridSize).map { _ in alphabet.randomElement()! } }
        for (index, word) in targetWords.enumerated() where index < gridSize {
            let reversed = level >= 4 && index.isMultiple(of: 2)
            let letters = Array(reversed ? String(word.reversed()) : word)
            for (col, letter) in letters.enumerated() where col < gridSize {
                newGrid[index][col] = letter
            }
        }
        grid = newGrid
        selection = []
        foundWords = []
        foundCells = []
        mistakes = 0
        showLevelComplete = false
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

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 320
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 { x = 0; y += rowHeight + spacing; rowHeight = 0 }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX { x = bounds.minX; y += rowHeight + spacing; rowHeight = 0 }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
