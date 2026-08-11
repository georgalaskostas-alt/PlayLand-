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

/// A treasure chest: tap it, meet a short approach dialogue, then win an
/// existing mini-game (via `ChallengeLauncherView`) to open it. `id` is the
/// persistence key for "this unique chest has been opened."
struct ChestDefinition {
    let id: String
    let challenge: RPGChallenge
    /// Shown when the chest is tapped while still locked — a "not yet"
    /// hint, never a hard wall.
    let lockedHintDialogue: [DialogueNode]
    /// Shown when the chest is tapped, before the challenge launches.
    let approachDialogue: [DialogueNode]
    /// Shown when an already-opened chest is tapped again.
    let openedFlavorDialogue: [DialogueNode]
    /// Spoken (and shown) once the chest opens, after the reward.
    let rewardPraiseKey: String
}

/// The four states a chest can be in. `.opening` is deliberately not here —
/// it's a transient view animation, not something that's ever persisted.
enum ChestVisualState {
    case locked
    case challengeAvailable
    case opened
}

/// A tappable thing in a `WorldLocation`: an NPC, a landmark, a resource
/// pickup, or a chest. `questId`, when present, is progressed by one step
/// the first time this object is interacted with (or, for a chest, the
/// first time it's successfully opened).
struct WorldObject: Identifiable {
    let id: String
    let emoji: String
    /// Placement within the scene as a fraction of its width/height, so
    /// layout doesn't depend on a fixed screen size.
    let position: UnitPoint
    /// Unused (pass `[]`) when `chest` is set — a chest speaks through its
    /// own locked/approach/opened dialogue instead.
    let dialogue: [DialogueNode]
    var questId: String?
    var collectibleItemId: String?
    var collectibleItemCount: Int = 1
    var chest: ChestDefinition?
    /// Whether this object appears in its location at all. Defaults to
    /// always-visible; a chapter-gated object (like a chest that "appears"
    /// once an earlier goal is met) sets this instead of needing a whole
    /// separate location.
    var unlockRequirement: LocationUnlockRequirement = .alwaysUnlocked
    /// Production scenery art for this object (a tree, a rock, a flower
    /// patch), if it has any — `nil` for objects with no environment-art
    /// equivalent yet. `emoji` remains the fallback whenever this is `nil`
    /// or doesn't resolve. Collectible objects don't need this field: their
    /// world-tile art comes from `ItemLibrary` via `collectibleItemId`
    /// instead, so item art has exactly one source of truth.
    var assetName: String? = nil
}

struct WorldLocation: Identifiable {
    let id: String
    let titleKey: String
    let backgroundAsset: String
    /// The playable world surface for this location (see
    /// `AppAssets.Grounds`). Falls back to `backgroundAsset` — today's
    /// exact look — until real ground art exists; see
    /// `WorldLocation.resolvedGroundAsset`.
    let groundAsset: String
    let objects: [WorldObject]

    var resolvedGroundAsset: String {
        AppAssets.exists(groundAsset) ? groundAsset : backgroundAsset
    }
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
            groundAsset: AppAssets.Grounds.village,
            objects: [
                WorldObject(
                    id: "village_kotsifi",
                    emoji: "🐦",
                    position: UnitPoint(x: 0.7, y: 0.55),
                    dialogue: [
                        DialogueNode(
                            speakerKey: "adventure.kotsifiName",
                            portraitAsset: KotsifiAssetResolver.portraitAsset(for: .happy),
                            textKey: "dialogue.village.kotsifi.line0",
                            choices: [DialogueChoice(textKey: "action.continue", nextIndex: 1)]
                        ),
                        DialogueNode(
                            speakerKey: "adventure.kotsifiName",
                            portraitAsset: KotsifiAssetResolver.portraitAsset(for: .talking),
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
                    ],
                    assetName: AppAssets.Environment.tree1
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
                    ],
                    assetName: AppAssets.Environment.flowerPatch1
                ),
                // MARK: The Lost Forest Supplies — Chapter 1, "The Empty Basket"
                WorldObject(
                    id: "village_berries",
                    emoji: "🫐",
                    position: UnitPoint(x: 0.3, y: 0.6),
                    dialogue: [
                        DialogueNode(speakerKey: WorldSpeaker.narrator, portraitAsset: AppAssets.Characters.babis, textKey: "dialogue.village.berries", choices: [])
                    ],
                    questId: "gather_supplies",
                    collectibleItemId: "berries"
                ),
                WorldObject(
                    id: "village_water",
                    emoji: "💧",
                    position: UnitPoint(x: 0.6, y: 0.32),
                    dialogue: [
                        DialogueNode(speakerKey: WorldSpeaker.narrator, portraitAsset: AppAssets.Characters.babis, textKey: "dialogue.village.water", choices: [])
                    ],
                    questId: "gather_supplies",
                    collectibleItemId: "water"
                ),
                // MARK: The Lost Forest Supplies — Chapter 2, "The Locked Chest"
                WorldObject(
                    id: "village_chest",
                    emoji: "🎁",
                    position: UnitPoint(x: 0.82, y: 0.68),
                    dialogue: [],
                    chest: ChestDefinition(
                        id: "village_chest",
                        challenge: RPGChallenge(
                            id: "village_chest_challenge",
                            gameType: .memory,
                            difficulty: .easy,
                            rewardItemId: "map_fragment",
                            rewardItemCount: 1,
                            rewardStars: 5,
                            questIdToProgress: "open_first_chest"
                        ),
                        lockedHintDialogue: [
                            DialogueNode(speakerKey: WorldSpeaker.narrator, portraitAsset: AppAssets.Characters.babis, textKey: "dialogue.village.chest.locked", choices: [])
                        ],
                        approachDialogue: [
                            DialogueNode(speakerKey: "adventure.kotsifiName", portraitAsset: KotsifiAssetResolver.portraitAsset(for: .surprised), textKey: "dialogue.village.chest.approach0", choices: [DialogueChoice(textKey: "action.continue", nextIndex: 1)]),
                            DialogueNode(speakerKey: WorldSpeaker.narrator, portraitAsset: AppAssets.Characters.babis, textKey: "dialogue.village.chest.approach1", choices: [])
                        ],
                        openedFlavorDialogue: [
                            DialogueNode(speakerKey: WorldSpeaker.narrator, portraitAsset: AppAssets.Characters.babis, textKey: "dialogue.village.chest.opened", choices: [])
                        ],
                        rewardPraiseKey: "dialogue.village.chest.reward"
                    ),
                    unlockRequirement: .questCompleted("gather_supplies")
                )
            ]
        ),
        WorldLocation(
            id: "forest",
            titleKey: "world.forest.title",
            backgroundAsset: AppAssets.Backgrounds.forestDay,
            groundAsset: AppAssets.Grounds.forest,
            objects: [
                WorldObject(
                    id: "forest_tree",
                    emoji: "🌳",
                    position: UnitPoint(x: 0.2, y: 0.35),
                    dialogue: [
                        DialogueNode(speakerKey: WorldSpeaker.narrator, portraitAsset: AppAssets.Characters.babis, textKey: "adventure.explore.tree", choices: [])
                    ],
                    assetName: AppAssets.Environment.tree2
                ),
                WorldObject(
                    id: "forest_rock",
                    emoji: "🪨",
                    position: UnitPoint(x: 0.8, y: 0.4),
                    dialogue: [
                        DialogueNode(speakerKey: WorldSpeaker.narrator, portraitAsset: AppAssets.Characters.babis, textKey: "adventure.explore.rock", choices: [])
                    ],
                    assetName: AppAssets.Environment.rock1
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
            groundAsset: AppAssets.Grounds.crystalCave,
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
            groundAsset: AppAssets.Grounds.foxArea,
            objects: [
                WorldObject(
                    id: "fox_cave_alepou",
                    emoji: "🦊",
                    position: UnitPoint(x: 0.5, y: 0.5),
                    dialogue: [
                        DialogueNode(speakerKey: "adventure.foxName", portraitAsset: FoxAssetResolver.portraitAsset(for: .friendly), textKey: "adventure.explore.foxDialogue", choices: [])
                    ],
                    questId: "uncover_fox_secret"
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
