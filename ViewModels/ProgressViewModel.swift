import Foundation

/// The single source of truth for a player's progress. Owned once at the
/// app root (`PlayLandApp`) and shared everywhere via `.environmentObject`.
/// Screens must never create their own instance.
final class ProgressViewModel: ObservableObject {
    @Published private(set) var completedGames: Set<String> = []
    @Published private(set) var completedStories: Set<String> = []
    @Published private(set) var completedChapters: Set<String> = []
    @Published private(set) var unlockedBadges: Set<String> = []
    /// The best star result ever recorded for a given game id.
    @Published private(set) var gameBestStars: [String: Int] = [:]
    @Published private(set) var totalStars: Int = 0

    private let storyStarReward = 5

    init() {
        loadProgress()
    }

    /// Records a game completion. Total stars only increase by the amount a
    /// new result improves on the player's previous best for that game, so
    /// replaying a game can never be used to farm stars indefinitely.
    ///
    /// Example: first clear scores 2 stars (+2 total). A replay scoring 3
    /// stars adds only +1 (the improvement). A replay scoring 2 stars again
    /// adds +0, since it doesn't beat the recorded best of 3.
    func completeGame(_ gameId: String, stars: Int) {
        let clampedStars = max(0, stars)
        let previousBest = gameBestStars[gameId] ?? 0

        if clampedStars > previousBest {
            totalStars += (clampedStars - previousBest)
            gameBestStars[gameId] = clampedStars
        }

        completedGames.insert(gameId)
        saveProgress()
    }

    func isGameCompleted(_ gameId: String) -> Bool {
        completedGames.contains(gameId)
    }

    /// The best star result recorded for a game, or 0 if never played.
    func bestStars(forGame gameId: String) -> Int {
        gameBestStars[gameId] ?? 0
    }

    func completeStory(_ storyId: String) {
        guard !completedStories.contains(storyId) else { return }
        completedStories.insert(storyId)
        totalStars += storyStarReward
        saveProgress()
    }

    func isStoryCompleted(_ storyId: String) -> Bool {
        completedStories.contains(storyId)
    }

    func completeChapter(_ chapterId: String) {
        guard !completedChapters.contains(chapterId) else { return }
        completedChapters.insert(chapterId)
        totalStars += storyStarReward
        saveProgress()
    }

    func isChapterCompleted(_ chapterId: String) -> Bool {
        completedChapters.contains(chapterId)
    }

    func unlockBadge(_ badgeId: String) {
        guard !unlockedBadges.contains(badgeId) else { return }
        unlockedBadges.insert(badgeId)
        saveProgress()
    }

    func hasBadge(_ badgeId: String) -> Bool {
        unlockedBadges.contains(badgeId)
    }

    func resetProgress() {
        completedGames = []
        completedStories = []
        completedChapters = []
        unlockedBadges = []
        gameBestStars = [:]
        totalStars = 0
        saveProgress()
    }

    private enum StorageKey {
        static let completedGames = "completedGames"
        static let completedStories = "completedStories"
        static let completedChapters = "completedChapters"
        static let unlockedBadges = "unlockedBadges"
        static let gameBestStars = "gameBestStars"
        static let totalStars = "totalStars"
    }

    private func saveProgress() {
        let defaults = UserDefaults.standard
        defaults.set(Array(completedGames), forKey: StorageKey.completedGames)
        defaults.set(Array(completedStories), forKey: StorageKey.completedStories)
        defaults.set(Array(completedChapters), forKey: StorageKey.completedChapters)
        defaults.set(Array(unlockedBadges), forKey: StorageKey.unlockedBadges)
        defaults.set(gameBestStars, forKey: StorageKey.gameBestStars)
        defaults.set(totalStars, forKey: StorageKey.totalStars)
    }

    private func loadProgress() {
        let defaults = UserDefaults.standard
        completedGames = Set(defaults.array(forKey: StorageKey.completedGames) as? [String] ?? [])
        completedStories = Set(defaults.array(forKey: StorageKey.completedStories) as? [String] ?? [])
        completedChapters = Set(defaults.array(forKey: StorageKey.completedChapters) as? [String] ?? [])
        unlockedBadges = Set(defaults.array(forKey: StorageKey.unlockedBadges) as? [String] ?? [])
        gameBestStars = defaults.dictionary(forKey: StorageKey.gameBestStars) as? [String: Int] ?? [:]
        totalStars = defaults.integer(forKey: StorageKey.totalStars)
    }
}
