import SwiftUI

struct MiniGamesModeView: View {
    @EnvironmentObject var progressManager: ProgressViewModel

    let miniGames = [
        MenuItem(id: "letter_recognition", title: "Letter Recognition", description: "Learn your ABCs!", iconImageName: AppAssets.GameIcons.letterGame),
        MenuItem(id: "word_matching", title: "Word Matching", description: "Match the picture to the word!", iconImageName: AppAssets.PlannedGameIcons.wordMatch),
        MenuItem(id: "word_scramble", title: "Word Scramble", description: "Unscramble the letters!", iconImageName: AppAssets.PlannedGameIcons.wordScramble),
        MenuItem(id: "memory_game", title: "Memory Game", description: "Train your memory!", iconImageName: AppAssets.PlannedGameIcons.memoryGame)
    ]

    var body: some View {
        List {
            Section(header: Text("Mini-Games")) {
                ForEach(miniGames) { game in
                    NavigationLink(destination: gameView(for: game)) {
                        GameCard(
                            item: game,
                            isCompleted: progressManager.isGameCompleted(game.id),
                            bestStars: progressManager.bestStars(forGame: game.id)
                        )
                    }
                }
            }
        }
        .navigationTitle("Mini-Games")
    }

    @ViewBuilder
    private func gameView(for game: MenuItem) -> some View {
        switch game.id {
        case "letter_recognition":
            LetterRecognitionGame()
        case "word_matching":
            WordMatchingGame()
        case "word_scramble":
            WordScrambleGame()
        case "memory_game":
            MemoryGame()
        default:
            Text("Coming soon!")
        }
    }
}
