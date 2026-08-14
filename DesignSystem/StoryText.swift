import Foundation

/// Story-specific copy that can evolve independently from the main string catalog.
/// Existing story narration still resolves through `Loc`; this layer supplies
/// interactive prompts and feedback for the expanded Babis & Kotsifi story.
enum StoryText {
    private static let en: [String: String] = [
        "story.babisKotsifi.scene4.choice.left": "Go left — the blackbird saw water there",
        "story.babisKotsifi.scene4.choice.right": "Go right",
        "story.babisKotsifi.scene5.choice.right": "Go right — the orchard is there",
        "story.babisKotsifi.scene5.choice.left": "Go left",
        "story.babisKotsifi.scene9.choice0": "Fly to the tallest tree and look for clues",
        "story.babisKotsifi.scene9.choice1": "Guess without looking for clues",
        "story.babisKotsifi.scene12.choice0": "Return everything to every animal and apologize",
        "story.babisKotsifi.scene12.choice1": "Return only Babis’s things",
        "story.babisKotsifi.feedback.water": "Look carefully at what the blackbird said: the water is on the left. Try again.",
        "story.babisKotsifi.feedback.food": "Remember the blackbird’s clue: the orchard is on the right. Try again.",
        "story.babisKotsifi.feedback.clues": "A good problem-solver looks for evidence before deciding. What could the blackbird do from high above?",
        "story.babisKotsifi.feedback.repair": "Making things right means repairing the harm done to everyone, not only to one friend. Try again."
    ]

    private static let el: [String: String] = [
        "story.babisKotsifi.scene4.choice.left": "Πήγαινε αριστερά — εκεί είδε το νερό το κοτσύφι",
        "story.babisKotsifi.scene4.choice.right": "Πήγαινε δεξιά",
        "story.babisKotsifi.scene5.choice.right": "Πήγαινε δεξιά — εκεί είναι το περιβόλι",
        "story.babisKotsifi.scene5.choice.left": "Πήγαινε αριστερά",
        "story.babisKotsifi.scene9.choice0": "Πέτα στο πιο ψηλό δέντρο και ψάξε για στοιχεία",
        "story.babisKotsifi.scene9.choice1": "Μάντεψε χωρίς να ψάξεις για στοιχεία",
        "story.babisKotsifi.scene12.choice0": "Επέστρεψε τα πράγματα σε όλα τα ζώα και ζήτησε συγγνώμη",
        "story.babisKotsifi.scene12.choice1": "Επέστρεψε μόνο τα πράγματα του Μπάμπη",
        "story.babisKotsifi.feedback.water": "Άκουσε προσεκτικά τι είπε το κοτσύφι: το νερό είναι αριστερά. Προσπάθησε ξανά.",
        "story.babisKotsifi.feedback.food": "Θυμήσου το στοιχείο που έδωσε το κοτσύφι: το περιβόλι είναι δεξιά. Προσπάθησε ξανά.",
        "story.babisKotsifi.feedback.clues": "Ένας καλός εξερευνητής ψάχνει πρώτα για στοιχεία και μετά αποφασίζει. Τι μπορεί να κάνει το κοτσύφι από ψηλά;",
        "story.babisKotsifi.feedback.repair": "Για να διορθώσεις ένα λάθος πρέπει να βοηθήσεις όλους όσους αδίκησες, όχι μόνο έναν φίλο. Προσπάθησε ξανά."
    ]

    static func t(_ key: String) -> String {
        let language = AppSettings.shared.resolvedLanguage
        if language == .greek, let value = el[key] { return value }
        if let value = en[key] { return value }
        return Loc.t(key)
    }
}
