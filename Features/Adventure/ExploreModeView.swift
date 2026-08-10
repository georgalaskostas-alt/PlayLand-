import SwiftUI

/// The world hub: every `WorldLocation`, locked or not. Tapping an unlocked
/// location pushes into `LocationExploreView`; locked ones show what's
/// needed to open them instead of just disappearing, so progression always
/// has a visible next step.
struct ExploreModeView: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        List {
            Section {
                ForEach(WorldLibrary.locations) { location in
                    if progressManager.isLocationUnlocked(location.id) {
                        NavigationLink(destination: LocationExploreView(location: location)) {
                            locationRow(location, isUnlocked: true)
                        }
                    } else {
                        locationRow(location, isUnlocked: false)
                    }
                }
            } footer: {
                if !inventorySummary.isEmpty {
                    inventoryRow
                }
            }
        }
        .navigationTitle(Loc.t("world.hubTitle"))
    }

    private func locationRow(_ location: WorldLocation, isUnlocked: Bool) -> some View {
        HStack(spacing: 14) {
            AppAssets.image(location.backgroundAsset)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusSmall))
                .saturation(isUnlocked ? 1.0 : 0.15)
                .overlay {
                    if !isUnlocked {
                        AppAssets.image(AppAssets.PlannedUI.lock)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(.white)
                    }
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(Loc.t(location.titleKey))
                    .font(PlayLandTypography.heading)
                    .foregroundColor(isUnlocked ? PlayLandColors.primaryText : PlayLandColors.secondaryText)

                if isUnlocked {
                    Text(Loc.t("world.enterLocation"))
                        .font(PlayLandTypography.body)
                        .foregroundColor(PlayLandColors.secondaryText)
                } else {
                    Text(Loc.t("world.unlockHint"))
                        .font(PlayLandTypography.caption)
                        .foregroundColor(PlayLandColors.secondaryText)
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .opacity(isUnlocked ? 1.0 : 0.7)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(isUnlocked ? Loc.t(location.titleKey) : "\(Loc.t(location.titleKey)) — \(Loc.t("world.locked"))"))
    }

    private var inventorySummary: [(String, Int)] {
        let crystalCount = progressManager.itemCount("crystal")
        return crystalCount > 0 ? [("crystal", crystalCount)] : []
    }

    private var inventoryRow: some View {
        HStack(spacing: 8) {
            Text(Loc.t("world.inventory") + ":")
                .font(PlayLandTypography.caption.weight(.semibold))
            ForEach(inventorySummary, id: \.0) { itemId, count in
                HStack(spacing: 4) {
                    Text("💎")
                    Text("\(Loc.t("world.itemCrystal")) × \(count)")
                }
                .font(PlayLandTypography.caption)
            }
        }
    }
}
