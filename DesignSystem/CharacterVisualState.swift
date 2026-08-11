import SwiftUI

/// The one fallback-resolution algorithm every character (Babis, Kotsifi,
/// Alepou) uses: a state's own specific asset, then that character's
/// neutral/idle asset, then the one asset guaranteed to exist for that
/// character. `BabisAssetResolver`, `KotsifiAssetResolver` and
/// `FoxAssetResolver` are thin wrappers over this — one resolution system,
/// not three copies of it.
enum CharacterAssetResolver {
    static func resolvedAssetName(assetName: String, neutralAssetName: String, guaranteedDefault: String) -> String {
        if AppAssets.exists(assetName) { return assetName }
        if assetName != neutralAssetName, AppAssets.exists(neutralAssetName) { return neutralAssetName }
        return guaranteedDefault
    }

    static func image(assetName: String, neutralAssetName: String, guaranteedDefault: String) -> Image {
        AppAssets.image(resolvedAssetName(assetName: assetName, neutralAssetName: neutralAssetName, guaranteedDefault: guaranteedDefault))
    }
}

/// Kotsifi's emotional/activity states. Small on purpose — this is not a
/// parallel system to `BabisVisualState`, just the same pattern applied to
/// a second character where the existing dialogue architecture already has
/// a natural hook for it (`DialogueNode.portraitAsset`).
enum KotsifiVisualState: CaseIterable {
    case idle
    case happy
    case surprised
    case talking
    case flying

    var plannedAssetName: String {
        switch self {
        case .idle: return AppAssets.KotsifiStates.idle
        case .happy: return AppAssets.KotsifiStates.happy
        case .surprised: return AppAssets.KotsifiStates.surprised
        case .talking: return AppAssets.KotsifiStates.talking
        case .flying: return AppAssets.KotsifiStates.fly1
        }
    }
}

enum KotsifiAssetResolver {
    static func hasSpecificAsset(for state: KotsifiVisualState) -> Bool {
        AppAssets.exists(state.plannedAssetName)
    }

    /// A resolved, always-safe asset name — for the places (like
    /// `DialogueNode.portraitAsset`) that store a plain string rather than
    /// resolving through an `Image` each render.
    static func portraitAsset(for state: KotsifiVisualState) -> String {
        CharacterAssetResolver.resolvedAssetName(
            assetName: state.plannedAssetName,
            neutralAssetName: KotsifiVisualState.idle.plannedAssetName,
            guaranteedDefault: AppAssets.Characters.kotsifi
        )
    }

    static func image(for state: KotsifiVisualState) -> Image {
        AppAssets.image(portraitAsset(for: state))
    }
}

/// Alepou (the fox)'s emotional states. Same small pattern as Kotsifi.
enum FoxVisualState: CaseIterable {
    case neutral
    case smirk
    case surprised
    case worried
    case friendly
    case talking

    var plannedAssetName: String {
        switch self {
        case .neutral: return AppAssets.FoxStates.neutral
        case .smirk: return AppAssets.FoxStates.smirk
        case .surprised: return AppAssets.FoxStates.surprised
        case .worried: return AppAssets.FoxStates.worried
        case .friendly: return AppAssets.FoxStates.friendly
        case .talking: return AppAssets.FoxStates.talking
        }
    }
}

enum FoxAssetResolver {
    static func hasSpecificAsset(for state: FoxVisualState) -> Bool {
        AppAssets.exists(state.plannedAssetName)
    }

    static func portraitAsset(for state: FoxVisualState) -> String {
        CharacterAssetResolver.resolvedAssetName(
            assetName: state.plannedAssetName,
            neutralAssetName: FoxVisualState.neutral.plannedAssetName,
            guaranteedDefault: AppAssets.Characters.fox
        )
    }

    static func image(for state: FoxVisualState) -> Image {
        AppAssets.image(portraitAsset(for: state))
    }
}
