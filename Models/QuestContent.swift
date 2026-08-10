import Foundation

struct Quest: Identifiable {
    let id: String
    let titleKey: String
    let descriptionKey: String
    let requiredProgress: Int
    let rewardStars: Int
}

enum QuestLibrary {
    static let quests: [Quest] = [
        Quest(id: "meet_kotsifi", titleKey: "quest.meetKotsifi.title", descriptionKey: "quest.meetKotsifi.desc", requiredProgress: 1, rewardStars: 3),
        Quest(id: "find_cave_entrance", titleKey: "quest.findCave.title", descriptionKey: "quest.findCave.desc", requiredProgress: 1, rewardStars: 3),
        Quest(id: "collect_stones", titleKey: "quest.collectStones.title", descriptionKey: "quest.collectStones.desc", requiredProgress: 3, rewardStars: 5)
    ]

    static func quest(withId id: String) -> Quest? {
        quests.first { $0.id == id }
    }
}
