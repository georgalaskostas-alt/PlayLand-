import SwiftUI

/// A large, always-visible "hear it again" control. Children who can't yet
/// read fluently need a reliable way to replay spoken instructions, so this
/// button appears anywhere PlayLand speaks — game headers, story scenes,
/// dialogue. Meets the minimum touch target on its own.
///
/// Uses an SF Symbol intentionally instead of a planned asset name. The old
/// implementation fell back to AppAssets' missing-asset question-mark glyph
/// when `ui_speaker` was not installed, which made the story control look like
/// a help button. A system speaker icon is always available and communicates
/// the action correctly in every build.
struct SpeakerButton: View {
    let text: String
    var language: AppLanguage?

    @ObservedObject private var speech = SpeechManager.shared

    var body: some View {
        Button(action: {
            if speech.isSpeaking {
                speech.stop()
            } else {
                speech.speak(text: text, language: language ?? AppSettings.shared.resolvedLanguage)
            }
        }) {
            Image(systemName: speech.isSpeaking ? "stop.fill" : "speaker.wave.2.fill")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(PlayLandColors.skyBlue)
                .frame(width: PlayLandMetrics.minTouchTarget, height: PlayLandMetrics.minTouchTarget)
                .background(PlayLandColors.skyBlue.opacity(speech.isSpeaking ? 0.28 : 0.13))
                .clipShape(Circle())
        }
        .accessibilityLabel(Text("accessibility.replayInstruction"))
    }
}
