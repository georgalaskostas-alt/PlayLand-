import SwiftUI

struct MiniGamesModeView: View {
    @EnvironmentObject var progressManager: ProgressViewModel

    let miniGames = [
        MenuItem(id: "letter_recognition", title: "Letter Recognition", description: "Learn your ABCs!", iconImageName: "icon_letter_game"),
        MenuItem(id: "word_matching", title: "Word Matching", description: "Match the picture to the word!", iconImageName: "icon_word_match"),
        MenuItem(id: "word_scramble", title: "Word Scramble", description: "Unscramble the letters!", iconImageName: "icon_word_scramble"),
        MenuItem(id: "memory_game", title: "Memory Game", description: "Train your memory!", iconImageName: "icon_memory_game")
    ]

    var body: some View {
        List {
            Section(header: Text("Mini-Games")) {
                ForEach(miniGames) { game in
                    NavigationLink(destination: gameView(for: game)) {
                        GameRow(item: game, isCompleted: progressManager.isGameCompleted(game.id))
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
