import SwiftUI

struct DinoGamesListView: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    
    let games = [
        DinoGame(id: "dino_dig", title: "Dino Dig", description: "Excavate fossils!", iconImageName: "icon_dino_dig"),
        DinoGame(id: "dino_match", title: "Dino Match", description: "Match dinos!", iconImageName: "icon_dino_match"),
        DinoGame(id: "dino_farm", title: "Dino Farm", description: "Care for dinos!", iconImageName: "icon_dino_farm"),
        DinoGame(id: "dino_sort", title: "Dino Sort", description: "Sort by type!", iconImageName: "icon_dino_sort")
    ]

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("🦖 Dino Games")) {
                    ForEach(games) { game in
                        NavigationLink(destination: dinoView(for: game)) {
                            HStack {
                                Image(game.iconImageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(12)
                                    .shadow(radius: 3)

                                
                                VStack(alignment: .leading) {
                                    Text(game.title).font(.headline)
                                    Text(game.description).font(.subheadline).foregroundColor(.gray)
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dino World")
        }
    }
    
    @ViewBuilder
    private func dinoView(for game: DinoGame) -> some View {
        switch game.id {
        case "dino_dig": DinoDigGame()
        case "dino_match": DinoMatchGame()
        case "dino_farm": DinoFarmGame()
        case "dino_sort": DinoSortGame()
        default: Text("Coming soon!")
        }
    }
}

struct DinoGame: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
}
