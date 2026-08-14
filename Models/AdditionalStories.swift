import Foundation

enum AdditionalStoryLibrary {
    private static func next(_ index: Int) -> [StoryChoice] {
        [StoryChoice(textKey: "story.common.continue", nextSceneIndex: index)]
    }

    static let stories: [StoryContent] = [
        StoryContent(
            id: "fox_golden_feather",
            titleKey: "story.foxFeather.title",
            descriptionKey: "story.foxFeather.desc",
            coverImageName: "golden_feather",
            scenes: [
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.FoxStates.smirk], narrationKey: "story.foxFeather.s0", choices: next(1)),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.FoxStates.smirk, AppAssets.KotsifiStates.idle], narrationKey: "story.foxFeather.s1", choices: next(2)),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.FoxStates.surprised, "golden_feather"], narrationKey: "story.foxFeather.s2", choices: next(3)),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.FoxStates.smirk, "golden_feather"], narrationKey: "story.foxFeather.s3", choices: next(4)),
                StoryScene(background: AppAssets.Backgrounds.village, characters: [AppAssets.KotsifiStates.surprised, AppAssets.FoxStates.worried], narrationKey: "story.foxFeather.s4", choices: next(5)),
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [AppAssets.FoxStates.worried], narrationKey: "story.foxFeather.s5", choices: next(6)),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.FoxStates.worried, AppAssets.KotsifiStates.idle], narrationKey: "story.foxFeather.s6", choices: next(7)),
                StoryScene(background: AppAssets.Backgrounds.village, characters: [AppAssets.FoxStates.friendly, "golden_feather"], narrationKey: "story.foxFeather.s7", choices: next(8)),
                StoryScene(background: AppAssets.Backgrounds.village, characters: [AppAssets.FoxStates.friendly, AppAssets.KotsifiStates.happy], narrationKey: "story.foxFeather.s8", choices: next(9)),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.FoxStates.friendly, AppAssets.KotsifiStates.happy], narrationKey: "story.foxFeather.s9", choices: [])
            ]
        ),
        StoryContent(
            id: "kotsifi_storm",
            titleKey: "story.kotsifiStorm.title",
            descriptionKey: "story.kotsifiStorm.desc",
            coverImageName: AppAssets.KotsifiStates.fly1,
            scenes: [
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.KotsifiStates.happy], narrationKey: "story.kotsifiStorm.s0", choices: next(1)),
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [AppAssets.KotsifiStates.surprised], narrationKey: "story.kotsifiStorm.s1", choices: next(2)),
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [AppAssets.KotsifiStates.fly1], narrationKey: "story.kotsifiStorm.s2", choices: next(3)),
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [AppAssets.KotsifiStates.fly2, AppAssets.FoxStates.worried], narrationKey: "story.kotsifiStorm.s3", choices: next(4)),
                StoryScene(background: AppAssets.Backgrounds.cave, characters: [AppAssets.KotsifiStates.idle, AppAssets.FoxStates.worried], narrationKey: "story.kotsifiStorm.s4", choices: next(5)),
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [AppAssets.KotsifiStates.fly3], narrationKey: "story.kotsifiStorm.s5", choices: next(6)),
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [BabisVisualState.neutral.plannedAssetName, AppAssets.KotsifiStates.talking], narrationKey: "story.kotsifiStorm.s6", choices: next(7)),
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [BabisVisualState.neutral.plannedAssetName, AppAssets.KotsifiStates.fly1], narrationKey: "story.kotsifiStorm.s7", choices: next(8)),
                StoryScene(background: AppAssets.Backgrounds.village, characters: [BabisVisualState.happy.plannedAssetName, AppAssets.KotsifiStates.happy, AppAssets.FoxStates.friendly], narrationKey: "story.kotsifiStorm.s8", choices: next(9)),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.KotsifiStates.happy], narrationKey: "story.kotsifiStorm.s9", choices: [])
            ]
        ),
        StoryContent(
            id: "crystal_promise",
            titleKey: "story.crystalPromise.title",
            descriptionKey: "story.crystalPromise.desc",
            coverImageName: "crystal_item",
            scenes: [
                StoryScene(background: AppAssets.Backgrounds.cave, characters: [BabisVisualState.neutral.plannedAssetName, "crystal_item"], narrationKey: "story.crystalPromise.s0", choices: next(1)),
                StoryScene(background: AppAssets.Backgrounds.cave, characters: [BabisVisualState.neutral.plannedAssetName, AppAssets.KotsifiStates.idle], narrationKey: "story.crystalPromise.s1", choices: next(2)),
                StoryScene(background: AppAssets.Backgrounds.cave, characters: [AppAssets.FoxStates.smirk, "crystal_item"], narrationKey: "story.crystalPromise.s2", choices: next(3)),
                StoryScene(background: AppAssets.Backgrounds.cave, characters: [BabisVisualState.neutral.plannedAssetName, AppAssets.FoxStates.worried], narrationKey: "story.crystalPromise.s3", choices: next(4)),
                StoryScene(background: AppAssets.Backgrounds.cave, characters: [AppAssets.KotsifiStates.talking, "crystal_item"], narrationKey: "story.crystalPromise.s4", choices: next(5)),
                StoryScene(background: AppAssets.Backgrounds.cave, characters: [BabisVisualState.happy.plannedAssetName, AppAssets.FoxStates.friendly], narrationKey: "story.crystalPromise.s5", choices: next(6)),
                StoryScene(background: AppAssets.Backgrounds.village, characters: [BabisVisualState.happy.plannedAssetName, AppAssets.FoxStates.friendly, AppAssets.KotsifiStates.happy], narrationKey: "story.crystalPromise.s6", choices: next(7)),
                StoryScene(background: AppAssets.Backgrounds.village, characters: ["crystal_item"], narrationKey: "story.crystalPromise.s7", choices: next(8)),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [BabisVisualState.happy.plannedAssetName, AppAssets.FoxStates.friendly], narrationKey: "story.crystalPromise.s8", choices: next(9)),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [BabisVisualState.excited.plannedAssetName, AppAssets.FoxStates.friendly, AppAssets.KotsifiStates.happy], narrationKey: "story.crystalPromise.s9", choices: [])
            ]
        )
    ]
}
