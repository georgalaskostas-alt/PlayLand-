import SwiftUI

/// A large, always-visible "hear it again" control. Children who can't yet
/// read fluently need a reliable way to replay spoken instructions, so this
/// button appears anywhere PlayLand speaks — game headers, story scenes,
/// dialogue. Meets the minimum touch target on its own.
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
            AppAssets.image(AppAssets.PlannedUI.speaker)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .frame(width: PlayLandMetrics.minTouchTarget, height: PlayLandMetrics.minTouchTarget)
                .background(PlayLandColors.skyBlue.opacity(speech.isSpeaking ? 0.35 : 0.15))
                .clipShape(Circle())
        }
        .accessibilityLabel(Text("accessibility.replayInstruction"))
    }
}
