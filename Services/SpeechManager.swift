import AVFoundation
import Combine

/// Central spoken-narration service built on `AVSpeechSynthesizer` — no
/// cloud APIs, no network requirement. Every screen that needs to speak an
/// instruction, a story line, or praise should go through this shared
/// instance rather than creating its own synthesizer, so instructions never
/// talk over each other.
final class SpeechManager: NSObject, ObservableObject {
    static let shared = SpeechManager()

    /// Whether the synthesizer is actively speaking right now. Views can
    /// observe this to, for example, animate a speaker icon.
    @Published private(set) var isSpeaking = false

    private let synthesizer = AVSpeechSynthesizer()

    /// Slightly slower than the system default, and a touch brighter in
    /// pitch — easier for a 6-8 year old to follow than a standard adult
    /// reading pace.
    private let childFriendlyRate = AVSpeechUtteranceDefaultSpeechRate * 0.92
    private let childFriendlyPitch: Float = 1.05

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

    /// Speaks `text` using the voice that best matches `language`.
    func speak(text: String, language: AppLanguage) {
        guard AppSettings.shared.isNarrationEnabled else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // A new important instruction replaces whatever is currently playing
        // rather than queueing behind it, so narration never overlaps.
        stop()

        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.voice = bestVoice(for: language)
        utterance.rate = childFriendlyRate
        utterance.pitchMultiplier = childFriendlyPitch
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

    /// Finds the best installed voice for `language`, degrading gracefully:
    /// exact region match (e.g. "el-GR") -> any installed voice whose
    /// language starts with the same base code -> the synthesizer's own
    /// default voice (by leaving `utterance.voice` nil). Never assumes a
    /// specific named voice exists, and never crashes if one doesn't.
    private func bestVoice(for language: AppLanguage) -> AVSpeechSynthesisVoice? {
        if let code = language.speechLanguageCode, let exact = AVSpeechSynthesisVoice(language: code) {
            return exact
        }
        if let prefix = language.localeIdentifier {
            let installed = AVSpeechSynthesisVoice.speechVoices()
            if let match = installed.first(where: { $0.language.lowercased().hasPrefix(prefix.lowercased()) }) {
                return match
            }
        }
        return nil
    }
}

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
