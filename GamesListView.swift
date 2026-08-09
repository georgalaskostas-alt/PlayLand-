import SwiftUI

struct GamesListView: View {
    @EnvironmentObject var progressManager: ProgressViewModel

    let games = [
        MenuItem(id: "letter_recognition", title: "Letter Recognition", description: "Learn your ABCs!", iconImageName: "icon_letter_game"),
        MenuItem(id: "word_matching", title: "Word Matching", description: "Match the picture to the word!", iconImageName: "icon_word_match"),
        MenuItem(id: "word_search", title: "Word Search", description: "Find hidden words!", iconImageName: "icon_word_search"),
        MenuItem(id: "word_scramble", title: "Word Scramble", description: "Unscramble the letters!", iconImageName: "icon_word_scramble"),
        MenuItem(id: "memory_game", title: "Memory Game", description: "Train your memory!", iconImageName: "icon_memory_game")
    ]

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Learning Games")) {
                    ForEach(games) { game in
                        NavigationLink(destination: gameView(for: game)) {
                            GameRow(item: game, isCompleted: progressManager.isGameCompleted(game.id))
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

struct GameRow: View {
    let item: MenuItem
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 14) {
            RoundedIconTile(imageName: item.iconImageName)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if isCompleted {
                    HStack(spacing: 4) {
                        Image("ui_check")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("Completed!")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(PlayLandTheme.leafGreen)
                    }
                }
            }

            Spacer()

            if isCompleted {
                Image("ui_star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
            }
        }
        .padding(.vertical, 6)
    }
}
