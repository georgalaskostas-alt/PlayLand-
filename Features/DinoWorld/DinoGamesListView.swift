import SwiftUI

struct DinoGamesListView: View {
    @EnvironmentObject var progressManager: ProgressViewModel

    let games = [
        MenuItem(id: "dino_dig", title: "Dino Dig", description: "Excavate hidden fossils!", iconImageName: AppAssets.PlannedGameIcons.dinoDig),
        MenuItem(id: "dino_match", title: "Dino Match", description: "Match pairs of dino friends!", iconImageName: AppAssets.PlannedGameIcons.dinoMatch),
        MenuItem(id: "dino_farm", title: "Dino Farm", description: "Feed and care for Babis!", iconImageName: AppAssets.PlannedGameIcons.dinoFarm),
        MenuItem(id: "dino_sort", title: "Dino Sort", description: "Sort dinos big or small!", iconImageName: AppAssets.PlannedGameIcons.dinoSort)
    ]

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Dino Games")) {
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
            .navigationTitle("Dino World")
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
        default: Text("Coming soon!")
        }
    }
}
