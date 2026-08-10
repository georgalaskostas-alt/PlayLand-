import Foundation

/// Every language PlayLand can present its UI, stories and narration in.
/// `.system` follows the device's preferred language and resolves to
/// `.english` if that language isn't one PlayLand supports.
enum AppLanguage: String, CaseIterable, Identifiable, Hashable {
    case system
    case greek
    case english
    case spanish
    case french
    case german
    case italian
    case portuguese

    var id: String { rawValue }

    /// The BCP-47-ish locale identifier used to select an `.lproj` table
    /// and to build a `Locale`. `.system` has no identifier of its own —
    /// callers should use `AppSettings.resolvedLanguage` instead.
    var localeIdentifier: String? {
        switch self {
        case .system: return nil
        case .greek: return "el"
        case .english: return "en"
        case .spanish: return "es"
        case .french: return "fr"
        case .german: return "de"
        case .italian: return "it"
        case .portuguese: return "pt"
        }
    }

    /// A best-effort BCP-47 region tag for `AVSpeechSynthesisVoice(language:)`.
    /// `SpeechManager` treats this as a preference, not a guarantee — it
    /// gracefully degrades to a language-only match or the system default
    /// voice if no voice for this exact tag is installed.
    var speechLanguageCode: String? {
        switch self {
        case .system: return nil
        case .greek: return "el-GR"
        case .english: return "en-US"
        case .spanish: return "es-ES"
        case .french: return "fr-FR"
        case .german: return "de-DE"
        case .italian: return "it-IT"
        case .portuguese: return "pt-PT"
        }
    }

    /// The name of the language written in that language, never a flag —
    /// per the product requirement that language identity isn't communicated
    /// through flags alone (a flag also doesn't uniquely identify a language).
    var displayName: String {
        switch self {
        case .system: return Loc.t("settings.language.system")
        case .greek: return "Ελληνικά"
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .italian: return "Italiano"
        case .portuguese: return "Português"
        }
    }

    /// Resolves `.system` to the best supported match for the device's
    /// preferred languages, falling back to `.english` if none match.
    static func resolvedFromSystem() -> AppLanguage {
        let supported = AppLanguage.allCases.filter { $0 != .system }
        for preferred in Locale.preferredLanguages {
            let code = Locale(identifier: preferred).language.languageCode?.identifier ?? preferred
            if let match = supported.first(where: { $0.localeIdentifier == code }) {
                return match
            }
        }
        return .english
    }
}

/// Resolves and looks up localized strings against the `.lproj` bundle for
/// the app's currently-selected `AppLanguage`, independent of the device's
/// system language.
///
/// PlayLand standardizes on `Loc.t(key)` everywhere — in `Text(...)`, in
/// spoken narration passed to `SpeechManager`, and in accessibility labels
/// — rather than mixing it with SwiftUI's own `Text("key")` catalog lookup.
/// One resolution path means language switching, dynamic/interpolated
/// strings, and non-view contexts (speech) all behave identically, and a
/// view only needs to hold `@EnvironmentObject var appSettings: AppSettings`
/// to re-render correctly when the language changes.
enum Loc {
    private static var bundleCache: [String: Bundle] = [:]

    static func bundle(for language: AppLanguage) -> Bundle {
        let resolved = language == .system ? AppSettings.shared.resolvedLanguage : language
        guard let code = resolved.localeIdentifier else { return .main }
        if let cached = bundleCache[code] { return cached }
        guard let path = Bundle.main.path(forResource: code, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        bundleCache[code] = bundle
        return bundle
    }

    /// The bundle for the app's currently-selected language.
    static var currentBundle: Bundle {
        bundle(for: AppSettings.shared.language)
    }

    static func t(_ key: String) -> String {
        NSLocalizedString(key, bundle: currentBundle, comment: "")
    }

    static func t(_ key: String, _ args: CVarArg...) -> String {
        String(format: NSLocalizedString(key, bundle: currentBundle, comment: ""), arguments: args)
    }

    /// Array-taking variant for call sites that already have their
    /// arguments collected (e.g. forwarding from another variadic call).
    static func t(_ key: String, args: [CVarArg]) -> String {
        String(format: NSLocalizedString(key, bundle: currentBundle, comment: ""), arguments: args)
    }
}
