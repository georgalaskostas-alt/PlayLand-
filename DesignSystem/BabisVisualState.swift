import SwiftUI

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
    ///
    /// `.sad`, `.tired` and `.sleeping` are not reachable from any active
    /// gameplay path today (verified: nothing outside this file switches
    /// on them). They're kept as forward-compatible cases, but since no
    /// screen ever requests them, they never need their own art — the
    /// standard fallback chain below already resolves them to `.neutral`.
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

    /// The 4-frame run cycle, in order. Only `.running`'s primary asset
    /// (`babis_run_01`) is reachable via `plannedAssetName`/the state
    /// machine; frames 2-4 exist solely for frame-cycling animation while
    /// Babis is moving (see `LocationExploreView`).
    static let runFrames = ["babis_run_01", "babis_run_02", "babis_run_03", "babis_run_04"]
}

/// Resolves a `BabisVisualState` to the best available artwork, using the
/// fallback hierarchy: the state's own specific asset, then a generic
/// "neutral" asset, then the one character asset guaranteed to exist
/// (`babis_dinosaur`). This can never crash and never silently claims art
/// exists that hasn't been added — it only ever renders a name it has
/// actually verified is present in the catalog. Built on
/// `CharacterAssetResolver`, the same primitive `KotsifiAssetResolver` and
/// `FoxAssetResolver` use, so there's one fallback algorithm, not three.
enum BabisAssetResolver {
    /// True only if `state`'s own specific asset exists — i.e. a caller
    /// can trust the art to convey this exact mood, rather than a
    /// same-neutral-image-for-everything fallback needing help (like
    /// desaturation) to read as distinct.
    static func hasSpecificAsset(for state: BabisVisualState) -> Bool {
        AppAssets.exists(state.plannedAssetName)
    }

    /// The concrete asset name that will actually be used for `state`,
    /// following the fallback chain (state's own → neutral → guaranteed
    /// default). Always resolves to something real and present.
    static func resolvedAssetName(for state: BabisVisualState) -> String {
        CharacterAssetResolver.resolvedAssetName(
            assetName: state.plannedAssetName,
            neutralAssetName: BabisVisualState.neutral.plannedAssetName,
            guaranteedDefault: AppAssets.Characters.babis
        )
    }

    static func image(for state: BabisVisualState) -> Image {
        AppAssets.image(resolvedAssetName(for: state))
    }
}
