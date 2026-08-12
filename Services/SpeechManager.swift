import AVFoundation
import Combine

/// Central spoken-narration service built on `AVSpeechSynthesizer` — no
/// cloud APIs, no network requirement. Every screen that needs to speak an
/// instruction, a story line, or praise should go through this shared
/// instance rather than creating its own synthesizer, so instructions never
/// talk over each other.
///
/// This is app-provided narration, entirely separate from VoiceOver: it
/// never touches accessibility settings or the system's own speech
/// synthesis, and it's silenced by `AppSettings.isNarrationEnabled` (the
/// in-app narration toggle), never by anything accessibility-related.
final class SpeechManager: NSObject, ObservableObject {
    static let shared = SpeechManager()

    /// Whether the synthesizer is actively speaking right now. Views can
    /// observe this to, for example, animate a speaker icon.
    @Published private(set) var isSpeaking = false

    private let synthesizer = AVSpeechSynthesizer()

    /// Slightly slower than the system default, and a touch brighter in
    /// pitch — easier for a 6-8 year old to follow than a standard adult
    /// reading pace. Both are per-language hooks (see `rateMultiplier(for:)`
    /// / `pitch(for:)`) that currently return the same value for every
    /// language; each voice's own `AVSpeechUtteranceDefaultSpeechRate`
    /// already reflects that language's natural tempo, so scaling it by a
    /// flat percentage — rather than picking one absolute rate for every
    /// locale — already avoids the "one rate for every language" pitfall.
    /// Tune a specific language here if real listening shows it needs one.
    private let baseRateMultiplier: Float = 0.92
    private let basePitch: Float = 1.05

    /// Guards against a SwiftUI `.onAppear` re-firing (e.g. a parent
    /// re-render recreating a view without its content actually changing)
    /// and re-triggering the exact same narration a moment later. A manual
    /// replay tap is never affected: `SpeakerButton` only calls `speak(_:)`
    /// while nothing is currently playing, so `isSpeaking` is always false
    /// at that point and this check never applies to it.
    private var lastSpokenText: String?
    private var lastSpokenAt: Date?
    private let duplicateSuppressionWindow: TimeInterval = 0.4

    /// Flip on locally (never in a shipped build — see `speak(text:language:)`)
    /// to print the resolved voice and the original/spoken text pair for
    /// every utterance, while tuning pronunciation or voice selection.
    #if DEBUG
    static var verboseLoggingEnabled = false
    #endif

    private override init() {
        super.init()
        synthesizer.delegate = self
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        #endif
    }

    /// Speaks `text` in the app's currently-selected language, cancelling
    /// whatever is currently being spoken first.
    func speak(text: String) {
        speak(text: text, language: AppSettings.shared.resolvedLanguage)
    }

    /// Speaks `text` using the best available voice for `language`. `text`
    /// should always be the already-localized, on-screen string — any
    /// pronunciation adjustment happens internally and never changes what
    /// the child sees.
    func speak(text: String, language: AppLanguage) {
        guard AppSettings.shared.isNarrationEnabled else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if isSpeaking, trimmed == lastSpokenText, let lastSpokenAt,
           Date().timeIntervalSince(lastSpokenAt) < duplicateSuppressionWindow {
            return
        }

        // A new important instruction replaces whatever is currently playing
        // rather than queueing behind it, so narration never overlaps.
        stop()

        let voice = bestVoice(for: language)
        let spokenText = SpeechPronunciationResolver.spokenText(for: trimmed, language: language)

        let utterance = AVSpeechUtterance(string: spokenText)
        utterance.voice = voice
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * rateMultiplier(for: language)
        utterance.pitchMultiplier = pitch(for: language)
        // Volume is left at its default (1.0, scaled by the device/system
        // volume as usual) — the app has no reason to override the user's
        // own volume preference.

        #if DEBUG
        if Self.verboseLoggingEnabled {
            print("[SpeechManager] language=\(language.rawValue) voice=\(voice?.identifier ?? "system default") (\(voice?.name ?? "-"), quality=\(voice.map(qualityDescription) ?? "-"))")
            print("[SpeechManager] original=\"\(trimmed)\"")
            if spokenText != trimmed {
                print("[SpeechManager] spoken=\"\(spokenText)\"")
            }
        }
        #endif

        lastSpokenText = trimmed
        lastSpokenAt = Date()
        synthesizer.speak(utterance)
    }

    func stop() {
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    func pause() {
        guard synthesizer.isSpeaking else { return }
        synthesizer.pauseSpeaking(at: .word)
    }

    func resume() {
        guard synthesizer.isPaused else { return }
        synthesizer.continueSpeaking()
    }

    /// This language's rate as a fraction of that voice's own default rate.
    /// Scaling relatively (rather than setting one absolute rate for every
    /// language) means each language keeps its own natural tempo, just
    /// slowed the same relative amount for a child audience.
    private func rateMultiplier(for language: AppLanguage) -> Float {
        baseRateMultiplier
    }

    private func pitch(for language: AppLanguage) -> Float {
        basePitch
    }

    /// Finds the best installed voice for `language`, degrading gracefully
    /// through four tiers, and never assumes a specific named voice exists:
    /// 1. Among installed voices matching the exact region tag (e.g.
    ///    "el-GR"), the highest-quality one (premium > enhanced > default).
    /// 2. Among installed voices for the same base language (any "el-*"),
    ///    same quality preference — covers a region tag that isn't
    ///    installed but a same-language voice is.
    /// 3. `AVSpeechSynthesisVoice(language:)`'s own single best guess, in
    ///    case the two scans above somehow found nothing.
    /// 4. `nil`, which leaves `AVSpeechUtterance.voice` unset — the
    ///    synthesizer then uses its own system default rather than the
    ///    utterance silently failing.
    /// Never triggers a voice download; only chooses among voices already
    /// on the device.
    private func bestVoice(for language: AppLanguage) -> AVSpeechSynthesisVoice? {
        let installed = AVSpeechSynthesisVoice.speechVoices()

        if let code = language.speechLanguageCode {
            let exact = installed.filter { $0.language.caseInsensitiveCompare(code) == .orderedSame }
            if let best = highestQuality(among: exact) { return best }
        }

        if let prefix = language.localeIdentifier {
            let sameLanguage = installed.filter { $0.language.lowercased().hasPrefix(prefix.lowercased()) }
            if let best = highestQuality(among: sameLanguage) { return best }
        }

        if let code = language.speechLanguageCode, let fallback = AVSpeechSynthesisVoice(language: code) {
            return fallback
        }

        return nil
    }

    private func highestQuality(among voices: [AVSpeechSynthesisVoice]) -> AVSpeechSynthesisVoice? {
        voices.max { qualityRank($0.quality) < qualityRank($1.quality) }
    }

    private func qualityRank(_ quality: AVSpeechSynthesisVoiceQuality) -> Int {
        switch quality {
        case .premium: return 3
        case .enhanced: return 2
        case .default: return 1
        @unknown default: return 0
        }
    }
}

#if DEBUG
private func qualityDescription(_ voice: AVSpeechSynthesisVoice) -> String {
    switch voice.quality {
    case .premium: return "premium"
    case .enhanced: return "enhanced"
    case .default: return "default"
    @unknown default: return "unknown"
    }
}
#endif

extension SpeechManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = true }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = false }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = false }
    }
}
