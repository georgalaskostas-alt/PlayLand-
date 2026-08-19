import Foundation

/// Which existing mini-game implementation a challenge launches. The RPG
/// never reimplements a game — it reuses these exactly as they appear in
/// the Games/Dino World tabs, just in a "challenge" context that
/// intercepts the completion moment.
enum RPGMiniGameType {
    case memory
    case wordMatching
    case wordScramble
    case letterRecognition
    case dinoSort
}

enum ChallengeDifficulty {
    case easy
    case medium
    case hard
}

/// A single educational-challenge gate used by the legacy challenge launcher.
/// Named RPGEducationalChallenge to avoid colliding with the campaign's
/// lightweight RPGChallenge enum (memory/numbers/shapes/words).
struct RPGEducationalChallenge: Identifiable {
    let id: String
    let gameType: RPGMiniGameType
    let difficulty: ChallengeDifficulty
    let rewardItemId: String?
    let rewardItemCount: Int
    let rewardStars: Int
    let questIdToProgress: String?

    init(
        id: String,
        gameType: RPGMiniGameType,
        difficulty: ChallengeDifficulty = .easy,
        rewardItemId: String? = nil,
        rewardItemCount: Int = 1,
        rewardStars: Int = 3,
        questIdToProgress: String? = nil
    ) {
        self.id = id
        self.gameType = gameType
        self.difficulty = difficulty
        self.rewardItemId = rewardItemId
        self.rewardItemCount = rewardItemCount
        self.rewardStars = rewardStars
        self.questIdToProgress = questIdToProgress
    }
}

/// The outcome of a launched challenge, reported back to whatever
/// presented it (a chest, a bridge, ...).
enum ChallengeOutcome {
    case success(stars: Int)
    case cancelled
}
