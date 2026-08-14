import Foundation

struct LetterQuestion: Identifiable {
    let id = UUID()
    let letter: String
    let options: [String]
    let correct: Int
}

struct MatchWordPair {
    let emoji: String
    let word: String
}

struct ScrambleWord {
    let answer: String
    let emoji: String
}

enum LearningContentProvider {
    static func letterQuestions(for language: AppLanguage) -> [LetterQuestion] {
        language == .greek ? greekLetterQuestions : englishLetterQuestions
    }

    static func matchWordPairs(for language: AppLanguage) -> [MatchWordPair] {
        language == .greek ? greekMatchPairs : englishMatchPairs
    }

    static func searchWords(for language: AppLanguage) -> [String] {
        language == .greek ? greekSearchWords : englishSearchWords
    }

    static func scrambleWords(for language: AppLanguage) -> [ScrambleWord] {
        language == .greek ? greekScrambleWords : englishScrambleWords
    }

    private static let englishLetterQuestions = [
        LetterQuestion(letter: "A", options: ["Apple", "Ball", "Cat"], correct: 0), LetterQuestion(letter: "B", options: ["Dog", "Ball", "Elephant"], correct: 1),
        LetterQuestion(letter: "C", options: ["Apple", "Cat", "Fish"], correct: 1), LetterQuestion(letter: "D", options: ["Dog", "Goat", "Hen"], correct: 0),
        LetterQuestion(letter: "E", options: ["Fish", "Elephant", "Lion"], correct: 1), LetterQuestion(letter: "F", options: ["Ant", "Fish", "Owl"], correct: 1),
        LetterQuestion(letter: "G", options: ["Goat", "Rabbit", "Sun"], correct: 0), LetterQuestion(letter: "H", options: ["Tiger", "Hen", "Apple"], correct: 1),
        LetterQuestion(letter: "I", options: ["Ice", "Moon", "Dog"], correct: 0), LetterQuestion(letter: "J", options: ["Cat", "Juice", "Fish"], correct: 1),
        LetterQuestion(letter: "K", options: ["Kite", "Apple", "Tree"], correct: 0), LetterQuestion(letter: "L", options: ["Ball", "Lion", "Goat"], correct: 1),
        LetterQuestion(letter: "M", options: ["Moon", "Cat", "Fish"], correct: 0), LetterQuestion(letter: "N", options: ["Sun", "Nest", "Dog"], correct: 1),
        LetterQuestion(letter: "O", options: ["Owl", "Tree", "Lion"], correct: 0), LetterQuestion(letter: "P", options: ["Rabbit", "Pig", "Moon"], correct: 1),
        LetterQuestion(letter: "Q", options: ["Queen", "Apple", "Goat"], correct: 0), LetterQuestion(letter: "R", options: ["Fish", "Rabbit", "Hen"], correct: 1),
        LetterQuestion(letter: "S", options: ["Sun", "Dog", "Lion"], correct: 0), LetterQuestion(letter: "T", options: ["Moon", "Tree", "Cat"], correct: 1),
        LetterQuestion(letter: "U", options: ["Umbrella", "Apple", "Fish"], correct: 0), LetterQuestion(letter: "V", options: ["Dog", "Van", "Tree"], correct: 1),
        LetterQuestion(letter: "W", options: ["Water", "Lion", "Hen"], correct: 0), LetterQuestion(letter: "X", options: ["Cat", "Xylophone", "Sun"], correct: 1),
        LetterQuestion(letter: "Y", options: ["Yogurt", "Moon", "Fish"], correct: 0), LetterQuestion(letter: "Z", options: ["Dog", "Zebra", "Apple"], correct: 1)
    ]

    private static let greekLetterQuestions = [
        LetterQuestion(letter: "Α", options: ["Αρκούδα", "Μπάλα", "Γάτα"], correct: 0), LetterQuestion(letter: "Β", options: ["Σκύλος", "Βάρκα", "Ψάρι"], correct: 1),
        LetterQuestion(letter: "Γ", options: ["Μήλο", "Γάτα", "Ήλιος"], correct: 1), LetterQuestion(letter: "Δ", options: ["Δέντρο", "Κότα", "Αγελάδα"], correct: 0),
        LetterQuestion(letter: "Ε", options: ["Μπάλα", "Ελέφαντας", "Γάτα"], correct: 1), LetterQuestion(letter: "Ζ", options: ["Ζέβρα", "Μήλο", "Ψάρι"], correct: 0),
        LetterQuestion(letter: "Η", options: ["Γάτα", "Ήλιος", "Δέντρο"], correct: 1), LetterQuestion(letter: "Θ", options: ["Θάλασσα", "Βάρκα", "Μήλο"], correct: 0),
        LetterQuestion(letter: "Ι", options: ["Ψάρι", "Ιππότης", "Γάτα"], correct: 1), LetterQuestion(letter: "Κ", options: ["Κότα", "Μήλο", "Δέντρο"], correct: 0),
        LetterQuestion(letter: "Λ", options: ["Γάτα", "Λιοντάρι", "Ψάρι"], correct: 1), LetterQuestion(letter: "Μ", options: ["Αλεπού", "Πουλί", "Μήλο"], correct: 2),
        LetterQuestion(letter: "Ν", options: ["Νερό", "Γάτα", "Δέντρο"], correct: 0), LetterQuestion(letter: "Ξ", options: ["Μήλο", "Ξύλο", "Ψάρι"], correct: 1),
        LetterQuestion(letter: "Ο", options: ["Ομπρέλα", "Γάτα", "Δέντρο"], correct: 0), LetterQuestion(letter: "Π", options: ["Μήλο", "Πουλί", "Αρκούδα"], correct: 1),
        LetterQuestion(letter: "Ρ", options: ["Ρόδι", "Γάτα", "Ψάρι"], correct: 0), LetterQuestion(letter: "Σ", options: ["Μήλο", "Σκύλος", "Δέντρο"], correct: 1),
        LetterQuestion(letter: "Τ", options: ["Τίγρης", "Γάτα", "Ψάρι"], correct: 0), LetterQuestion(letter: "Υ", options: ["Δέντρο", "Ύαινα", "Μήλο"], correct: 1),
        LetterQuestion(letter: "Φ", options: ["Φίδι", "Γάτα", "Ψάρι"], correct: 0), LetterQuestion(letter: "Χ", options: ["Μήλο", "Χελώνα", "Δέντρο"], correct: 1),
        LetterQuestion(letter: "Ψ", options: ["Ψάρι", "Γάτα", "Μήλο"], correct: 0), LetterQuestion(letter: "Ω", options: ["Δέντρο", "Ώρα", "Γάτα"], correct: 1)
    ]

    private static let englishMatchPairs = [
        MatchWordPair(emoji: "🦖", word: "DINO"), MatchWordPair(emoji: "🐦", word: "BIRD"), MatchWordPair(emoji: "🦊", word: "FOX"),
        MatchWordPair(emoji: "🌳", word: "TREE"), MatchWordPair(emoji: "🍎", word: "APPLE"), MatchWordPair(emoji: "💧", word: "WATER"),
        MatchWordPair(emoji: "🪵", word: "WOOD"), MatchWordPair(emoji: "⭐", word: "STAR"), MatchWordPair(emoji: "🐟", word: "FISH"),
        MatchWordPair(emoji: "🌞", word: "SUN"), MatchWordPair(emoji: "🌙", word: "MOON"), MatchWordPair(emoji: "🏰", word: "CASTLE")
    ]

    private static let greekMatchPairs = [
        MatchWordPair(emoji: "🦖", word: "ΔΕΙΝΟΣΑΥΡΟΣ"), MatchWordPair(emoji: "🐦", word: "ΠΟΥΛΙ"), MatchWordPair(emoji: "🦊", word: "ΑΛΕΠΟΥ"),
        MatchWordPair(emoji: "🌳", word: "ΔΕΝΤΡΟ"), MatchWordPair(emoji: "🍎", word: "ΜΗΛΟ"), MatchWordPair(emoji: "💧", word: "ΝΕΡΟ"),
        MatchWordPair(emoji: "🪵", word: "ΞΥΛΟ"), MatchWordPair(emoji: "⭐", word: "ΑΣΤΕΡΙ"), MatchWordPair(emoji: "🐟", word: "ΨΑΡΙ"),
        MatchWordPair(emoji: "🌞", word: "ΗΛΙΟΣ"), MatchWordPair(emoji: "🌙", word: "ΦΕΓΓΑΡΙ"), MatchWordPair(emoji: "🏰", word: "ΚΑΣΤΡΟ")
    ]

    private static let englishSearchWords = ["DINO", "BIRD", "FOX", "TREE", "APPLE", "WATER", "WOOD", "STAR", "FISH", "SUN", "MOON", "CAVE"]
    private static let greekSearchWords = ["ΠΟΥΛΙ", "ΨΑΡΙ", "ΓΑΤΑ", "ΜΗΛΟ", "ΝΕΡΟ", "ΞΥΛΟ", "ΗΛΙΟΣ", "ΑΣΤΕΡΙ", "ΔΕΝΤΡΟ", "ΑΛΕΠΟΥ", "ΣΠΗΛΙΑ", "ΚΑΣΤΡΟ"]

    private static let englishScrambleWords = [
        ScrambleWord(answer: "APPLE", emoji: "🍎"), ScrambleWord(answer: "BIRD", emoji: "🐦"), ScrambleWord(answer: "FOX", emoji: "🦊"),
        ScrambleWord(answer: "TREE", emoji: "🌳"), ScrambleWord(answer: "WATER", emoji: "💧"), ScrambleWord(answer: "WOOD", emoji: "🪵"),
        ScrambleWord(answer: "STAR", emoji: "⭐"), ScrambleWord(answer: "FISH", emoji: "🐟"), ScrambleWord(answer: "MOON", emoji: "🌙"),
        ScrambleWord(answer: "CAVE", emoji: "🪨"), ScrambleWord(answer: "CASTLE", emoji: "🏰"), ScrambleWord(answer: "QUEEN", emoji: "👑")
    ]

    private static let greekScrambleWords = [
        ScrambleWord(answer: "ΓΑΤΑ", emoji: "🐱"), ScrambleWord(answer: "ΨΑΡΙ", emoji: "🐟"), ScrambleWord(answer: "ΗΛΙΟΣ", emoji: "☀️"),
        ScrambleWord(answer: "ΜΗΛΟ", emoji: "🍎"), ScrambleWord(answer: "ΝΕΡΟ", emoji: "💧"), ScrambleWord(answer: "ΞΥΛΟ", emoji: "🪵"),
        ScrambleWord(answer: "ΠΟΥΛΙ", emoji: "🐦"), ScrambleWord(answer: "ΔΕΝΤΡΟ", emoji: "🌳"), ScrambleWord(answer: "ΑΣΤΕΡΙ", emoji: "⭐"),
        ScrambleWord(answer: "ΣΠΗΛΙΑ", emoji: "🪨"), ScrambleWord(answer: "ΚΑΣΤΡΟ", emoji: "🏰"), ScrambleWord(answer: "ΣΤΕΜΜΑ", emoji: "👑")
    ]
}
