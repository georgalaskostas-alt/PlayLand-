import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            GamesListView()
                .tabItem { Label("Games", image: "ui_gamepad") }
                .tag(0)

            StoriesListView()
                .tabItem { Label("Stories", image: "ui_book") }
                .tag(1)

            DinoGamesListView()
                .tabItem { Label("Dino World", image: "ui_paw") }
                .tag(2)

            RPGAdventureView()
                .tabItem { Label("Adventure", image: "ui_map") }
                .tag(3)

            ParentalGateView()
                .tabItem { Label("Parents", image: "ui_lock") }
                .tag(4)
        }
        .accentColor(PlayLandTheme.sunOrange)
    }
}
