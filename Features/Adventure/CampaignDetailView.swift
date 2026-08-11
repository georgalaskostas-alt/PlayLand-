import SwiftUI

/// A campaign's chapter list: completed chapters show a checkmark,
/// the current chapter is highlighted and tappable, and any chapter whose
/// location isn't unlocked yet is shown but disabled — reusing
/// `ProgressViewModel.isLocationUnlocked` rather than inventing a second
/// gating system just for campaigns.
struct CampaignDetailView: View {
    let campaign: Campaign

    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings

    private var currentChapter: CampaignChapter? {
        CampaignLibrary.currentChapter(for: campaign, progress: progressManager)
    }

    var body: some View {
        List {
            Section {
                Text(Loc.t(campaign.descriptionKey))
                    .font(PlayLandTypography.body)
                    .foregroundColor(PlayLandColors.secondaryText)
            }

            Section {
                ForEach(campaign.chapters) { chapter in
                    chapterRow(chapter)
                }
            }
        }
        .navigationTitle(Loc.t(campaign.titleKey))
    }

    @ViewBuilder
    private func chapterRow(_ chapter: CampaignChapter) -> some View {
        let isComplete = CampaignLibrary.isChapterComplete(chapter, progress: progressManager)
        let isCurrent = chapter.id == currentChapter?.id
        let isReachable = progressManager.isLocationUnlocked(chapter.locationId)
        let location = WorldLibrary.location(withId: chapter.locationId)

        if isReachable, let location {
            NavigationLink(destination: LocationExploreView(location: location)) {
                chapterRowContent(chapter, isComplete: isComplete, isCurrent: isCurrent, isReachable: true)
            }
        } else {
            chapterRowContent(chapter, isComplete: isComplete, isCurrent: isCurrent, isReachable: false)
                .opacity(0.5)
        }
    }

    private func chapterRowContent(_ chapter: CampaignChapter, isComplete: Bool, isCurrent: Bool, isReachable: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : (isReachable ? "circle" : "lock.fill"))
                .foregroundColor(isComplete ? PlayLandColors.leafGreen : PlayLandColors.secondaryText)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(Loc.t(chapter.titleKey))
                    .font(PlayLandTypography.heading)
                if isCurrent, !isComplete {
                    Text(Loc.t(chapter.goalKey))
                        .font(PlayLandTypography.caption)
                        .foregroundColor(PlayLandColors.sunOrange)
                } else if !isReachable {
                    Text(Loc.t("world.unlockHint"))
                        .font(PlayLandTypography.caption)
                        .foregroundColor(PlayLandColors.secondaryText)
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}
