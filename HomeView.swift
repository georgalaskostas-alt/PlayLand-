import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GamesListView()
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }
                .tag(0)
            
            StoriesListView()
                .tabItem {
                    Label("Stories", systemImage: "book.fill")
                }
                .tag(1)
            
            DinoGamesListView()
                .tabItem {
                    Label("Dino World", systemImage: "leaf.fill")
                }
                .tag(2)
            
            // ΝΕΟ TAB - RPG ADVENTURE
            RPGAdventureView()
                .tabItem {
                    Label("Adventure", systemImage: "map.fill")
                }
                .tag(3)
            
            ParentalGateView()
                .tabItem {
                    Label("Parents", systemImage: "lock.fill")
                }
                .tag(4)
        }
        .accentColor(.orange)
    }
}
