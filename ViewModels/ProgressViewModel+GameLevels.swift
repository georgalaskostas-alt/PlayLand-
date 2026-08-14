import Foundation
import Combine

extension ProgressViewModel {
    private func levelStorageKey(for gameId: String) -> String { "gameLevel.\(gameId)" }

    /// Highest unlocked level, 1-based. A game always starts with level 1 unlocked.
    func unlockedLevel(for gameId: String, totalLevels: Int) -> Int {
        let stored = UserDefaults.standard.integer(forKey: levelStorageKey(for: gameId))
        return min(max(stored == 0 ? 1 : stored, 1), max(totalLevels, 1))
    }

    /// Unlocks a level without ever moving progress backwards.
    func unlockLevel(_ level: Int, for gameId: String, totalLevels: Int) {
        let current = unlockedLevel(for: gameId, totalLevels: totalLevels)
        let next = min(max(level, current), max(totalLevels, 1))
        UserDefaults.standard.set(next, forKey: levelStorageKey(for: gameId))
        objectWillChange.send()
    }

    func resetUnlockedLevels(for gameIds: [String]) {
        for id in gameIds { UserDefaults.standard.removeObject(forKey: levelStorageKey(for: id)) }
        objectWillChange.send()
    }
}
