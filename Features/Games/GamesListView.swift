import SwiftUI

struct GamesListView: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings

    private var games: [MenuItem] {
        [
            MenuItem(id: "art_studio", title: appSettings.resolvedLanguage == .greek ? "Εργαστήριο Ζωγραφικής" : "Art Studio", description: appSettings.resolvedLanguage == .greek ? "Ζωγράφισε, χρωμάτισε και δημιούργησε με όλες τις συλλογές σχεδίων." : "Draw, color and create with all drawing collections.", iconImageName: "butterfly_rpg_neutral"),
            MenuItem(id: "letter_recognition", title: Loc.t("game.letterRecognition.title"), description: Loc.t("game.letterRecognition.desc"), iconImageName: AppAssets.GameIcons.letterGame),
            MenuItem(id: "word_matching", title: Loc.t("game.wordMatching.title"), description: Loc.t("game.wordMatching.desc"), iconImageName: "butterfly_rpg_neutral"),
            MenuItem(id: "word_search", title: Loc.t("game.wordSearch.title"), description: Loc.t("game.wordSearch.desc"), iconImageName: "owl_rpg_neutral"),
            MenuItem(id: "word_scramble", title: Loc.t("game.wordScramble.title"), description: Loc.t("game.wordScramble.desc"), iconImageName: "ladybug_rpg_neutral"),
            MenuItem(id: "memory_game", title: Loc.t("game.memoryGame.title"), description: Loc.t("game.memoryGame.desc"), iconImageName: "forest_spirit_rpg_neutral")
        ]
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text(Loc.t("games.sectionHeader"))) {
                    ForEach(games) { game in
                        NavigationLink(destination: gameView(for: game)) {
                            GameCard(item: game, isCompleted: progressManager.isGameCompleted(game.id), bestStars: progressManager.bestStars(forGame: game.id))
                        }
                    }
                }
            }
            .navigationTitle(Loc.t("games.navTitle"))
            .navigationBarTitleDisplayMode(.large)
        }
    }

    @ViewBuilder
    private func gameView(for game: MenuItem) -> some View {
        switch game.id {
        case "art_studio": ArtStudioCollectionsView()
        case "letter_recognition": LetterRecognitionGame()
        case "word_matching": WordMatchingGame()
        case "word_search": WordSearchGame()
        case "word_scramble": WordScrambleGame()
        case "memory_game": MemoryGame()
        default: EmptyView()
        }
    }
}
