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

/// Per-language educational content packs for the word/letter games.
///
/// Game *logic* (matching, scoring, scrambling) is language-independent and
/// lives in the game views; only the *content* — which letters, which
/// words — changes per language, and it changes here, not by mechanically
/// translating one language's spelling list into another. Today there are
/// real content packs for English and Greek (the two languages required to
/// work end-to-end); every other supported UI language falls back to the
/// English pack until a native pack is authored for it — see the final
/// report for exactly which.
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
        LetterQuestion(letter: "A", options: ["Apple", "Ball", "Cat"], correct: 0),
        LetterQuestion(letter: "B", options: ["Dog", "Ball", "Elephant"], correct: 1),
        LetterQuestion(letter: "C", options: ["Apple", "Cat", "Fish"], correct: 1),
        LetterQuestion(letter: "D", options: ["Dog", "Goat", "Hen"], correct: 0),
        LetterQuestion(letter: "F", options: ["Ant", "Fish", "Owl"], correct: 1)
    ]

    private static let greekLetterQuestions = [
        LetterQuestion(letter: "Α", options: ["Αρκούδα", "Μπάλα", "Γάτα"], correct: 0),
        LetterQuestion(letter: "Β", options: ["Βάρκα", "Σκύλος", "Ψάρι"], correct: 0),
        LetterQuestion(letter: "Γ", options: ["Μήλο", "Γάτα", "Ήλιος"], correct: 1),
        LetterQuestion(letter: "Δ", options: ["Δέντρο", "Κότα", "Αγελάδα"], correct: 0),
        LetterQuestion(letter: "Μ", options: ["Αλεπού", "Πουλί", "Μήλο"], correct: 2)
    ]

    private static let englishMatchPairs = [
        MatchWordPair(emoji: "🦖", word: "DINO"),
        MatchWordPair(emoji: "🐦", word: "BIRD"),
        MatchWordPair(emoji: "🦊", word: "FOX"),
        MatchWordPair(emoji: "🌳", word: "TREE")
    ]

    private static let greekMatchPairs = [
        MatchWordPair(emoji: "🦖", word: "ΔΕΙΝΟΣΑΥΡΟΣ"),
        MatchWordPair(emoji: "🐦", word: "ΠΟΥΛΙ"),
        MatchWordPair(emoji: "🦊", word: "ΑΛΕΠΟΥ"),
        MatchWordPair(emoji: "🌳", word: "ΔΕΝΤΡΟ")
    ]

    private static let englishSearchWords = ["DINO", "BIRD", "FOX"]
    private static let greekSearchWords = ["ΠΟΥΛΙ", "ΨΑΡΙ", "ΓΑΤΑ"]

    private static let englishScrambleWords = [
        ScrambleWord(answer: "APPLE", emoji: "🍎"),
        ScrambleWord(answer: "BIRD", emoji: "🐦"),
        ScrambleWord(answer: "FOX", emoji: "🦊")
    ]

    private static let greekScrambleWords = [
        ScrambleWord(answer: "ΓΑΤΑ", emoji: "🐱"),
        ScrambleWord(answer: "ΨΑΡΙ", emoji: "🐟"),
        ScrambleWord(answer: "ΗΛΙΟΣ", emoji: "☀️")
    ]
}
