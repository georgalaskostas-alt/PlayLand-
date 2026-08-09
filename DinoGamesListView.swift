import SwiftUI

struct DinoGamesListView: View {
    @EnvironmentObject var progressManager: ProgressViewModel

    let games = [
        MenuItem(id: "dino_dig", title: "Dino Dig", description: "Excavate hidden fossils!", iconImageName: "icon_dino_dig"),
        MenuItem(id: "dino_match", title: "Dino Match", description: "Match pairs of dino friends!", iconImageName: "icon_dino_match"),
        MenuItem(id: "dino_farm", title: "Dino Farm", description: "Feed and care for Babis!", iconImageName: "icon_dino_farm"),
        MenuItem(id: "dino_sort", title: "Dino Sort", description: "Sort dinos big or small!", iconImageName: "icon_dino_sort")
    ]

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Dino Games")) {
                    ForEach(games) { game in
                        NavigationLink(destination: dinoView(for: game)) {
                            GameRow(item: game, isCompleted: progressManager.isGameCompleted(game.id))
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
