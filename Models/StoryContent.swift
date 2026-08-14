import Foundation

struct StoryChoice: Identifiable {
    let id = UUID()
    let textKey: String
    /// Index of the scene to jump to. `nil` ends the story/chapter.
    let nextSceneIndex: Int?
}

struct StoryScene: Identifiable {
    let id = UUID()
    let background: String
    let characters: [String]
    let narrationKey: String
    let choices: [StoryChoice]
    let illustration: String?

    init(
        background: String,
        characters: [String],
        narrationKey: String,
        choices: [StoryChoice],
        illustration: String? = nil
    ) {
        self.background = background
        self.characters = characters
        self.narrationKey = narrationKey
        self.choices = choices
        self.illustration = illustration
    }
}

struct StoryContent: Identifiable {
    let id: String
    let titleKey: String
    let descriptionKey: String
    let coverImageName: String
    let scenes: [StoryScene]
}

enum StoryIllustrations {
    enum BabisKotsifi {
        static let scene01 = "story_babis_kotsifi_01"
        static let scene02 = "story_babis_kotsifi_02"
        static let scene03 = "story_babis_kotsifi_03"
        static let scene04 = "story_babis_kotsifi_04"
        static let scene05 = "story_babis_kotsifi_05"
        static let scene06 = "story_babis_kotsifi_06"
        static let scene07 = "story_babis_kotsifi_07"
        static let scene08 = "story_babis_kotsifi_08"
        static let scene09 = "story_babis_kotsifi_09"
        static let scene10 = "story_babis_kotsifi_10"
        static let scene11 = "story_babis_kotsifi_11"
        static let scene12 = "story_babis_kotsifi_12"
        static let scene13 = "story_babis_kotsifi_13"
        static let scene14 = "story_babis_kotsifi_14"
        static let scene15 = "story_babis_kotsifi_15"
    }
}

enum StoryLibrary {
    private static func next(_ scene: Int) -> [StoryChoice] {
        [StoryChoice(textKey: "story.babisKotsifi.continue", nextSceneIndex: scene)]
    }

    static let stories: [StoryContent] = [
        StoryContent(
            id: "babis_kotsifi",
            titleKey: "story.babisKotsifi.title",
            descriptionKey: "story.babisKotsifi.desc",
            coverImageName: StoryIllustrations.BabisKotsifi.scene01,
            scenes: [
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [BabisVisualState.neutral.plannedAssetName], narrationKey: "story.babisKotsifi.scene0.narration", choices: next(1), illustration: StoryIllustrations.BabisKotsifi.scene01),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [BabisVisualState.neutral.plannedAssetName, AppAssets.KotsifiStates.idle], narrationKey: "story.babisKotsifi.scene1.narration", choices: next(2), illustration: StoryIllustrations.BabisKotsifi.scene02),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [BabisVisualState.happy.plannedAssetName, AppAssets.KotsifiStates.happy], narrationKey: "story.babisKotsifi.scene2.combinedNarration", choices: next(3), illustration: StoryIllustrations.BabisKotsifi.scene03),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [BabisVisualState.drinking.plannedAssetName, AppAssets.KotsifiStates.happy], narrationKey: "story.babisKotsifi.scene4.narration", choices: next(4), illustration: StoryIllustrations.BabisKotsifi.scene04),
                StoryScene(background: AppAssets.Backgrounds.village, characters: [BabisVisualState.eating.plannedAssetName, AppAssets.KotsifiStates.happy], narrationKey: "story.babisKotsifi.scene5.narration", choices: next(5), illustration: StoryIllustrations.BabisKotsifi.scene05),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [BabisVisualState.happy.plannedAssetName, AppAssets.KotsifiStates.happy], narrationKey: "story.babisKotsifi.scene6.narration", choices: next(6), illustration: StoryIllustrations.BabisKotsifi.scene06),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.FoxStates.smirk, BabisVisualState.happy.plannedAssetName, AppAssets.KotsifiStates.idle], narrationKey: "story.babisKotsifi.scene7.narration", choices: next(7), illustration: StoryIllustrations.BabisKotsifi.scene07),
                StoryScene(background: AppAssets.Backgrounds.cave, characters: [AppAssets.FoxStates.smirk], narrationKey: "story.babisKotsifi.scene8.narration", choices: next(8), illustration: StoryIllustrations.BabisKotsifi.scene08),
                StoryScene(background: AppAssets.Backgrounds.cave, characters: [BabisVisualState.neutral.plannedAssetName, AppAssets.KotsifiStates.surprised], narrationKey: "story.babisKotsifi.scene9.narration", choices: [StoryChoice(textKey: "story.babisKotsifi.scene9.choice0", nextSceneIndex: 9), StoryChoice(textKey: "story.babisKotsifi.scene9.choice1", nextSceneIndex: 9)], illustration: StoryIllustrations.BabisKotsifi.scene09),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.KotsifiStates.fly1], narrationKey: "story.babisKotsifi.scene10.treeNarration", choices: next(10), illustration: StoryIllustrations.BabisKotsifi.scene10),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.KotsifiStates.fly1, BabisVisualState.neutral.plannedAssetName], narrationKey: "story.babisKotsifi.scene11.smokeNarration", choices: next(11), illustration: StoryIllustrations.BabisKotsifi.scene11),
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [BabisVisualState.neutral.plannedAssetName, AppAssets.KotsifiStates.idle], narrationKey: "story.babisKotsifi.scene11.narration", choices: next(12), illustration: StoryIllustrations.BabisKotsifi.scene12),
                StoryScene(background: AppAssets.Backgrounds.foxCave, characters: [BabisVisualState.neutral.plannedAssetName, AppAssets.FoxStates.worried, AppAssets.KotsifiStates.idle], narrationKey: "story.babisKotsifi.scene12.narration", choices: [StoryChoice(textKey: "story.babisKotsifi.scene12.choice0", nextSceneIndex: 13), StoryChoice(textKey: "story.babisKotsifi.scene12.choice1", nextSceneIndex: 13)], illustration: StoryIllustrations.BabisKotsifi.scene13),
                StoryScene(background: AppAssets.Backgrounds.village, characters: [AppAssets.FoxStates.friendly, BabisVisualState.happy.plannedAssetName, AppAssets.KotsifiStates.happy], narrationKey: "story.babisKotsifi.scene13.narration", choices: next(14), illustration: StoryIllustrations.BabisKotsifi.scene14),
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [BabisVisualState.excited.plannedAssetName, AppAssets.KotsifiStates.happy, AppAssets.FoxStates.friendly], narrationKey: "story.babisKotsifi.scene14.narration", choices: [], illustration: StoryIllustrations.BabisKotsifi.scene15)
            ]
        ),
        StoryContent(
            id: "cave_crystals",
            titleKey: "story.caveCrystals.title",
            descriptionKey: "story.caveCrystals.desc",
            coverImageName: AppAssets.Backgrounds.cave,
            scenes: [
                StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi], narrationKey: "story.caveCrystals.scene0.narration", choices: [StoryChoice(textKey: "story.caveCrystals.scene0.choice0", nextSceneIndex: 1), StoryChoice(textKey: "story.caveCrystals.scene0.choice1", nextSceneIndex: 2)]),
                StoryScene(background: AppAssets.Backgrounds.cave, characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi], narrationKey: "story.caveCrystals.scene1.narration", choices: [StoryChoice(textKey: "story.caveCrystals.scene1.choice0", nextSceneIndex: 3)]),
                StoryScene(background: AppAssets.Backgrounds.cave, characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi], narrationKey: "story.caveCrystals.scene2.narration", choices: [StoryChoice(textKey: "story.caveCrystals.scene2.choice0", nextSceneIndex: 3)]),
                StoryScene(background: AppAssets.Backgrounds.foxCave, characters: [AppAssets.Characters.fox, AppAssets.Characters.babis], narrationKey: "story.caveCrystals.scene3.narration", choices: [StoryChoice(textKey: "story.caveCrystals.scene3.choice0", nextSceneIndex: 4)]),
                StoryScene(background: AppAssets.Backgrounds.village, characters: [AppAssets.Characters.babis, AppAssets.Characters.fox, AppAssets.Characters.kotsifi], narrationKey: "story.caveCrystals.scene4.narration", choices: [])
            ]
        ),
        StoryContent(
            id: "forest_hero",
            titleKey: "story.forestHero.title",
            descriptionKey: "story.forestHero.desc",
            coverImageName: AppAssets.Backgrounds.forestNight,
            scenes: [
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [AppAssets.Characters.babis], narrationKey: "story.forestHero.scene0.narration", choices: [StoryChoice(textKey: "story.forestHero.scene0.choice0", nextSceneIndex: 1), StoryChoice(textKey: "story.forestHero.scene0.choice1", nextSceneIndex: 2)]),
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi], narrationKey: "story.forestHero.scene1.narration", choices: [StoryChoice(textKey: "story.forestHero.scene1.choice0", nextSceneIndex: 2)]),
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [AppAssets.Characters.babis, AppAssets.Characters.fox], narrationKey: "story.forestHero.scene2.narration", choices: [StoryChoice(textKey: "story.forestHero.scene2.choice0", nextSceneIndex: 3)]),
                StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [AppAssets.Characters.babis, AppAssets.Characters.fox, AppAssets.Characters.kotsifi], narrationKey: "story.forestHero.scene3.narration", choices: [StoryChoice(textKey: "story.forestHero.scene3.choice0", nextSceneIndex: 4)]),
                StoryScene(background: AppAssets.Backgrounds.village, characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi, AppAssets.Characters.fox], narrationKey: "story.forestHero.scene4.narration", choices: [])
            ]
        )
    ]

    static func story(withId id: String) -> StoryContent? { stories.first { $0.id == id } }
}

struct ChapterContent: Identifiable {
    let id: String
    let order: Int
    let titleKey: String
    let descriptionKey: String
    let imageName: String
    let scenes: [StoryScene]
}

enum ChapterLibrary {
    static let chapters: [ChapterContent] = [
        ChapterContent(id: "meeting_babis", order: 1, titleKey: "chapter.meetingBabis.title", descriptionKey: "chapter.meetingBabis.desc", imageName: AppAssets.Characters.babis, scenes: [StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.Characters.babis], narrationKey: "chapter.meetingBabis.scene0.narration", choices: [StoryChoice(textKey: "chapter.meetingBabis.scene0.choice0", nextSceneIndex: 1)]), StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.Characters.babis], narrationKey: "chapter.meetingBabis.scene1.narration", choices: [])]),
        ChapterContent(id: "kotsifi_arrives", order: 2, titleKey: "chapter.kotsifiArrives.title", descriptionKey: "chapter.kotsifiArrives.desc", imageName: AppAssets.Characters.kotsifi, scenes: [StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.Characters.babis], narrationKey: "chapter.kotsifiArrives.scene0.narration", choices: [StoryChoice(textKey: "chapter.kotsifiArrives.scene0.choice0", nextSceneIndex: 1)]), StoryScene(background: AppAssets.Backgrounds.forestDay, characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi], narrationKey: "chapter.kotsifiArrives.scene1.narration", choices: [])]),
        ChapterContent(id: "clever_fox", order: 3, titleKey: "chapter.cleverFox.title", descriptionKey: "chapter.cleverFox.desc", imageName: AppAssets.Characters.fox, scenes: [StoryScene(background: AppAssets.Backgrounds.foxCave, characters: [AppAssets.Characters.fox], narrationKey: "chapter.cleverFox.scene0.narration", choices: [StoryChoice(textKey: "chapter.cleverFox.scene0.choice0", nextSceneIndex: 1), StoryChoice(textKey: "chapter.cleverFox.scene0.choice1", nextSceneIndex: 1)]), StoryScene(background: AppAssets.Backgrounds.foxCave, characters: [AppAssets.Characters.fox, AppAssets.Characters.babis], narrationKey: "chapter.cleverFox.scene1.narration", choices: [])]),
        ChapterContent(id: "forest_hero", order: 4, titleKey: "chapter.forestHero.title", descriptionKey: "chapter.forestHero.desc", imageName: AppAssets.Backgrounds.village, scenes: [StoryScene(background: AppAssets.Backgrounds.forestNight, characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi, AppAssets.Characters.fox], narrationKey: "chapter.forestHero.scene0.narration", choices: [StoryChoice(textKey: "chapter.forestHero.scene0.choice0", nextSceneIndex: 1)]), StoryScene(background: AppAssets.Backgrounds.village, characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi, AppAssets.Characters.fox], narrationKey: "chapter.forestHero.scene1.narration", choices: [])])
    ]
}
