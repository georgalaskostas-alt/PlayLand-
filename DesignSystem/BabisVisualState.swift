import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Every emotional/activity state Babis can visually be in. New cases are
/// safe to add at any time — `BabisAssetResolver` degrades gracefully for
/// any state that doesn't have art yet.
enum BabisVisualState: CaseIterable {
    case hungry
    case thirsty
    case sad
    case neutral
    case happy
    case excited
    case eating
    case drinking
    case running
    case tired
    case dirty
    case clean
    case sleeping

    /// The planned Assets.xcassets name for this state. Most of these do
    /// not exist yet — see the asset manifest in the project report.
    var plannedAssetName: String {
        switch self {
        case .hungry: return "babis_hungry"
        case .thirsty: return "babis_thirsty"
        case .sad: return "babis_sad"
        case .neutral: return "babis_neutral"
        case .happy: return "babis_happy"
        case .excited: return "babis_excited"
        case .eating: return "babis_eating"
        case .drinking: return "babis_drinking"
        case .running: return "babis_run_01"
        case .tired: return "babis_tired"
        case .dirty: return "babis_dirty"
        case .clean: return "babis_clean"
        case .sleeping: return "babis_sleeping"
        }
    }
}

/// Resolves a `BabisVisualState` to the best available artwork, using the
/// fallback hierarchy: the state's own specific asset, then a generic
/// "neutral" asset, then the one character asset guaranteed to exist
/// (`babis_dinosaur`). This can never crash and never silently claims art
/// exists that hasn't been added — it only ever renders a name it has
/// actually verified is present in the catalog.
enum BabisAssetResolver {
    /// True only if `state`'s own specific asset exists — i.e. a caller
    /// can trust the art to convey this exact mood, rather than a
    /// same-neutral-image-for-everything fallback needing help (like
    /// desaturation) to read as distinct.
    static func hasSpecificAsset(for state: BabisVisualState) -> Bool {
        assetExists(state.plannedAssetName)
    }

    static func image(for state: BabisVisualState) -> Image {
        if let name = resolvedAssetName(for: state) {
            return Image(name)
        }
        return AppAssets.image(AppAssets.Characters.babis)
    }

    /// The concrete asset name that will actually be used for `state`,
    /// following the fallback chain, or `nil` if nothing beyond the
    /// guaranteed default exists.
    private static func resolvedAssetName(for state: BabisVisualState) -> String? {
        if assetExists(state.plannedAssetName) {
            return state.plannedAssetName
        }
        if state != .neutral, assetExists(BabisVisualState.neutral.plannedAssetName) {
            return BabisVisualState.neutral.plannedAssetName
        }
        return nil
    }

    private static func assetExists(_ name: String) -> Bool {
        #if canImport(UIKit)
        return UIImage(named: name) != nil
        #else
        return false
        #endif
    }
}
