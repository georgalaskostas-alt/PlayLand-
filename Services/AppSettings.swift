import Foundation
import Combine

/// Global, persisted app preferences: language, narration and sound effects.
///
/// There is exactly one instance (`AppSettings.shared`), created once and
/// used two ways: injected into the view hierarchy via `.environmentObject`
/// so SwiftUI reacts to changes, and referenced directly as `.shared` by
/// non-view code (`Loc`, `SpeechManager`) that needs the current language
/// outside of a view's environment. This mirrors how `AudioManager.shared`
/// is already used elsewhere in the app.
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: StorageKey.language) }
    }

    @Published var isNarrationEnabled: Bool {
        didSet { UserDefaults.standard.set(isNarrationEnabled, forKey: StorageKey.narration) }
    }

    @Published var isSoundEffectsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEffectsEnabled, forKey: StorageKey.soundEffects)
            AudioManager.shared.setMuted(!isSoundEffectsEnabled)
        }
    }

    private enum StorageKey {
        static let language = "appLanguage"
        static let narration = "narrationEnabled"
        static let soundEffects = "soundEffectsEnabled"
    }

    private init() {
        let defaults = UserDefaults.standard
        if let saved = defaults.string(forKey: StorageKey.language), let saved = AppLanguage(rawValue: saved) {
            language = saved
        } else {
            language = .system
        }
        // Narration defaults ON per the product requirement that spoken
        // instructions must be available to non-readers out of the box.
        isNarrationEnabled = defaults.object(forKey: StorageKey.narration) as? Bool ?? true
        isSoundEffectsEnabled = defaults.object(forKey: StorageKey.soundEffects) as? Bool ?? true
        AudioManager.shared.setMuted(!isSoundEffectsEnabled)
    }

    /// `language` with `.system` resolved to a concrete supported language.
    var resolvedLanguage: AppLanguage {
        language == .system ? AppLanguage.resolvedFromSystem() : language
    }

    /// The `Locale` SwiftUI's `.environment(\.locale, ...)` should use so
    /// every `Text` in the app follows the in-app selection immediately,
    /// without relying on the device's system language.
    var locale: Locale {
        Locale(identifier: resolvedLanguage.localeIdentifier ?? "en")
    }
}
