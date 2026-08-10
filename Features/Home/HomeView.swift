import SwiftUI

/// The five destinations reachable from the tab bar. Kept as a typed enum
/// (rather than raw `Int` tags) so the selection state is self-documenting
/// and safe to extend if a dedicated Home/world-hub tab is added later.
enum AppTab: Hashable {
    case games, stories, dinoWorld, adventure, parents
}

struct HomeView: View {
    @State private var selectedTab: AppTab = .games

    var body: some View {
        TabView(selection: $selectedTab) {
            GamesListView()
                .tabItem { Label("Games", image: AppAssets.PlannedUI.gamepad) }
                .tag(AppTab.games)

            StoriesListView()
                .tabItem { Label("Stories", image: AppAssets.PlannedUI.book) }
                .tag(AppTab.stories)

            DinoGamesListView()
                .tabItem { Label("Dino World", image: AppAssets.PlannedUI.paw) }
                .tag(AppTab.dinoWorld)

            RPGAdventureView()
                .tabItem { Label("Adventure", image: AppAssets.PlannedUI.map) }
                .tag(AppTab.adventure)

            ParentalGateView()
                .tabItem { Label("Parents", image: AppAssets.PlannedUI.lock) }
                .tag(AppTab.parents)
        }
        .accentColor(PlayLandColors.sunOrange)
    }
}
