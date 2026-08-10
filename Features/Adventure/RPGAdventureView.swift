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
                PlayLandBackground(imageName: AppAssets.Backgrounds.village, scrimOpacity: 0)
                    .overlay(Color.white.opacity(0.55).ignoresSafeArea())

                VStack(spacing: 20) {
                    Text("Babis' Adventure")
                        .font(PlayLandTypography.display)

                    HStack(spacing: 30) {
                        VStack {
                            AppAssets.image(AppAssets.Characters.babis)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge))
                                .shadow(radius: 5)
                            Text("Babis").font(PlayLandTypography.heading)
                        }

                        VStack {
                            AppAssets.image(AppAssets.Characters.kotsifi)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge))
                                .shadow(radius: 5)
                            Text("Kotsifi").font(PlayLandTypography.heading)
                        }
                    }
                    .padding()

                    Text("Choose your adventure!")
                        .font(PlayLandTypography.title)

                    VStack(spacing: 15) {
                        ForEach(RPGMode.allCases, id: \.self) { mode in
                            NavigationLink(destination: rpgModeView(for: mode)) {
                                PlayLandCard {
                                    HStack {
                                        IconTile(imageName: modeIcon(for: mode), size: 50, background: PlayLandColors.sunOrange.opacity(0.15))

                                        VStack(alignment: .leading) {
                                            Text(mode.rawValue).font(PlayLandTypography.heading)
                                            Text(modeDescription(for: mode))
                                                .font(PlayLandTypography.body)
                                                .foregroundColor(PlayLandColors.secondaryText)
                                        }

                                        Spacer()
                                    }
                                }
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
        case .story: return AppAssets.PlannedUI.book
        case .explore: return AppAssets.PlannedUI.map
        case .minigames: return AppAssets.PlannedUI.gamepad
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
