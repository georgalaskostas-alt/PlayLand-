import SwiftUI

struct GamesListView: View {
    @EnvironmentObject var progressManager: ProgressViewModel

    let games = [
        MenuItem(id: "letter_recognition", title: "Letter Recognition", description: "Learn your ABCs!", iconImageName: AppAssets.GameIcons.letterGame),
        MenuItem(id: "word_matching", title: "Word Matching", description: "Match the picture to the word!", iconImageName: AppAssets.PlannedGameIcons.wordMatch),
        MenuItem(id: "word_search", title: "Word Search", description: "Find hidden words!", iconImageName: AppAssets.PlannedGameIcons.wordSearch),
        MenuItem(id: "word_scramble", title: "Word Scramble", description: "Unscramble the letters!", iconImageName: AppAssets.PlannedGameIcons.wordScramble),
        MenuItem(id: "memory_game", title: "Memory Game", description: "Train your memory!", iconImageName: AppAssets.PlannedGameIcons.memoryGame)
    ]

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Learning Games")) {
                    ForEach(games) { game in
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
            .navigationTitle("PlayLand")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    @ViewBuilder
    private func gameView(for game: MenuItem) -> some View {
        switch game.id {
        case "letter_recognition":
            LetterRecognitionGame()
        case "word_matching":
            WordMatchingGame()
        case "word_search":
            WordSearchGame()
        case "word_scramble":
            WordScrambleGame()
        case "memory_game":
            MemoryGame()
        default:
            Text("Game coming soon!")
        }
    }
}
