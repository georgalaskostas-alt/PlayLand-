import Foundation
import SwiftUI

/// Sentinel speaker key meaning "no named speaker" — flavor text about an
/// object (a tree, a rock) rather than a character talking.
enum WorldSpeaker {
    static let narrator = "world.narrator"
}

/// A single line of dialogue from a character, optionally branching into
/// choices. Sequences of these drive every NPC conversation in the RPG —
/// one reusable engine (`DialogueView`) plays them, so dialogue UI is never
/// hand-built per location.
struct DialogueChoice: Identifiable {
    let id = UUID()
    let textKey: String
    /// Index of the next node in the same sequence. `nil` ends the dialogue.
    let nextIndex: Int?
}

struct DialogueNode: Identifiable {
    let id = UUID()
    let speakerKey: String
    let portraitAsset: String
    let textKey: String
    let choices: [DialogueChoice]
}

/// A tappable thing in a `WorldLocation`: an NPC, a landmark, a collectible.
/// `questId`, when present, is progressed by one step the first time this
/// object is interacted with in a visit.
struct WorldObject: Identifiable {
    let id: String
    let emoji: String
    /// Placement within the scene as a fraction of its width/height, so
    /// layout doesn't depend on a fixed screen size.
    let position: UnitPoint
    let dialogue: [DialogueNode]
    var questId: String?
    var collectibleItemId: String?
}

struct WorldLocation: Identifiable {
    let id: String
    let titleKey: String
    let backgroundAsset: String
    let objects: [WorldObject]
}

enum LocationUnlockRequirement {
    case alwaysUnlocked
    case questCompleted(String)
    case chapterCompleted(String)
}

enum WorldLibrary {
    static let locations: [WorldLocation] = [
        WorldLocation(
            id: "village",
            titleKey: "world.village.title",
            backgroundAsset: AppAssets.Backgrounds.village,
            objects: [
                WorldObject(
                    id: "village_kotsifi",
                    emoji: "🐦",
                    position: UnitPoint(x: 0.7, y: 0.55),
                    dialogue: [
                        DialogueNode(
                            speakerKey: "adventure.kotsifiName",
                            portraitAsset: AppAssets.Characters.kotsifi,
                            textKey: "dialogue.village.kotsifi.line0",
                            choices: [DialogueChoice(textKey: "action.continue", nextIndex: 1)]
                        ),
                        DialogueNode(
                            speakerKey: "adventure.kotsifiName",
                            portraitAsset: AppAssets.Characters.kotsifi,
                            textKey: "dialogue.village.kotsifi.line1",
                            choices: []
                        )
                    ],
                    questId: "meet_kotsifi"
                ),
                WorldObject(
                    id: "village_tree",
                    emoji: "🌳",
                    position: UnitPoint(x: 0.18, y: 0.4),
                    dialogue: [
                        DialogueNode(
                            speakerKey: WorldSpeaker.narrator,
                            portraitAsset: AppAssets.Characters.babis,
                            textKey: "adventure.explore.tree",
                            choices: []
                        )
                    ]
                ),
                WorldObject(
                    id: "village_flowers",
                    emoji: "🌼",
                    position: UnitPoint(x: 0.45, y: 0.75),
                    dialogue: [
                        DialogueNode(
                            speakerKey: WorldSpeaker.narrator,
                            portraitAsset: AppAssets.Characters.babis,
                            textKey: "dialogue.village.flowers",
                            choices: []
                        )
                    ]
                )
            ]
        ),
        WorldLocation(
            id: "forest",
            titleKey: "world.forest.title",
            backgroundAsset: AppAssets.Backgrounds.forestDay,
            objects: [
                WorldObject(
                    id: "forest_tree",
                    emoji: "🌳",
                    position: UnitPoint(x: 0.2, y: 0.35),
                    dialogue: [
                        DialogueNode(speakerKey: WorldSpeaker.narrator, portraitAsset: AppAssets.Characters.babis, textKey: "adventure.explore.tree", choices: [])
                    ]
                ),
                WorldObject(
                    id: "forest_rock",
                    emoji: "🪨",
                    position: UnitPoint(x: 0.8, y: 0.4),
                    dialogue: [
                        DialogueNode(speakerKey: WorldSpeaker.narrator, portraitAsset: AppAssets.Characters.babis, textKey: "adventure.explore.rock", choices: [])
                    ]
                ),
                WorldObject(
                    id: "forest_footprints",
                    emoji: "🐾",
                    position: UnitPoint(x: 0.5, y: 0.65),
                    dialogue: [
                        DialogueNode(speakerKey: WorldSpeaker.narrator, portraitAsset: AppAssets.Characters.babis, textKey: "dialogue.forest.footprints", choices: [])
                    ]
                ),
                WorldObject(
                    id: "forest_cave_entrance",
                    emoji: "🕳️",
                    position: UnitPoint(x: 0.5, y: 0.2),
                    dialogue: [
                        DialogueNode(speakerKey: WorldSpeaker.narrator, portraitAsset: AppAssets.Characters.babis, textKey: "dialogue.forest.caveEntrance", choices: [])
                    ],
                    questId: "find_cave_entrance"
                )
            ]
        ),
        WorldLocation(
            id: "crystal_cave",
            titleKey: "world.crystalCave.title",
            backgroundAsset: AppAssets.Backgrounds.cave,
            objects: [
                WorldObject(id: "stone_1", emoji: "💎", position: UnitPoint(x: 0.25, y: 0.35), dialogue: [
                    DialogueNode(speakerKey: WorldSpeaker.narrator, portraitAsset: AppAssets.Characters.babis, textKey: "dialogue.cave.stone", choices: [])
                ], questId: "collect_stones", collectibleItemId: "crystal"),
                WorldObject(id: "stone_2", emoji: "💎", position: UnitPoint(x: 0.55, y: 0.55), dialogue: [
                    DialogueNode(speakerKey: WorldSpeaker.narrator, portraitAsset: AppAssets.Characters.babis, textKey: "dialogue.cave.stone", choices: [])
                ], questId: "collect_stones", collectibleItemId: "crystal"),
                WorldObject(id: "stone_3", emoji: "💎", position: UnitPoint(x: 0.78, y: 0.3), dialogue: [
                    DialogueNode(speakerKey: WorldSpeaker.narrator, portraitAsset: AppAssets.Characters.babis, textKey: "dialogue.cave.stone", choices: [])
                ], questId: "collect_stones", collectibleItemId: "crystal")
            ]
        ),
        WorldLocation(
            id: "fox_cave",
            titleKey: "world.foxCave.title",
            backgroundAsset: AppAssets.Backgrounds.foxCave,
            objects: [
                WorldObject(
                    id: "fox_cave_alepou",
                    emoji: "🦊",
                    position: UnitPoint(x: 0.5, y: 0.5),
                    dialogue: [
                        DialogueNode(speakerKey: "adventure.foxName", portraitAsset: AppAssets.Characters.fox, textKey: "adventure.explore.foxDialogue", choices: [])
                    ]
                )
            ]
        )
    ]

    static let unlockRequirements: [String: LocationUnlockRequirement] = [
        "village": .alwaysUnlocked,
        "forest": .questCompleted("meet_kotsifi"),
        "crystal_cave": .questCompleted("find_cave_entrance"),
        "fox_cave": .chapterCompleted("clever_fox")
    ]

    static func location(withId id: String) -> WorldLocation? {
        locations.first { $0.id == id }
    }
}
