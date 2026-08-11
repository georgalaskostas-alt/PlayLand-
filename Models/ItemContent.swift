import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// What kind of thing an item is, for generic handling: food/water feed
/// Babis' needs meters, quest items gate story progress, collectibles are
/// just for delight. New items never need new *logic* — only a new
/// `ItemDefinition` entry in `ItemLibrary`.
enum ItemCategory {
    case food
    case water
    case quest
    case collectible
}

struct ItemDefinition: Identifiable {
    let id: String
    let category: ItemCategory
    let nameKey: String
    /// Emoji shown until a real `assetName` exists in the catalog.
    let emoji: String
    /// Planned Assets.xcassets name. `AppAssets.image(_:)` falls back to
    /// the emoji-carrying placeholder glyph gracefully if it's missing.
    let assetName: String?

    /// The item's real artwork if it exists in the catalog, otherwise its
    /// emoji — never the generic dashed missing-asset glyph, since an
    /// emoji is a perfectly good, always-available stand-in for an item
    /// icon specifically (unlike a character's expression, which a
    /// mismatched emoji can't convey).
    @ViewBuilder
    var icon: some View {
        if let assetName, Self.assetExists(assetName) {
            AppAssets.image(assetName)
                .resizable()
                .scaledToFit()
        } else {
            Text(emoji)
        }
    }

    private static func assetExists(_ name: String) -> Bool {
        #if canImport(UIKit)
        return UIImage(named: name) != nil
        #else
        return false
        #endif
    }
}

/// Every collectible item in the game, independent of which campaign or
/// location hands it out. `ProgressViewModel.inventory` already stores
/// counts generically by item id — this catalog is only ever consulted for
/// *display* (name, icon, category), so adding a new item never requires
/// new inventory-handling code.
enum ItemLibrary {
    static let items: [ItemDefinition] = [
        ItemDefinition(id: "berries", category: .food, nameKey: "item.berries", emoji: "🫐", assetName: "berries_item"),
        ItemDefinition(id: "apple", category: .food, nameKey: "item.apple", emoji: "🍎", assetName: "apple_item"),
        ItemDefinition(id: "carrot", category: .food, nameKey: "item.carrot", emoji: "🥕", assetName: "carrot_item"),
        ItemDefinition(id: "water", category: .water, nameKey: "item.water", emoji: "💧", assetName: "water_item"),
        ItemDefinition(id: "crystal", category: .quest, nameKey: "item.crystal", emoji: "💎", assetName: "crystal_item"),
        ItemDefinition(id: "golden_feather", category: .quest, nameKey: "item.goldenFeather", emoji: "🪶", assetName: "golden_feather"),
        ItemDefinition(id: "key", category: .quest, nameKey: "item.key", emoji: "🔑", assetName: "key_item"),
        ItemDefinition(id: "map_fragment", category: .quest, nameKey: "item.mapFragment", emoji: "🗺️", assetName: "map_fragment"),
        ItemDefinition(id: "leaf", category: .collectible, nameKey: "item.leaf", emoji: "🍃", assetName: nil),
        ItemDefinition(id: "star_token", category: .collectible, nameKey: "item.starToken", emoji: "⭐", assetName: nil)
    ]

    static func item(withId id: String) -> ItemDefinition? {
        items.first { $0.id == id }
    }
}
