import Foundation

/// Story-specific copy that can evolve independently from the main string catalog.
/// This layer supplies interactive prompts, feedback and narration for story
/// beats that do not yet live in the main localization catalog.
enum StoryText {
    private static let en: [String: String] = [
        "story.babisKotsifi.scene2.combinedNarration": "‘No,’ said the blackbird. ‘You may look fierce and terrifying, but deep down I think you are kind.’ Babis had never heard anyone say that before. He thought for a moment and replied, ‘Then let’s make a deal. I’ll let you ride on my nose, and because you can see far from above, you’ll help me find food and water.’ The blackbird happily agreed, and from that day they became a team.",
        "story.babisKotsifi.scene10.treeNarration": "Without wasting a moment, the blackbird flew to the very top of the tallest tree. From there he could see the whole forest. He searched carefully for a clue that might reveal where the stolen food and firewood had gone.",
        "story.babisKotsifi.scene11.smokeNarration": "Then he noticed something strange. The only cave with smoke rising from it was the fox’s cave. ‘She must have taken our food and firewood!’ he thought. He hurried down and flew back to tell Babis.",
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
        "story.babisKotsifi.scene2.combinedNarration": "«Όχι», του είπε το κοτσύφι. «Μπορεί να μοιάζεις φοβερός και τρομερός, αλλά κατά βάθος πιστεύω πως είσαι καλός.» Κανείς δεν είχε ξαναμιλήσει έτσι στον Μπάμπη. Σκέφτηκε για λίγο και του είπε: «Τότε θα κάνουμε μια συμφωνία. Εγώ θα σε αφήνω να κάθεσαι πάνω στη μύτη μου κι εσύ, που βλέπεις μακριά και καλά από ψηλά, θα μου λες πού είναι το φαγητό και πού είναι το νερό.» Το κοτσύφι συμφώνησε χαρούμενο και από εκείνη τη μέρα έγιναν ομάδα.",
        "story.babisKotsifi.scene10.treeNarration": "Το κοτσύφι, χωρίς να χάσει καθόλου καιρό, πέταξε στην πιο ψηλή κορυφή του πιο ψηλού δέντρου. Από εκεί πάνω μπορούσε να δει ολόκληρο το δάσος. Κοίταξε προσεκτικά παντού, ψάχνοντας ένα στοιχείο που θα τους έδειχνε πού είχαν πάει τα κλεμμένα πράγματα.",
        "story.babisKotsifi.scene11.smokeNarration": "Ξαφνικά πρόσεξε κάτι παράξενο. Η μόνη σπηλιά απ’ όπου έβγαινε καπνός ήταν η σπηλιά της αλεπούς. «Αυτή πρέπει να πήρε τα ξύλα και τα φαγητά μας!» σκέφτηκε. Κατέβηκε γρήγορα από το δέντρο και πέταξε να το πει στον Μπάμπη.",
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
