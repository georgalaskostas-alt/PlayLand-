import SwiftUI

struct DinoGamesListView: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings

    private var games: [MenuItem] {
        [
            MenuItem(id: "dino_dig", title: Loc.t("dino.dig.title"), description: Loc.t("dino.dig.desc"), iconImageName: AppAssets.PlannedGameIcons.dinoDig),
            MenuItem(id: "dino_match", title: Loc.t("dino.match.title"), description: Loc.t("dino.match.desc"), iconImageName: AppAssets.PlannedGameIcons.dinoMatch),
            MenuItem(id: "dino_farm", title: Loc.t("dino.farm.title"), description: Loc.t("dino.farm.desc"), iconImageName: AppAssets.PlannedGameIcons.dinoFarm),
            MenuItem(id: "dino_sort", title: Loc.t("dino.sort.title"), description: Loc.t("dino.sort.desc"), iconImageName: AppAssets.PlannedGameIcons.dinoSort)
        ]
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text(Loc.t("dino.sectionHeader"))) {
                    ForEach(games) { game in
                        NavigationLink(destination: dinoView(for: game)) {
                            GameCard(
                                item: game,
                                isCompleted: progressManager.isGameCompleted(game.id),
                                bestStars: progressManager.bestStars(forGame: game.id)
                            )
                        }
                    }
                }
            }
            .navigationTitle(Loc.t("dino.navTitle"))
            .navigationBarTitleDisplayMode(.large)
        }
    }

    @ViewBuilder
    private func dinoView(for game: MenuItem) -> some View {
        switch game.id {
        case "dino_dig": DinoDigGame()
        case "dino_match": DinoMatchGame()
        case "dino_farm": DinoFarmGame()
        case "dino_sort": DinoSortGame()
        default: EmptyView()
        }
    }
}
