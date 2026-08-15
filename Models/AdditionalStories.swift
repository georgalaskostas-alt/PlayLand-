import Foundation

extension StoryIllustrations {
    enum FoxFeather {
        static let scene01 = "story_fox_feather_01"
        static let scene02 = "story_fox_feather_02"
        static let scene03 = "story_fox_feather_03"
        static let scene04 = "story_fox_feather_04"
        static let scene05 = "story_fox_feather_05"
        static let scene06 = "story_fox_feather_06"
        static let scene07 = "story_fox_feather_07"
        static let scene08 = "story_fox_feather_08"
        static let scene09 = "story_fox_feather_09"
        static let scene10 = "story_fox_feather_10"
    }

    enum KotsifiStorm {
        static let scene01 = "story_kotsifi_storm_01"
        static let scene02 = "story_kotsifi_storm_02"
        static let scene03 = "story_kotsifi_storm_03"
        static let scene04 = "story_kotsifi_storm_04"
        static let scene05 = "story_kotsifi_storm_05"
        static let scene06 = "story_kotsifi_storm_06"
        static let scene07 = "story_kotsifi_storm_07"
        static let scene08 = "story_kotsifi_storm_08"
        static let scene09 = "story_kotsifi_storm_09"
        static let scene10 = "story_kotsifi_storm_10"
    }

    enum CrystalPromise {
        static let scene01 = "story_crystal_promise_01"
        static let scene02 = "story_crystal_promise_02"
        static let scene03 = "story_crystal_promise_03"
        static let scene04 = "story_crystal_promise_04"
        static let scene05 = "story_crystal_promise_05"
        static let scene06 = "story_crystal_promise_06"
        static let scene07 = "story_crystal_promise_07"
        static let scene08 = "story_crystal_promise_08"
        static let scene09 = "story_crystal_promise_09"
        static let scene10 = "story_crystal_promise_10"
    }
}

enum AdditionalStoryLibrary {
    private static func next(_ index: Int) -> [StoryChoice] {
        [StoryChoice(textKey: "story.common.continue", nextSceneIndex: index)]
    }

    static let stories: [StoryContent] = [
        StoryContent(
            id: "fox_golden_feather",
            titleKey: "story.foxFeather.title",
            descriptionKey: "story.foxFeather.desc",
            coverImageName: StoryIllustrations.FoxFeather.scene01,
            scenes: [
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.FoxStates.smirk], narrationKey: "story.foxFeather.s0", choices: next(1), illustration: StoryIllustrations.FoxFeather.scene01),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.FoxStates.smirk, AppAssets.KotsifiStates.idle], narrationKey: "story.foxFeather.s1", choices: next(2), illustration: StoryIllustrations.FoxFeather.scene02),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.FoxStates.surprised, "golden_feather"], narrationKey: "story.foxFeather.s2", choices: next(3), illustration: StoryIllustrations.FoxFeather.scene03),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.FoxStates.smirk, "golden_feather"], narrationKey: "story.foxFeather.s3", choices: next(4), illustration: StoryIllustrations.FoxFeather.scene04),
                StoryScene(background: AppAssets.Backgrounds.village, characters: [AppAssets.KotsifiStates.surprised, AppAssets.FoxStates.worried], narrationKey: "story.foxFeather.s4", choices: next(5), illustration: StoryIllustrations.FoxFeather.scene05),
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [AppAssets.FoxStates.worried], narrationKey: "story.foxFeather.s5", choices: next(6), illustration: StoryIllustrations.FoxFeather.scene06),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.FoxStates.worried, AppAssets.KotsifiStates.idle], narrationKey: "story.foxFeather.s6", choices: next(7), illustration: StoryIllustrations.FoxFeather.scene07),
                StoryScene(background: AppAssets.Backgrounds.village, characters: [AppAssets.FoxStates.friendly, "golden_feather"], narrationKey: "story.foxFeather.s7", choices: next(8), illustration: StoryIllustrations.FoxFeather.scene08),
                StoryScene(background: AppAssets.Backgrounds.village, characters: [AppAssets.FoxStates.friendly, AppAssets.KotsifiStates.happy], narrationKey: "story.foxFeather.s8", choices: next(9), illustration: StoryIllustrations.FoxFeather.scene09),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.FoxStates.friendly, AppAssets.KotsifiStates.happy], narrationKey: "story.foxFeather.s9", choices: [], illustration: StoryIllustrations.FoxFeather.scene10)
            ]
        ),
        StoryContent(
            id: "kotsifi_storm",
            titleKey: "story.kotsifiStorm.title",
            descriptionKey: "story.kotsifiStorm.desc",
            coverImageName: StoryIllustrations.KotsifiStorm.scene01,
            scenes: [
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.KotsifiStates.happy], narrationKey: "story.kotsifiStorm.s0", choices: next(1), illustration: StoryIllustrations.KotsifiStorm.scene01),
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [AppAssets.KotsifiStates.surprised], narrationKey: "story.kotsifiStorm.s1", choices: next(2), illustration: StoryIllustrations.KotsifiStorm.scene02),
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [AppAssets.KotsifiStates.fly1], narrationKey: "story.kotsifiStorm.s2", choices: next(3), illustration: StoryIllustrations.KotsifiStorm.scene03),
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [AppAssets.KotsifiStates.fly2, AppAssets.FoxStates.worried], narrationKey: "story.kotsifiStorm.s3", choices: next(4), illustration: StoryIllustrations.KotsifiStorm.scene04),
                StoryScene(background: AppAssets.Backgrounds.cave, characters: [AppAssets.KotsifiStates.idle, AppAssets.FoxStates.worried], narrationKey: "story.kotsifiStorm.s4", choices: next(5), illustration: StoryIllustrations.KotsifiStorm.scene05),
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [AppAssets.KotsifiStates.fly3], narrationKey: "story.kotsifiStorm.s5", choices: next(6), illustration: StoryIllustrations.KotsifiStorm.scene06),
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [BabisVisualState.neutral.plannedAssetName, AppAssets.KotsifiStates.talking], narrationKey: "story.kotsifiStorm.s6", choices: next(7), illustration: StoryIllustrations.KotsifiStorm.scene07),
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [BabisVisualState.neutral.plannedAssetName, AppAssets.KotsifiStates.fly1], narrationKey: "story.kotsifiStorm.s7", choices: next(8), illustration: StoryIllustrations.KotsifiStorm.scene08),
                StoryScene(background: AppAssets.Backgrounds.village, characters: [BabisVisualState.happy.plannedAssetName, AppAssets.KotsifiStates.happy, AppAssets.FoxStates.friendly], narrationKey: "story.kotsifiStorm.s8", choices: next(9), illustration: StoryIllustrations.KotsifiStorm.scene09),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.KotsifiStates.happy], narrationKey: "story.kotsifiStorm.s9", choices: [], illustration: StoryIllustrations.KotsifiStorm.scene10)
            ]
        ),
        StoryContent(
            id: "crystal_promise",
            titleKey: "story.crystalPromise.title",
            descriptionKey: "story.crystalPromise.desc",
            coverImageName: StoryIllustrations.CrystalPromise.scene01,
            scenes: [
                StoryScene(background: AppAssets.Backgrounds.cave, characters: [BabisVisualState.neutral.plannedAssetName, "crystal_item"], narrationKey: "story.crystalPromise.s0", choices: next(1), illustration: StoryIllustrations.CrystalPromise.scene01),
                StoryScene(background: AppAssets.Backgrounds.cave, characters: [BabisVisualState.neutral.plannedAssetName, AppAssets.KotsifiStates.idle], narrationKey: "story.crystalPromise.s1", choices: next(2), illustration: StoryIllustrations.CrystalPromise.scene02),
                StoryScene(background: AppAssets.Backgrounds.cave, characters: [AppAssets.FoxStates.smirk, "crystal_item"], narrationKey: "story.crystalPromise.s2", choices: next(3), illustration: StoryIllustrations.CrystalPromise.scene03),
                StoryScene(background: AppAssets.Backgrounds.cave, characters: [BabisVisualState.neutral.plannedAssetName, AppAssets.FoxStates.worried], narrationKey: "story.crystalPromise.s3", choices: next(4), illustration: StoryIllustrations.CrystalPromise.scene04),
                StoryScene(background: AppAssets.Backgrounds.cave, characters: [AppAssets.KotsifiStates.talking, "crystal_item"], narrationKey: "story.crystalPromise.s4", choices: next(5), illustration: StoryIllustrations.CrystalPromise.scene05),
                StoryScene(background: AppAssets.Backgrounds.cave, characters: [BabisVisualState.happy.plannedAssetName, AppAssets.FoxStates.friendly], narrationKey: "story.crystalPromise.s5", choices: next(6), illustration: StoryIllustrations.CrystalPromise.scene06),
                StoryScene(background: AppAssets.Backgrounds.village, characters: [BabisVisualState.happy.plannedAssetName, AppAssets.FoxStates.friendly, AppAssets.KotsifiStates.happy], narrationKey: "story.crystalPromise.s6", choices: next(7), illustration: StoryIllustrations.CrystalPromise.scene07),
                StoryScene(background: AppAssets.Backgrounds.village, characters: ["crystal_item"], narrationKey: "story.crystalPromise.s7", choices: next(8), illustration: StoryIllustrations.CrystalPromise.scene08),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [BabisVisualState.happy.plannedAssetName, AppAssets.FoxStates.friendly], narrationKey: "story.crystalPromise.s8", choices: next(9), illustration: StoryIllustrations.CrystalPromise.scene09),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [BabisVisualState.excited.plannedAssetName, AppAssets.FoxStates.friendly, AppAssets.KotsifiStates.happy], narrationKey: "story.crystalPromise.s9", choices: [], illustration: StoryIllustrations.CrystalPromise.scene10)
            ]
        )
    ]
}
