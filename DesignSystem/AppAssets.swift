import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Type-safe names for every image in `Assets.xcassets`, grouped by category
/// so raw string literals stop being duplicated across the codebase.
///
/// Some names below (see the "Planned" groups) are not in the asset catalog
/// yet. Referencing them is safe: `AppAssets.image(_:)` never crashes, and
/// falls back to a dashed placeholder glyph that makes a missing asset
/// obvious during development instead of silently rendering blank.
enum AppAssets {
    enum Characters {
        static let babis = "babis_dinosaur"
        static let babisSide = "babis_dinosaur_side"
        static let kotsifi = "kotsifi_bird"
        static let kotsifiSide = "kotsifi_bird_side"
        static let fox = "alepou_fox"
    }

    enum Backgrounds {
        static let forestDay = "forest_background"
        static let forestNight = "forest_background_night"
        static let cave = "cave_background"
        static let foxCave = "fox_cave_background"
        static let village = "village_background"
    }

    enum Badges {
        static let sheet = "badges"
    }

    /// Icons already present in Assets.xcassets today.
    enum GameIcons {
        static let generic = "icon_game"
        static let letterGame = "icon_letter_game"
    }

    /// Icons planned per the product spec but not yet added to the asset
    /// catalog. `AppAssets.image(_:)` falls back gracefully until they land.
    enum PlannedGameIcons {
        static let wordMatch = "icon_word_match"
        static let wordSearch = "icon_word_search"
        static let wordScramble = "icon_word_scramble"
        static let memoryGame = "icon_memory_game"
        static let dinoDig = "icon_dino_dig"
        static let dinoMatch = "icon_dino_match"
        static let dinoFarm = "icon_dino_farm"
        static let dinoSort = "icon_dino_sort"
    }

    /// UI glyphs planned per the product spec but not yet added to the asset
    /// catalog. `AppAssets.image(_:)` falls back gracefully until they land.
    enum PlannedUI {
        static let star = "ui_star"
        static let check = "ui_check"
        static let lock = "ui_lock"
        static let play = "ui_play"
        static let book = "ui_book"
        static let paw = "ui_paw"
        static let gamepad = "ui_gamepad"
        static let card = "ui_card"
        /// Introduced during the Phase 0 pass for the Adventure tab icon;
        /// not part of the originally specified asset list.
        static let map = "ui_map"
        /// Introduced for the "replay spoken instruction" control.
        static let speaker = "ui_speaker"
        /// Introduced for the campaign/quest-log entry point.
        static let scroll = "ui_scroll"
    }

    /// Chests and the village's story-basket prop. Not yet in the catalog
    /// as of this pass — every usage is routed through `AppAssets.image(_:)`
    /// or `AppAssets.exists(_:)`, so they light up the moment art lands.
    enum PlannedProps {
        static let chestClosed = "chest_closed"
        static let chestOpen = "chest_open"
        static let foodBasketEmpty = "food_basket_empty"
        static let foodBasketFull = "food_basket_full"
    }

    /// Non-interactive scenery used to dress `WorldLocation`s. Referenced by
    /// `WorldObject.assetName` for the objects that already exist as emoji
    /// today (a tree, a rock, a flower patch) — see `WorldContent.swift`.
    /// The rest (bushes, stump, sign, log, mushrooms) have no corresponding
    /// `WorldObject` yet, so these names are wired but currently unused;
    /// see the asset integration report.
    enum Environment {
        static let tree1 = "tree_01"
        static let tree2 = "tree_02"
        static let tree3 = "tree_03"
        static let bush1 = "bush_01"
        static let bush2 = "bush_02"
        static let rock1 = "rock_01"
        static let rock2 = "rock_02"
        static let flowerPatch1 = "flower_patch_01"
        static let treeStump = "tree_stump"
        static let woodSign = "wood_sign"
        static let log = "log"
        static let mushrooms = "mushrooms"
    }

    /// The playable "world surface" for each `WorldLocation`, distinct from
    /// `Backgrounds` (which also serves the hub's small decorative
    /// thumbnails and Story scenes). See `WorldLocation.groundAsset`.
    enum Grounds {
        static let forest = "rpg_forest_ground_01"
        static let village = "rpg_village_ground"
        static let crystalCave = "rpg_crystal_cave_ground"
        /// No "Night Forest" `WorldLocation` exists yet (only a `.comingSoon`
        /// campaign stub) — wired for when one is built, unused today.
        static let nightForest = "rpg_night_forest_ground"
        static let foxArea = "rpg_fox_area_ground"
    }

    /// Kotsifi's emotional/activity states. See `KotsifiVisualState`.
    enum KotsifiStates {
        static let idle = "kotsifi_idle"
        static let happy = "kotsifi_happy"
        static let surprised = "kotsifi_surprised"
        static let talking = "kotsifi_talking"
        static let fly1 = "kotsifi_fly_01"
        static let fly2 = "kotsifi_fly_02"
        static let fly3 = "kotsifi_fly_03"
    }

    /// Alepou (the fox)'s emotional states. See `FoxVisualState`.
    enum FoxStates {
        static let neutral = "fox_neutral"
        static let smirk = "fox_smirk"
        static let surprised = "fox_surprised"
        static let worried = "fox_worried"
        static let friendly = "fox_friendly"
        static let talking = "fox_talking"
    }

    /// Dino Farm care-loop props (bowls, cleaning feedback).
    enum DinoFarmProps {
        static let foodBowlEmpty = "food_bowl_empty"
        static let foodBowlFull = "food_bowl_full"
        static let waterBowlEmpty = "water_bowl_empty"
        static let waterBowlFull = "water_bowl_full"
        static let cleaningBrush = "cleaning_brush"
        static let mudSplash = "mud_splash"
        static let soapBubbles = "soap_bubbles"
    }

    /// A placeholder glyph shown in development when a named asset is
    /// missing from the catalog, so a gap is obvious instead of blank space.
    private static let missingAssetPlaceholder = "questionmark.square.dashed"

    /// Whether `name` currently exists in the asset catalog. The single
    /// primitive every resolver (`BabisAssetResolver`, `KotsifiAssetResolver`,
    /// `FoxAssetResolver`, `ItemDefinition`, world-object/ground rendering)
    /// is built on, so there's exactly one asset-existence check in the app.
    static func exists(_ name: String) -> Bool {
        #if canImport(UIKit)
        return UIImage(named: name) != nil
        #else
        return false
        #endif
    }

    /// Resolves the correct story illustration for the active app language.
    /// Greek always uses the original asset. Every other language uses the
    /// matching `_global` asset only when that asset actually exists; scenes
    /// without a global version automatically keep their original artwork.
    ///
    /// Example:
    /// `story_babis_kotsifi_05` -> `story_babis_kotsifi_05_global`
    /// for non-Greek languages, but only if the global asset is installed.
    static func storyIllustration(_ baseName: String, language: AppLanguage) -> String {
        guard language != .greek else { return baseName }
        let globalName = "\(baseName)_global"
        return exists(globalName) ? globalName : baseName
    }

    /// Returns `Image(name)` when the asset exists in the catalog, or a
    /// neutral system placeholder otherwise. Never crashes on a missing name.
    static func image(_ name: String) -> Image {
        exists(name) ? Image(name) : Image(systemName: missingAssetPlaceholder)
    }

    /// All planned-but-not-yet-added asset names, for diagnostics/QA builds.
    static var missingAssetNames: [String] {
        let planned = [
            PlannedGameIcons.wordMatch, PlannedGameIcons.wordSearch, PlannedGameIcons.wordScramble,
            PlannedGameIcons.memoryGame, PlannedGameIcons.dinoDig, PlannedGameIcons.dinoMatch,
            PlannedGameIcons.dinoFarm, PlannedGameIcons.dinoSort,
            PlannedUI.star, PlannedUI.check, PlannedUI.lock, PlannedUI.play,
            PlannedUI.book, PlannedUI.paw, PlannedUI.gamepad, PlannedUI.card, PlannedUI.map, PlannedUI.speaker, PlannedUI.scroll,
            PlannedProps.chestClosed, PlannedProps.chestOpen, PlannedProps.foodBasketEmpty, PlannedProps.foodBasketFull,
            Environment.tree1, Environment.tree2, Environment.tree3, Environment.bush1, Environment.bush2,
            Environment.rock1, Environment.rock2, Environment.flowerPatch1, Environment.treeStump,
            Environment.woodSign, Environment.log, Environment.mushrooms,
            Grounds.forest, Grounds.village, Grounds.crystalCave, Grounds.nightForest, Grounds.foxArea,
            DinoFarmProps.foodBowlEmpty, DinoFarmProps.foodBowlFull, DinoFarmProps.waterBowlEmpty, DinoFarmProps.waterBowlFull,
            DinoFarmProps.cleaningBrush, DinoFarmProps.mudSplash, DinoFarmProps.soapBubbles
        ]
        // Character emotional/activity states (Babis/Kotsifi/Fox) are
        // intentionally excluded — each has its own resolver
        // (`BabisAssetResolver`/`KotsifiAssetResolver`/`FoxAssetResolver`)
        // with a per-state `hasSpecificAsset(for:)` diagnostic instead.
        return planned.filter { !exists($0) }
    }
}
