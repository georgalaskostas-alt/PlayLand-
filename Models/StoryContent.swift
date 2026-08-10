import Foundation

struct StoryChoice: Identifiable {
    let id = UUID()
    let text: String
    /// Index of the scene to jump to. `nil` ends the story/chapter.
    let nextSceneIndex: Int?
}

struct StoryScene: Identifiable {
    let id = UUID()
    let background: String
    let characters: [String]
    let narration: String
    let choices: [StoryChoice]
}

struct StoryContent: Identifiable {
    let id: String
    let title: String
    let coverImageName: String
    let description: String
    let scenes: [StoryScene]
}

enum StoryLibrary {
    static let stories: [StoryContent] = [
        StoryContent(
            id: "babis_kotsifi",
            title: "Babis & Kotsifi",
            coverImageName: "babis_dinosaur",
            description: "A hungry dinosaur and a tiny bird become the best of friends.",
            scenes: [
                StoryScene(
                    background: "forest_background",
                    characters: ["babis_dinosaur"],
                    narration: "Babis the dinosaur woke up hungry. Suddenly he heard a little chirp coming from the bushes!",
                    choices: [
                        StoryChoice(text: "Follow the chirping sound", nextSceneIndex: 1),
                        StoryChoice(text: "Look for berries first", nextSceneIndex: 2)
                    ]
                ),
                StoryScene(
                    background: "forest_background",
                    characters: ["babis_dinosaur", "kotsifi_bird"],
                    narration: "Babis pushed the leaves aside and found Kotsifi the bird, tangled in a branch and tweeting for help!",
                    choices: [
                        StoryChoice(text: "Help Kotsifi right away", nextSceneIndex: 3)
                    ]
                ),
                StoryScene(
                    background: "forest_background",
                    characters: ["babis_dinosaur"],
                    narration: "Babis munched on some sweet berries. But that little chirp kept getting louder and closer...",
                    choices: [
                        StoryChoice(text: "Go check on the sound", nextSceneIndex: 1)
                    ]
                ),
                StoryScene(
                    background: "forest_background",
                    characters: ["babis_dinosaur", "kotsifi_bird"],
                    narration: "With his long neck, Babis gently freed Kotsifi. The little bird chirped happily and landed right on his nose!",
                    choices: [
                        StoryChoice(text: "Become best friends", nextSceneIndex: 4)
                    ]
                ),
                StoryScene(
                    background: "village_background",
                    characters: ["babis_dinosaur", "kotsifi_bird"],
                    narration: "From that day on, Babis and Kotsifi explored every corner of the forest together. The End!",
                    choices: []
                )
            ]
        ),
        StoryContent(
            id: "cave_crystals",
            title: "The Cave of Crystals",
            coverImageName: "cave_background",
            description: "Babis and Kotsifi discover a sparkling cave — and someone unexpected inside.",
            scenes: [
                StoryScene(
                    background: "forest_background",
                    characters: ["babis_dinosaur", "kotsifi_bird"],
                    narration: "While exploring, Babis and Kotsifi found a dark cave entrance glowing with a strange light.",
                    choices: [
                        StoryChoice(text: "Peek inside bravely", nextSceneIndex: 1),
                        StoryChoice(text: "Call out first", nextSceneIndex: 2)
                    ]
                ),
                StoryScene(
                    background: "cave_background",
                    characters: ["babis_dinosaur", "kotsifi_bird"],
                    narration: "Inside, the walls sparkled with beautiful crystals. Then a rustling sound echoed from deeper in the cave!",
                    choices: [
                        StoryChoice(text: "Follow the sound", nextSceneIndex: 3)
                    ]
                ),
                StoryScene(
                    background: "cave_background",
                    characters: ["babis_dinosaur", "kotsifi_bird"],
                    narration: "\"Hello?\" called Babis. His voice echoed off the crystal walls, and something rustled back in reply.",
                    choices: [
                        StoryChoice(text: "Walk in together", nextSceneIndex: 3)
                    ]
                ),
                StoryScene(
                    background: "fox_cave_background",
                    characters: ["alepou_fox", "babis_dinosaur"],
                    narration: "It was Alepou the fox, all alone and a little scared. \"I got lost chasing fireflies,\" she admitted.",
                    choices: [
                        StoryChoice(text: "Offer to help her home", nextSceneIndex: 4)
                    ]
                ),
                StoryScene(
                    background: "village_background",
                    characters: ["babis_dinosaur", "alepou_fox", "kotsifi_bird"],
                    narration: "Babis and Kotsifi walked Alepou safely home. She wasn't so scary after all — just a new friend! The End!",
                    choices: []
                )
            ]
        ),
        StoryContent(
            id: "forest_hero",
            title: "The Night Guardian",
            coverImageName: "forest_background_night",
            description: "When night falls over the forest, Babis learns what it means to be a hero.",
            scenes: [
                StoryScene(
                    background: "forest_background_night",
                    characters: ["babis_dinosaur"],
                    narration: "The sun went down and the forest grew dark. Babis heard the little animals whimpering, afraid of the shadows.",
                    choices: [
                        StoryChoice(text: "Comfort the animals", nextSceneIndex: 1),
                        StoryChoice(text: "Search for the source of fear", nextSceneIndex: 2)
                    ]
                ),
                StoryScene(
                    background: "forest_background_night",
                    characters: ["babis_dinosaur", "kotsifi_bird"],
                    narration: "\"Don't worry,\" Babis said gently, and Kotsifi sang a soft song to calm everyone down.",
                    choices: [
                        StoryChoice(text: "Go find what scared them", nextSceneIndex: 2)
                    ]
                ),
                StoryScene(
                    background: "forest_background_night",
                    characters: ["babis_dinosaur", "alepou_fox"],
                    narration: "It was only Alepou, casting a big shadow while looking for her way home in the dark.",
                    choices: [
                        StoryChoice(text: "Light the way together", nextSceneIndex: 3)
                    ]
                ),
                StoryScene(
                    background: "forest_background_night",
                    characters: ["babis_dinosaur", "alepou_fox", "kotsifi_bird"],
                    narration: "Babis walked ahead so everyone could follow his silhouette safely home through the dark forest.",
                    choices: [
                        StoryChoice(text: "Celebrate in the village", nextSceneIndex: 4)
                    ]
                ),
                StoryScene(
                    background: "village_background",
                    characters: ["babis_dinosaur", "kotsifi_bird", "alepou_fox"],
                    narration: "The whole village cheered for Babis, the forest's very own Night Guardian. The End!",
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
    let title: String
    let description: String
    let imageName: String
    let scenes: [StoryScene]
}

enum ChapterLibrary {
    static let chapters: [ChapterContent] = [
        ChapterContent(
            id: "meeting_babis",
            order: 1,
            title: "Meeting Babis",
            description: "Say hello to the friendliest dinosaur in the forest.",
            imageName: "babis_dinosaur",
            scenes: [
                StoryScene(
                    background: "forest_background",
                    characters: ["babis_dinosaur"],
                    narration: "Deep in a sunny forest lived a big, gentle dinosaur named Babis, who loved to explore.",
                    choices: [
                        StoryChoice(text: "Wave hello to Babis", nextSceneIndex: 1)
                    ]
                ),
                StoryScene(
                    background: "forest_background",
                    characters: ["babis_dinosaur"],
                    narration: "Babis smiled with his whole face and let out a friendly rumble. \"A new friend!\" he thought.",
                    choices: []
                )
            ]
        ),
        ChapterContent(
            id: "kotsifi_arrives",
            order: 2,
            title: "Kotsifi Arrives",
            description: "A tiny bird lands right on Babis' nose.",
            imageName: "kotsifi_bird",
            scenes: [
                StoryScene(
                    background: "forest_background",
                    characters: ["babis_dinosaur"],
                    narration: "One breezy morning, a small bird came fluttering down from the trees.",
                    choices: [
                        StoryChoice(text: "Let the bird land", nextSceneIndex: 1)
                    ]
                ),
                StoryScene(
                    background: "forest_background",
                    characters: ["babis_dinosaur", "kotsifi_bird"],
                    narration: "Kotsifi landed right on Babis' nose and chirped a cheerful tune. A new friendship had begun!",
                    choices: []
                )
            ]
        ),
        ChapterContent(
            id: "clever_fox",
            order: 3,
            title: "The Clever Fox",
            description: "A mischievous fox has a trick up her sleeve.",
            imageName: "alepou_fox",
            scenes: [
                StoryScene(
                    background: "fox_cave_background",
                    characters: ["alepou_fox"],
                    narration: "Near her cave, Alepou the fox loved playing tricks on anyone who passed by.",
                    choices: [
                        StoryChoice(text: "Approach carefully", nextSceneIndex: 1),
                        StoryChoice(text: "Say hello loudly", nextSceneIndex: 1)
                    ]
                ),
                StoryScene(
                    background: "fox_cave_background",
                    characters: ["alepou_fox", "babis_dinosaur"],
                    narration: "Alepou grinned, but when Babis just smiled kindly back, she decided a new friend was more fun than a trick.",
                    choices: []
                )
            ]
        ),
        ChapterContent(
            id: "forest_hero",
            order: 4,
            title: "Forest Hero",
            description: "Babis helps his friends and becomes the forest's hero.",
            imageName: "village_background",
            scenes: [
                StoryScene(
                    background: "forest_background_night",
                    characters: ["babis_dinosaur", "kotsifi_bird", "alepou_fox"],
                    narration: "When night fell and the little animals felt scared, Babis led everyone safely home.",
                    choices: [
                        StoryChoice(text: "Guide everyone to the village", nextSceneIndex: 1)
                    ]
                ),
                StoryScene(
                    background: "village_background",
                    characters: ["babis_dinosaur", "kotsifi_bird", "alepou_fox"],
                    narration: "The whole village cheered for Babis, Kotsifi and Alepou — the forest's very own heroes!",
                    choices: []
                )
            ]
        )
    ]
}
