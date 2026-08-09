import SwiftUI

struct RPGAdventureView: View {
    enum RPGMode: String, CaseIterable {
        case story = "Story Mode"
        case explore = "Explore"
        case minigames = "Mini-Games"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Image("village_background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .overlay(Color.white.opacity(0.55).ignoresSafeArea())

                VStack(spacing: 20) {
                    Text("Babis' Adventure")
                        .font(.largeTitle.bold())

                    HStack(spacing: 30) {
                        VStack {
                            Image("babis_dinosaur")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .shadow(radius: 5)
                            Text("Babis").font(.headline)
                        }

                        VStack {
                            Image("kotsifi_bird")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .shadow(radius: 5)
                            Text("Kotsifi").font(.headline)
                        }
                    }
                    .padding()

                    Text("Choose your adventure!")
                        .font(.title2.bold())

                    VStack(spacing: 15) {
                        ForEach(RPGMode.allCases, id: \.self) { mode in
                            NavigationLink(destination: rpgModeView(for: mode)) {
                                HStack {
                                    RoundedIconTile(imageName: modeIcon(for: mode), size: 50, background: PlayLandTheme.sunOrange.opacity(0.15))

                                    VStack(alignment: .leading) {
                                        Text(mode.rawValue).font(.headline)
                                        Text(modeDescription(for: mode))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(radius: 3)
                            }
                        }
                    }
                    .padding()

                    Spacer()
                }
            }
            .navigationTitle("Adventure")
        }
    }

    private func modeIcon(for mode: RPGMode) -> String {
        switch mode {
        case .story: return "ui_book"
        case .explore: return "ui_map"
        case .minigames: return "ui_gamepad"
        }
    }

    private func modeDescription(for mode: RPGMode) -> String {
        switch mode {
        case .story:
            return "Play the story of Babis & friends"
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
        .environmentObject(ProgressViewModel())
}
