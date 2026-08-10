import AVFoundation

/// Sound effects PlayLand plays for common interactions. Add matching audio
/// files to the app bundle (e.g. `button_tap.mp3`) to enable playback —
/// until then, `AudioManager` silently no-ops so nothing crashes or requires
/// bundled audio to build.
enum SoundEffect: String {
    case buttonTap = "button_tap"
    case correct = "correct"
    case wrong = "wrong"
    case starReward = "star_reward"
    case storyNext = "story_next"
    case gameCompletion = "game_completion"
}

/// A minimal, crash-safe sound effect player. This is foundation only:
/// individual screens are not yet wired to call every case, but any screen
/// can safely call `AudioManager.shared.play(_:)` at any time.
final class AudioManager {
    static let shared = AudioManager()

    private var player: AVAudioPlayer?
    private var isMuted = false

    private init() {}

    func setMuted(_ muted: Bool) {
        isMuted = muted
    }

    /// Plays a sound effect if its audio file exists in the bundle.
    /// Does nothing (no crash, no warning) if the file hasn't been added yet.
    func play(_ effect: SoundEffect) {
        guard !isMuted else { return }

        let candidateExtensions = ["caf", "wav", "mp3", "m4a"]
        guard let url = candidateExtensions.lazy
            .compactMap({ Bundle.main.url(forResource: effect.rawValue, withExtension: $0) })
            .first else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
            self.player = player
        } catch {
            // Playback failure is non-fatal; the app continues silently.
        }
    }
}
