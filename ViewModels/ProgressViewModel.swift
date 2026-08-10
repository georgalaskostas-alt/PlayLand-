import Foundation
import Combine

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

    // MARK: RPG progression
    @Published private(set) var completedQuests: Set<String> = []
    @Published private(set) var questProgress: [String: Int] = [:]
    @Published private(set) var unlockedLocations: Set<String> = []
    @Published private(set) var inventory: [String: Int] = [:]

    private let storyStarReward = 5

    init() {
        loadProgress()
        unlockLocationsIfNeeded()
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
        unlockLocationsIfNeeded()
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

    // MARK: RPG progression

    /// Advances a quest's progress by `amount` (default 1). Once progress
    /// reaches the quest's `requiredProgress`, it's marked complete exactly
    /// once, its star reward is granted, and any location gated on it is
    /// unlocked. Progress never exceeds `requiredProgress`, so re-tapping
    /// the same object repeatedly can't over-complete a quest.
    func progressQuest(_ questId: String, by amount: Int = 1) {
        guard !completedQuests.contains(questId) else { return }
        guard let quest = QuestLibrary.quest(withId: questId) else { return }

        let newProgress = min(quest.requiredProgress, (questProgress[questId] ?? 0) + amount)
        questProgress[questId] = newProgress

        if newProgress >= quest.requiredProgress {
            completedQuests.insert(questId)
            totalStars += quest.rewardStars
            unlockLocationsIfNeeded()
        }
        saveProgress()
    }

    func isQuestCompleted(_ questId: String) -> Bool {
        completedQuests.contains(questId)
    }

    func progress(forQuest questId: String) -> Int {
        questProgress[questId] ?? 0
    }

    func isLocationUnlocked(_ locationId: String) -> Bool {
        unlockedLocations.contains(locationId)
    }

    func collectItem(_ itemId: String, count: Int = 1) {
        inventory[itemId, default: 0] += count
        saveProgress()
    }

    func itemCount(_ itemId: String) -> Int {
        inventory[itemId] ?? 0
    }

    /// Re-evaluates every location's unlock requirement against current
    /// quest/chapter completion and unlocks any that now qualify. Called
    /// after any event that could satisfy a requirement, and once at
    /// startup so always-unlocked locations (the village hub) are present
    /// even on a fresh install.
    private func unlockLocationsIfNeeded() {
        for (locationId, requirement) in WorldLibrary.unlockRequirements {
            switch requirement {
            case .alwaysUnlocked:
                unlockedLocations.insert(locationId)
            case .questCompleted(let id):
                if completedQuests.contains(id) { unlockedLocations.insert(locationId) }
            case .chapterCompleted(let id):
                if completedChapters.contains(id) { unlockedLocations.insert(locationId) }
            }
        }
    }

    func resetProgress() {
        completedGames = []
        completedStories = []
        completedChapters = []
        unlockedBadges = []
        gameBestStars = [:]
        totalStars = 0
        completedQuests = []
        questProgress = [:]
        unlockedLocations = []
        inventory = [:]
        unlockLocationsIfNeeded()
        saveProgress()
    }

    private enum StorageKey {
        static let completedGames = "completedGames"
        static let completedStories = "completedStories"
        static let completedChapters = "completedChapters"
        static let unlockedBadges = "unlockedBadges"
        static let gameBestStars = "gameBestStars"
        static let totalStars = "totalStars"
        static let completedQuests = "completedQuests"
        static let questProgress = "questProgress"
        static let unlockedLocations = "unlockedLocations"
        static let inventory = "inventory"
    }

    private func saveProgress() {
        let defaults = UserDefaults.standard
        defaults.set(Array(completedGames), forKey: StorageKey.completedGames)
        defaults.set(Array(completedStories), forKey: StorageKey.completedStories)
        defaults.set(Array(completedChapters), forKey: StorageKey.completedChapters)
        defaults.set(Array(unlockedBadges), forKey: StorageKey.unlockedBadges)
        defaults.set(gameBestStars, forKey: StorageKey.gameBestStars)
        defaults.set(totalStars, forKey: StorageKey.totalStars)
        defaults.set(Array(completedQuests), forKey: StorageKey.completedQuests)
        defaults.set(questProgress, forKey: StorageKey.questProgress)
        defaults.set(Array(unlockedLocations), forKey: StorageKey.unlockedLocations)
        defaults.set(inventory, forKey: StorageKey.inventory)
    }

    private func loadProgress() {
        let defaults = UserDefaults.standard
        completedGames = Set(defaults.array(forKey: StorageKey.completedGames) as? [String] ?? [])
        completedStories = Set(defaults.array(forKey: StorageKey.completedStories) as? [String] ?? [])
        completedChapters = Set(defaults.array(forKey: StorageKey.completedChapters) as? [String] ?? [])
        unlockedBadges = Set(defaults.array(forKey: StorageKey.unlockedBadges) as? [String] ?? [])
        gameBestStars = defaults.dictionary(forKey: StorageKey.gameBestStars) as? [String: Int] ?? [:]
        totalStars = defaults.integer(forKey: StorageKey.totalStars)
        completedQuests = Set(defaults.array(forKey: StorageKey.completedQuests) as? [String] ?? [])
        questProgress = defaults.dictionary(forKey: StorageKey.questProgress) as? [String: Int] ?? [:]
        unlockedLocations = Set(defaults.array(forKey: StorageKey.unlockedLocations) as? [String] ?? [])
        inventory = defaults.dictionary(forKey: StorageKey.inventory) as? [String: Int] ?? [:]
    }
}
