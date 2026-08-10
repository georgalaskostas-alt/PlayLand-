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
    }

    /// A placeholder glyph shown in development when a named asset is
    /// missing from the catalog, so a gap is obvious instead of blank space.
    private static let missingAssetPlaceholder = "questionmark.square.dashed"

    /// Returns `Image(name)` when the asset exists in the catalog, or a
    /// neutral system placeholder otherwise. Never crashes on a missing name.
    static func image(_ name: String) -> Image {
        #if canImport(UIKit)
        if UIImage(named: name) == nil {
            return Image(systemName: missingAssetPlaceholder)
        }
        #endif
        return Image(name)
    }

    /// All planned-but-not-yet-added asset names, for diagnostics/QA builds.
    static var missingAssetNames: [String] {
        let planned = [
            PlannedGameIcons.wordMatch, PlannedGameIcons.wordSearch, PlannedGameIcons.wordScramble,
            PlannedGameIcons.memoryGame, PlannedGameIcons.dinoDig, PlannedGameIcons.dinoMatch,
            PlannedGameIcons.dinoFarm, PlannedGameIcons.dinoSort,
            PlannedUI.star, PlannedUI.check, PlannedUI.lock, PlannedUI.play,
            PlannedUI.book, PlannedUI.paw, PlannedUI.gamepad, PlannedUI.card, PlannedUI.map, PlannedUI.speaker
        ]
        #if canImport(UIKit)
        return planned.filter { UIImage(named: $0) == nil }
        #else
        return planned
        #endif
    }
}
