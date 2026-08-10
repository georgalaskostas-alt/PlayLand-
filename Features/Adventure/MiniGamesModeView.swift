import SwiftUI

struct MiniGamesModeView: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings

    private var miniGames: [MenuItem] {
        [
            MenuItem(id: "letter_recognition", title: Loc.t("game.letterRecognition.title"), description: Loc.t("game.letterRecognition.desc"), iconImageName: AppAssets.GameIcons.letterGame),
            MenuItem(id: "word_matching", title: Loc.t("game.wordMatching.title"), description: Loc.t("game.wordMatching.desc"), iconImageName: AppAssets.PlannedGameIcons.wordMatch),
            MenuItem(id: "word_scramble", title: Loc.t("game.wordScramble.title"), description: Loc.t("game.wordScramble.desc"), iconImageName: AppAssets.PlannedGameIcons.wordScramble),
            MenuItem(id: "memory_game", title: Loc.t("game.memoryGame.title"), description: Loc.t("game.memoryGame.desc"), iconImageName: AppAssets.PlannedGameIcons.memoryGame)
        ]
    }

    var body: some View {
        List {
            Section(header: Text(Loc.t("adventure.mode.minigames.title"))) {
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
        .navigationTitle(Loc.t("adventure.mode.minigames.title"))
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
            EmptyView()
        }
    }
}
