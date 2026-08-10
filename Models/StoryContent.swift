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
}

struct StoryContent: Identifiable {
    let id: String
    let titleKey: String
    let descriptionKey: String
    let coverImageName: String
    let scenes: [StoryScene]
}

enum StoryLibrary {
    static let stories: [StoryContent] = [
        StoryContent(
            id: "babis_kotsifi",
            titleKey: "story.babisKotsifi.title",
            descriptionKey: "story.babisKotsifi.desc",
            coverImageName: AppAssets.Characters.babis,
            scenes: [
                StoryScene(
                    background: AppAssets.Backgrounds.forestDay,
                    characters: [AppAssets.Characters.babis],
                    narrationKey: "story.babisKotsifi.scene0.narration",
                    choices: [
                        StoryChoice(textKey: "story.babisKotsifi.scene0.choice0", nextSceneIndex: 1),
                        StoryChoice(textKey: "story.babisKotsifi.scene0.choice1", nextSceneIndex: 2)
                    ]
                ),
                StoryScene(
                    background: AppAssets.Backgrounds.forestDay,
                    characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi],
                    narrationKey: "story.babisKotsifi.scene1.narration",
                    choices: [
                        StoryChoice(textKey: "story.babisKotsifi.scene1.choice0", nextSceneIndex: 3)
                    ]
                ),
                StoryScene(
                    background: AppAssets.Backgrounds.forestDay,
                    characters: [AppAssets.Characters.babis],
                    narrationKey: "story.babisKotsifi.scene2.narration",
                    choices: [
                        StoryChoice(textKey: "story.babisKotsifi.scene2.choice0", nextSceneIndex: 1)
                    ]
                ),
                StoryScene(
                    background: AppAssets.Backgrounds.forestDay,
                    characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi],
                    narrationKey: "story.babisKotsifi.scene3.narration",
                    choices: [
                        StoryChoice(textKey: "story.babisKotsifi.scene3.choice0", nextSceneIndex: 4)
                    ]
                ),
                StoryScene(
                    background: AppAssets.Backgrounds.village,
                    characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi],
                    narrationKey: "story.babisKotsifi.scene4.narration",
                    choices: []
                )
            ]
        ),
        StoryContent(
            id: "cave_crystals",
            titleKey: "story.caveCrystals.title",
            descriptionKey: "story.caveCrystals.desc",
            coverImageName: AppAssets.Backgrounds.cave,
            scenes: [
                StoryScene(
                    background: AppAssets.Backgrounds.forestDay,
                    characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi],
                    narrationKey: "story.caveCrystals.scene0.narration",
                    choices: [
                        StoryChoice(textKey: "story.caveCrystals.scene0.choice0", nextSceneIndex: 1),
                        StoryChoice(textKey: "story.caveCrystals.scene0.choice1", nextSceneIndex: 2)
                    ]
                ),
                StoryScene(
                    background: AppAssets.Backgrounds.cave,
                    characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi],
                    narrationKey: "story.caveCrystals.scene1.narration",
                    choices: [
                        StoryChoice(textKey: "story.caveCrystals.scene1.choice0", nextSceneIndex: 3)
                    ]
                ),
                StoryScene(
                    background: AppAssets.Backgrounds.cave,
                    characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi],
                    narrationKey: "story.caveCrystals.scene2.narration",
                    choices: [
                        StoryChoice(textKey: "story.caveCrystals.scene2.choice0", nextSceneIndex: 3)
                    ]
                ),
                StoryScene(
                    background: AppAssets.Backgrounds.foxCave,
                    characters: [AppAssets.Characters.fox, AppAssets.Characters.babis],
                    narrationKey: "story.caveCrystals.scene3.narration",
                    choices: [
                        StoryChoice(textKey: "story.caveCrystals.scene3.choice0", nextSceneIndex: 4)
                    ]
                ),
                StoryScene(
                    background: AppAssets.Backgrounds.village,
                    characters: [AppAssets.Characters.babis, AppAssets.Characters.fox, AppAssets.Characters.kotsifi],
                    narrationKey: "story.caveCrystals.scene4.narration",
                    choices: []
                )
            ]
        ),
        StoryContent(
            id: "forest_hero",
            titleKey: "story.forestHero.title",
            descriptionKey: "story.forestHero.desc",
            coverImageName: AppAssets.Backgrounds.forestNight,
            scenes: [
                StoryScene(
                    background: AppAssets.Backgrounds.forestNight,
                    characters: [AppAssets.Characters.babis],
                    narrationKey: "story.forestHero.scene0.narration",
                    choices: [
                        StoryChoice(textKey: "story.forestHero.scene0.choice0", nextSceneIndex: 1),
                        StoryChoice(textKey: "story.forestHero.scene0.choice1", nextSceneIndex: 2)
                    ]
                ),
                StoryScene(
                    background: AppAssets.Backgrounds.forestNight,
                    characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi],
                    narrationKey: "story.forestHero.scene1.narration",
                    choices: [
                        StoryChoice(textKey: "story.forestHero.scene1.choice0", nextSceneIndex: 2)
                    ]
                ),
                StoryScene(
                    background: AppAssets.Backgrounds.forestNight,
                    characters: [AppAssets.Characters.babis, AppAssets.Characters.fox],
                    narrationKey: "story.forestHero.scene2.narration",
                    choices: [
                        StoryChoice(textKey: "story.forestHero.scene2.choice0", nextSceneIndex: 3)
                    ]
                ),
                StoryScene(
                    background: AppAssets.Backgrounds.forestNight,
                    characters: [AppAssets.Characters.babis, AppAssets.Characters.fox, AppAssets.Characters.kotsifi],
                    narrationKey: "story.forestHero.scene3.narration",
                    choices: [
                        StoryChoice(textKey: "story.forestHero.scene3.choice0", nextSceneIndex: 4)
                    ]
                ),
                StoryScene(
                    background: AppAssets.Backgrounds.village,
                    characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi, AppAssets.Characters.fox],
                    narrationKey: "story.forestHero.scene4.narration",
                    choices: []
                )
            ]
        )
    ]

    static func story(withId id: String) -> StoryContent? {
        stories.first { $0.id == id }
    }
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
        ChapterContent(
            id: "meeting_babis",
            order: 1,
            titleKey: "chapter.meetingBabis.title",
            descriptionKey: "chapter.meetingBabis.desc",
            imageName: AppAssets.Characters.babis,
            scenes: [
                StoryScene(
                    background: AppAssets.Backgrounds.forestDay,
                    characters: [AppAssets.Characters.babis],
                    narrationKey: "chapter.meetingBabis.scene0.narration",
                    choices: [
                        StoryChoice(textKey: "chapter.meetingBabis.scene0.choice0", nextSceneIndex: 1)
                    ]
                ),
                StoryScene(
                    background: AppAssets.Backgrounds.forestDay,
                    characters: [AppAssets.Characters.babis],
                    narrationKey: "chapter.meetingBabis.scene1.narration",
                    choices: []
                )
            ]
        ),
        ChapterContent(
            id: "kotsifi_arrives",
            order: 2,
            titleKey: "chapter.kotsifiArrives.title",
            descriptionKey: "chapter.kotsifiArrives.desc",
            imageName: AppAssets.Characters.kotsifi,
            scenes: [
                StoryScene(
                    background: AppAssets.Backgrounds.forestDay,
                    characters: [AppAssets.Characters.babis],
                    narrationKey: "chapter.kotsifiArrives.scene0.narration",
                    choices: [
                        StoryChoice(textKey: "chapter.kotsifiArrives.scene0.choice0", nextSceneIndex: 1)
                    ]
                ),
                StoryScene(
                    background: AppAssets.Backgrounds.forestDay,
                    characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi],
                    narrationKey: "chapter.kotsifiArrives.scene1.narration",
                    choices: []
                )
            ]
        ),
        ChapterContent(
            id: "clever_fox",
            order: 3,
            titleKey: "chapter.cleverFox.title",
            descriptionKey: "chapter.cleverFox.desc",
            imageName: AppAssets.Characters.fox,
            scenes: [
                StoryScene(
                    background: AppAssets.Backgrounds.foxCave,
                    characters: [AppAssets.Characters.fox],
                    narrationKey: "chapter.cleverFox.scene0.narration",
                    choices: [
                        StoryChoice(textKey: "chapter.cleverFox.scene0.choice0", nextSceneIndex: 1),
                        StoryChoice(textKey: "chapter.cleverFox.scene0.choice1", nextSceneIndex: 1)
                    ]
                ),
                StoryScene(
                    background: AppAssets.Backgrounds.foxCave,
                    characters: [AppAssets.Characters.fox, AppAssets.Characters.babis],
                    narrationKey: "chapter.cleverFox.scene1.narration",
                    choices: []
                )
            ]
        ),
        ChapterContent(
            id: "forest_hero",
            order: 4,
            titleKey: "chapter.forestHero.title",
            descriptionKey: "chapter.forestHero.desc",
            imageName: AppAssets.Backgrounds.village,
            scenes: [
                StoryScene(
                    background: AppAssets.Backgrounds.forestNight,
                    characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi, AppAssets.Characters.fox],
                    narrationKey: "chapter.forestHero.scene0.narration",
                    choices: [
                        StoryChoice(textKey: "chapter.forestHero.scene0.choice0", nextSceneIndex: 1)
                    ]
                ),
                StoryScene(
                    background: AppAssets.Backgrounds.village,
                    characters: [AppAssets.Characters.babis, AppAssets.Characters.kotsifi, AppAssets.Characters.fox],
                    narrationKey: "chapter.forestHero.scene1.narration",
                    choices: []
                )
            ]
        )
    ]
}
