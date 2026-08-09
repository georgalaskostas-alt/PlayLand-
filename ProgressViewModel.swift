import Foundation

class ProgressViewModel: ObservableObject {
    @Published var completedGames: Set<String> = []
    @Published var completedStories: Set<String> = []
    @Published var unlockedDinoCharacters: Set<String> = []
    @Published var totalStars: Int = 0
    
    init() {
        loadProgress()
    }
    
    func completeGame(_ gameId: String, stars: Int) {
        if !completedGames.contains(gameId) {
            completedGames.insert(gameId)
        }
        totalStars += stars
        saveProgress()
    }
    
    func isGameCompleted(_ gameId: String) -> Bool {
        return completedGames.contains(gameId)
    }
    
    func completeStory(_ storyId: String) {
        if !completedStories.contains(storyId) {
            completedStories.insert(storyId)
            totalStars += 5
        }
        saveProgress()
    }
    
    func isStoryCompleted(_ storyId: String) -> Bool {
        return completedStories.contains(storyId)
    }
    
    private func saveProgress() {
        UserDefaults.standard.set(Array(completedGames), forKey: "completedGames")
        UserDefaults.standard.set(Array(completedStories), forKey: "completedStories")
        UserDefaults.standard.set(Array(unlockedDinoCharacters), forKey: "unlockedDinoCharacters")
        UserDefaults.standard.set(totalStars, forKey: "totalStars")
    }
    
    private func loadProgress() {
        completedGames = Set(UserDefaults.standard.array(forKey: "completedGames") as? [String] ?? [])
        completedStories = Set(UserDefaults.standard.array(forKey: "completedStories") as? [String] ?? [])
        unlockedDinoCharacters = Set(UserDefaults.standard.array(forKey: "unlockedDinoCharacters") as? [String] ?? [])
        totalStars = UserDefaults.standard.integer(forKey: "totalStars")
    }
    
    func resetProgress() {
        completedGames.removeAll()
        completedStories.removeAll()
        unlockedDinoCharacters.removeAll()
        totalStars = 0
        saveProgress()
    }
}
