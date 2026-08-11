import SwiftUI

/// Every campaign in the game, `.available` ones tappable into
/// `CampaignDetailView`, `.comingSoon` ones shown dimmed with a "coming
/// soon" label — visible, not hidden, so the full planned scope reads as
/// intentional rather than missing.
struct CampaignListView: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        List {
            ForEach(CampaignLibrary.campaigns) { campaign in
                if campaign.status == .available {
                    NavigationLink(destination: CampaignDetailView(campaign: campaign)) {
                        campaignRow(campaign)
                    }
                } else {
                    campaignRow(campaign)
                        .opacity(0.55)
                }
            }
        }
        .navigationTitle(Loc.t("adventure.mode.campaign.title"))
    }

    private func campaignRow(_ campaign: Campaign) -> some View {
        HStack(spacing: 14) {
            AppAssets.image(campaign.coverAsset)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusSmall))
                .saturation(campaign.status == .available ? 1.0 : 0.15)

            VStack(alignment: .leading, spacing: 4) {
                Text(Loc.t(campaign.titleKey))
                    .font(PlayLandTypography.heading)

                if campaign.status == .comingSoon {
                    Text(Loc.t("campaign.comingSoon"))
                        .font(PlayLandTypography.caption)
                        .foregroundColor(PlayLandColors.secondaryText)
                } else {
                    Text(progressSummary(for: campaign))
                        .font(PlayLandTypography.body)
                        .foregroundColor(PlayLandColors.secondaryText)
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }

    private func progressSummary(for campaign: Campaign) -> String {
        let completedCount = campaign.chapters.filter { CampaignLibrary.isChapterComplete($0, progress: progressManager) }.count
        return Loc.t("campaign.chapterProgress", completedCount, campaign.chapters.count)
    }
}
