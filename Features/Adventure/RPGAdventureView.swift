import SwiftUI

struct RPGAdventureView: View {
    @EnvironmentObject var appSettings: AppSettings

    enum RPGMode: String, CaseIterable {
        case story, explore, minigames

        var titleKey: String {
            switch self {
            case .story: return "adventure.mode.story.title"
            case .explore: return "adventure.mode.explore.title"
            case .minigames: return "adventure.mode.minigames.title"
            }
        }

        var descriptionKey: String {
            switch self {
            case .story: return "adventure.mode.story.desc"
            case .explore: return "adventure.mode.explore.desc"
            case .minigames: return "adventure.mode.minigames.desc"
            }
        }

        var icon: String {
            switch self {
            case .story: return AppAssets.PlannedUI.book
            case .explore: return AppAssets.PlannedUI.map
            case .minigames: return AppAssets.PlannedUI.gamepad
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PlayLandBackground(imageName: AppAssets.Backgrounds.village, scrimOpacity: 0)
                    .overlay(Color.white.opacity(0.55).ignoresSafeArea())

                VStack(spacing: 20) {
                    Text(Loc.t("adventure.title"))
                        .font(PlayLandTypography.display)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 30) {
                        VStack {
                            AppAssets.image(AppAssets.Characters.babis)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge))
                                .shadow(radius: 5)
                            Text(Loc.t("adventure.babisName")).font(PlayLandTypography.heading)
                        }

                        VStack {
                            AppAssets.image(AppAssets.Characters.kotsifi)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge))
                                .shadow(radius: 5)
                            Text(Loc.t("adventure.kotsifiName")).font(PlayLandTypography.heading)
                        }
                    }
                    .padding()

                    Text(Loc.t("adventure.chooseAdventure"))
                        .font(PlayLandTypography.title)
                        .multilineTextAlignment(.center)

                    VStack(spacing: 15) {
                        ForEach(RPGMode.allCases, id: \.self) { mode in
                            NavigationLink(destination: rpgModeView(for: mode)) {
                                PlayLandCard {
                                    HStack {
                                        IconTile(imageName: mode.icon, size: 50, background: PlayLandColors.sunOrange.opacity(0.15))

                                        VStack(alignment: .leading) {
                                            Text(Loc.t(mode.titleKey)).font(PlayLandTypography.heading)
                                            Text(Loc.t(mode.descriptionKey))
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
            .navigationTitle(Loc.t("adventure.title"))
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
        .environmentObject(AppSettings.shared)
}
