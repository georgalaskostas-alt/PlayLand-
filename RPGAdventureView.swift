import SwiftUI

struct RPGAdventureView: View {
    @State private var selectedMode: RPGMode = .story
    
    enum RPGMode: String, CaseIterable {
        case story = "Story Mode"
        case explore = "Explore"
        case minigames = "Mini-Games"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                Text("🦖 Babis Adventure")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Character Preview
                HStack(spacing: 30) {
                    // Babis
                    VStack {
                        Image("babis_dinosaur")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                        
                        Text("Babis")
                            .font(.headline)
                    }
                    
                    // Kotsifi
                    VStack {
                        Image("kotsifi_bird")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                        
                        Text("Kotsifi")
                            .font(.headline)
                    }
                }
                .padding()
                
                // Mode Selection
                Text("Choose your adventure!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                VStack(spacing: 15) {
                    ForEach(RPGMode.allCases, id: \.self) { mode in
                        NavigationLink(destination: rpgModeView(for: mode)) {
                            HStack {
                                Image(systemName: mode == .story ? "book.fill" : (mode == .explore ? "map.fill" : "gamecontroller.fill"))
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.orange)
                                    .cornerRadius(10)
                                
                                VStack(alignment: .leading) {
                                    Text(mode.rawValue)
                                        .font(.headline)
                                    
                                    Text(modeDescription(for: mode))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(radius: 3)
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .background(Color.green.opacity(0.05))
            .navigationTitle("Adventure")
        }
    }
    
    private func modeDescription(for mode: RPGMode) -> String {
        switch mode {
        case .story:
            return "Play the story of Babis & Kotsifi"
        case .explore:
            return "Explore the forest and meet friends"
        case .minigames:
            return "Fun educational mini-games"
        }
    }
    
    @ViewBuilder
    private func rpgModeView(for mode: RPGMode) -> some View {
        switch mode {
        case .story:
            StoryModeView()
        case .explore:
            ExploreModeView()
        case .minigames:
            MiniGamesModeView()
        }
    }
}

#Preview {
    RPGAdventureView()
}
