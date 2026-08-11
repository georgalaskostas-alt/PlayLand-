import SwiftUI

/// Launches an existing mini-game implementation "as a challenge" —
/// nothing about Memory/WordMatching/WordScramble/LetterRecognition/
/// DinoSort is reimplemented here. The only difference from playing them
/// normally from the Games tab is that success is reported back to
/// `onOutcome` instead of just dismissing, so the calling context (a
/// chest, a bridge, a cave symbol) can apply its own reward.
///
/// Closing without finishing reports `.cancelled` — the object that
/// launched this stays exactly as it was (a chest stays closed), so the
/// child can simply try again later. There's no penalty for walking away.
struct ChallengeLauncherView: View {
    let challenge: RPGChallenge
    let onOutcome: (ChallengeOutcome) -> Void

    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        NavigationStack {
            challengeGame
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(Loc.t("action.close")) { onOutcome(.cancelled) }
                    }
                }
        }
    }

    @ViewBuilder
    private var challengeGame: some View {
        switch challenge.gameType {
        case .memory:
            MemoryGame(onChallengeComplete: { stars in onOutcome(.success(stars: stars)) })
        case .wordMatching:
            WordMatchingGame(onChallengeComplete: { stars in onOutcome(.success(stars: stars)) })
        case .wordScramble:
            WordScrambleGame(onChallengeComplete: { stars in onOutcome(.success(stars: stars)) })
        case .letterRecognition:
            LetterRecognitionGame(onChallengeComplete: { stars in onOutcome(.success(stars: stars)) })
        case .dinoSort:
            DinoSortGame(onChallengeComplete: { stars in onOutcome(.success(stars: stars)) })
        }
    }
}
