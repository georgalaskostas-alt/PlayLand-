import Foundation

/// One chapter within a campaign. A chapter never tracks its own progress —
/// it names the existing `WorldLocation` it plays out in and the existing
/// `Quest` whose completion *is* the chapter's completion, so campaign
/// progression can never drift out of sync with the quest/location system
/// that already drives the RPG world.
struct CampaignChapter: Identifiable {
    let id: String
    let order: Int
    let titleKey: String
    /// A short "what to do" line shown as a goal banner while playing.
    let goalKey: String
    let locationId: String
    let questId: String
}

/// Whether a campaign has real, playable chapters yet. `.comingSoon`
/// campaigns are still named and described in the picker — the full
/// 7-campaign scope stays visible — but present no chapters to play,
/// per "implement one strong vertical slice, not all campaigns at once."
enum CampaignStatus {
    case available
    case comingSoon
}

struct Campaign: Identifiable {
    let id: String
    let titleKey: String
    let descriptionKey: String
    let coverAsset: String
    let status: CampaignStatus
    let chapters: [CampaignChapter]
}

/// Every campaign in the game. Only "The Lost Forest Supplies" has
/// chapters wired to real world content today; the rest are stubs that
/// establish the architecture (and the picker UI) for future campaigns
/// without pretending they're playable.
enum CampaignLibrary {
    static let campaigns: [Campaign] = [
        Campaign(
            id: "lost_forest_supplies",
            titleKey: "campaign.lostForestSupplies.title",
            descriptionKey: "campaign.lostForestSupplies.desc",
            coverAsset: AppAssets.Backgrounds.village,
            status: .available,
            chapters: [
                CampaignChapter(
                    id: "lost_forest_supplies_ch1",
                    order: 1,
                    titleKey: "campaign.lostForestSupplies.ch1.title",
                    goalKey: "campaign.lostForestSupplies.ch1.goal",
                    locationId: "village",
                    questId: "gather_supplies"
                ),
                CampaignChapter(
                    id: "lost_forest_supplies_ch2",
                    order: 2,
                    titleKey: "campaign.lostForestSupplies.ch2.title",
                    goalKey: "campaign.lostForestSupplies.ch2.goal",
                    locationId: "village",
                    questId: "open_first_chest"
                ),
                CampaignChapter(
                    id: "lost_forest_supplies_ch3",
                    order: 3,
                    titleKey: "campaign.lostForestSupplies.ch3.title",
                    goalKey: "campaign.lostForestSupplies.ch3.goal",
                    locationId: "forest",
                    questId: "find_cave_entrance"
                ),
                CampaignChapter(
                    id: "lost_forest_supplies_ch4",
                    order: 4,
                    titleKey: "campaign.lostForestSupplies.ch4.title",
                    goalKey: "campaign.lostForestSupplies.ch4.goal",
                    locationId: "crystal_cave",
                    questId: "collect_stones"
                ),
                CampaignChapter(
                    id: "lost_forest_supplies_ch5",
                    order: 5,
                    titleKey: "campaign.lostForestSupplies.ch5.title",
                    goalKey: "campaign.lostForestSupplies.ch5.goal",
                    locationId: "fox_cave",
                    questId: "uncover_fox_secret"
                )
            ]
        ),
        Campaign(id: "crystal_cave_mystery", titleKey: "campaign.crystalCaveMystery.title", descriptionKey: "campaign.crystalCaveMystery.desc", coverAsset: AppAssets.Backgrounds.cave, status: .comingSoon, chapters: []),
        Campaign(id: "lost_dino_egg", titleKey: "campaign.lostDinoEgg.title", descriptionKey: "campaign.lostDinoEgg.desc", coverAsset: AppAssets.Backgrounds.forestDay, status: .comingSoon, chapters: []),
        Campaign(id: "night_forest", titleKey: "campaign.nightForest.title", descriptionKey: "campaign.nightForest.desc", coverAsset: AppAssets.Backgrounds.forestNight, status: .comingSoon, chapters: []),
        Campaign(id: "village_festival", titleKey: "campaign.villageFestival.title", descriptionKey: "campaign.villageFestival.desc", coverAsset: AppAssets.Backgrounds.village, status: .comingSoon, chapters: []),
        Campaign(id: "dino_farm_rescue", titleKey: "campaign.dinoFarmRescue.title", descriptionKey: "campaign.dinoFarmRescue.desc", coverAsset: AppAssets.Characters.babis, status: .comingSoon, chapters: []),
        Campaign(id: "fox_secret_path", titleKey: "campaign.foxSecretPath.title", descriptionKey: "campaign.foxSecretPath.desc", coverAsset: AppAssets.Backgrounds.foxCave, status: .comingSoon, chapters: [])
    ]

    static func campaign(withId id: String) -> Campaign? {
        campaigns.first { $0.id == id }
    }

    static func isChapterComplete(_ chapter: CampaignChapter, progress: ProgressViewModel) -> Bool {
        progress.isQuestCompleted(chapter.questId)
    }

    /// The first not-yet-complete chapter — where a returning player should
    /// resume. `nil` once every chapter is done (or if the campaign has none).
    static func currentChapter(for campaign: Campaign, progress: ProgressViewModel) -> CampaignChapter? {
        campaign.chapters.first { !isChapterComplete($0, progress: progress) }
    }

    static func isCampaignComplete(_ campaign: Campaign, progress: ProgressViewModel) -> Bool {
        !campaign.chapters.isEmpty && campaign.chapters.allSatisfy { isChapterComplete($0, progress: progress) }
    }
}
