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

/// Central crash-safe audio service for short sound effects and looping game music.
final class AudioManager {
    static let shared = AudioManager()

    private var effectPlayer: AVAudioPlayer?
    private var musicPlayer: AVAudioPlayer?
    private var isMuted = false
    private var musicVolume: Float = 0.28

    private init() {}

    func setMuted(_ muted: Bool) {
        isMuted = muted
        musicPlayer?.volume = muted ? 0 : musicVolume
    }

    func setMusicVolume(_ volume: Float) {
        musicVolume = min(1, max(0, volume))
        if !isMuted {
            musicPlayer?.volume = musicVolume
        }
    }

    /// Plays a sound effect if its audio file exists in the bundle.
    func play(_ effect: SoundEffect) {
        guard !isMuted else { return }
        guard let url = bundledAudioURL(named: effect.rawValue) else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
            effectPlayer = player
        } catch {
            // Playback failure is non-fatal.
        }
    }

    /// Starts a seamless looping music track if it exists in the bundle.
    /// Calling this repeatedly with the same track is cheap and does not restart it.
    func playLoop(named resourceName: String, volume: Float = 0.28) {
        setMusicVolume(volume)

        if let current = musicPlayer,
           current.isPlaying,
           current.url?.deletingPathExtension().lastPathComponent == resourceName {
            return
        }

        guard let url = bundledAudioURL(named: resourceName) else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = isMuted ? 0 : musicVolume
            player.prepareToPlay()
            player.play()
            musicPlayer = player
        } catch {
            // Missing/invalid music never blocks gameplay.
        }
    }

    func stopMusic(fadeDuration: TimeInterval = 0.25) {
        guard let player = musicPlayer else { return }
        guard fadeDuration > 0, player.isPlaying else {
            player.stop()
            musicPlayer = nil
            return
        }

        let steps = 8
        let startVolume = player.volume
        for step in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeDuration * Double(step) / Double(steps)) { [weak self, weak player] in
                guard let self, let player else { return }
                player.volume = startVolume * Float(steps - step) / Float(steps)
                if step == steps {
                    player.stop()
                    if self.musicPlayer === player {
                        self.musicPlayer = nil
                    }
                }
            }
        }
    }

    private func bundledAudioURL(named resourceName: String) -> URL? {
        ["caf", "wav", "mp3", "m4a"].lazy
            .compactMap { Bundle.main.url(forResource: resourceName, withExtension: $0) }
            .first
    }
}
