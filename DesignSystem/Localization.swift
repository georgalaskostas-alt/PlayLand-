import Foundation

/// Every language PlayLand can present its UI, stories and narration in.
/// `.system` follows the device's preferred language and resolves to
/// `.english` if that language isn't one PlayLand supports.
enum AppLanguage: String, CaseIterable, Identifiable, Hashable {
    case system
    case greek
    case english
    case spanish
    case french
    case german
    case italian
    case portuguese

    var id: String { rawValue }

    var localeIdentifier: String? {
        switch self {
        case .system: return nil
        case .greek: return "el"
        case .english: return "en"
        case .spanish: return "es"
        case .french: return "fr"
        case .german: return "de"
        case .italian: return "it"
        case .portuguese: return "pt"
        }
    }

    var speechLanguageCode: String? {
        switch self {
        case .system: return nil
        case .greek: return "el-GR"
        case .english: return "en-US"
        case .spanish: return "es-ES"
        case .french: return "fr-FR"
        case .german: return "de-DE"
        case .italian: return "it-IT"
        case .portuguese: return "pt-PT"
        }
    }

    var displayName: String {
        switch self {
        case .system: return Loc.t("settings.language.system")
        case .greek: return "Ελληνικά"
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .italian: return "Italiano"
        case .portuguese: return "Português"
        }
    }

    static func resolvedFromSystem() -> AppLanguage {
        let supported = AppLanguage.allCases.filter { $0 != .system }
        for preferred in Locale.preferredLanguages {
            let code = Locale(identifier: preferred).language.languageCode?.identifier ?? preferred
            if let match = supported.first(where: { $0.localeIdentifier == code }) {
                return match
            }
        }
        return .english
    }
}

/// Editorial long-form copy for the expanded Babis & Kotsifi story.
/// Kept beside the localization resolver so the story can ship without
/// creating another source file. Greek and English are editorially complete;
/// other supported languages temporarily fall back to English for these new
/// keys until their translations are approved.
private enum BabisKotsifiStoryText {
    static let en: [String: String] = [
        "story.babisKotsifi.title": "Babis and the Blackbird",
        "story.babisKotsifi.desc": "A story about friendship, courage, honesty and making things right.",
        "story.babisKotsifi.continue": "Continue",
        "story.babisKotsifi.scene0.narration": "Once upon a time, deep in a green forest, lived Babis, a dinosaur who looked fierce and terrifying. Whenever he walked between the trees, the animals hurried away because they were afraid of him.",
        "story.babisKotsifi.scene1.narration": "One morning, a tiny blackbird flew straight toward Babis and calmly landed on the tip of his nose. Babis looked at the little bird in surprise. “Aren’t you afraid of me? I’m fierce and terrifying!” he asked.",
        "story.babisKotsifi.scene2.narration": "“No,” said the blackbird. “You may look scary, but I think there is kindness inside you.” Babis had never heard anyone say that before. He thought for a moment and smiled.",
        "story.babisKotsifi.scene3.narration": "“Then let’s make a deal,” said Babis. “You can ride on my nose, and because you can see far from above, you can help me find food and water.” The blackbird happily agreed, and from that day they became a team.",
        "story.babisKotsifi.scene4.narration": "The next morning Babis asked, “Blackbird, where is the water?” The bird looked far across the forest. “To the left!” he chirped. Soon they reached a sparkling little lake, drank cool water and rested together.",
        "story.babisKotsifi.scene5.narration": "Then Babis asked, “And where can we find food?” The blackbird looked to the right and spotted an orchard. They found apples, pears, oranges and all kinds of good things. They ate until their tummies were full and returned home laughing.",
        "story.babisKotsifi.scene6.narration": "Day after day, Babis and the blackbird helped one another. The bird used his sharp eyes, and Babis used his strength. Before long they were the best of friends, and the forest animals began to notice that Babis was not as frightening as they had believed.",
        "story.babisKotsifi.scene7.narration": "But a sly fox was watching them from behind a bush. She had already stolen food and firewood from other animals. “If Babis is gentle enough to befriend a tiny bird, perhaps I can steal from him too,” she thought.",
        "story.babisKotsifi.scene8.narration": "The next morning, when Babis and the blackbird left the cave, the fox slipped inside. She carried away half their winter food and half their firewood, then hurried back to her own cave before anyone saw her.",
        "story.babisKotsifi.scene9.narration": "That afternoon Babis returned and froze. “Blackbird! Someone took our food and our wood!” he cried. The blackbird did not panic. What would be the smartest way to discover where the missing things had gone?",
        "story.babisKotsifi.scene9.choice0": "Fly to the tallest tree and look around carefully",
        "story.babisKotsifi.scene9.choice1": "Guess without looking for clues",
        "story.babisKotsifi.scene10.narration": "The blackbird flew to the very top of the tallest tree and searched the whole forest. From high above he noticed something strange: smoke rose from the fox’s cave, even though she had not gathered wood that winter. He flew down and told Babis. Babis was angry, but chose to think before acting.",
        "story.babisKotsifi.scene11.narration": "“Climb onto my nose. I have a plan,” said Babis. Together they went to the fox’s cave and hid behind a large tree until night fell. They wanted to discover the truth and make sure everything that had been stolen was returned.",
        "story.babisKotsifi.scene12.narration": "When the fox woke and saw Babis at the entrance, she was terrified. “Please, Babis! I’ll give your things back!” she cried. But Babis knew that fixing a wrong means helping everyone who was hurt. What should the fox do?",
        "story.babisKotsifi.scene12.choice0": "Return everything to every animal and apologize",
        "story.babisKotsifi.scene12.choice1": "Return only Babis’s things",
        "story.babisKotsifi.scene13.narration": "The next morning the fox kept her promise. She returned food and firewood all across the forest and apologized to every animal she had hurt. It was not easy, but with every apology she understood a little better why what she had done was wrong.",
        "story.babisKotsifi.scene14.narration": "From that day on, the animals no longer called Babis the terror of the forest. They called him their friend and their hero. Babis and the blackbird stayed inseparable, proving that true strength is not about frightening others—it is about helping, thinking and doing what is right. And they all lived happily ever after."
    ]

    static let el: [String: String] = [
        "story.babisKotsifi.title": "Ο Μπάμπης και το Κοτσύφι",
        "story.babisKotsifi.desc": "Ένα παραμύθι για τη φιλία, το θάρρος, την ειλικρίνεια και το πώς διορθώνουμε τα λάθη μας.",
        "story.babisKotsifi.continue": "Συνέχεια",
        "story.babisKotsifi.scene0.narration": "Μια φορά κι έναν καιρό, βαθιά μέσα σε ένα καταπράσινο δάσος, ζούσε ο Μπάμπης. Ο Μπάμπης ήταν ένας δεινόσαυρος που έμοιαζε φοβερός και τρομερός. Κάθε φορά που περπατούσε ανάμεσα στα δέντρα, τα ζώα έτρεχαν να κρυφτούν γιατί τον φοβόντουσαν.",
        "story.babisKotsifi.scene1.narration": "Ένα πρωινό, ένα μικρό κοτσύφι πέταξε καταπάνω του και κάθισε ήρεμα στην άκρη της μύτης του. Ο Μπάμπης κοίταξε το μικρό πουλάκι και απόρησε. «Μα καλά, δε με φοβάσαι; Εγώ είμαι φοβερός και τρομερός!» το ρώτησε.",
        "story.babisKotsifi.scene2.narration": "«Όχι», του είπε το κοτσύφι. «Μπορεί να μοιάζεις φοβερός και τρομερός, αλλά εγώ πιστεύω πως κατά βάθος είσαι καλός.» Κανείς δεν είχε ξαναμιλήσει έτσι στον Μπάμπη. Σκέφτηκε για λίγο και χαμογέλασε.",
        "story.babisKotsifi.scene3.narration": "«Τότε θα κάνουμε μια συμφωνία», είπε ο Μπάμπης. «Εγώ θα σε αφήνω να κάθεσαι πάνω στη μύτη μου κι εσύ, που βλέπεις μακριά από ψηλά, θα με βοηθάς να βρίσκω φαγητό και νερό.» Το κοτσύφι συμφώνησε χαρούμενο και από εκείνη τη μέρα έγιναν ομάδα.",
        "story.babisKotsifi.scene4.narration": "Το επόμενο πρωί ο Μπάμπης ρώτησε: «Κοτσύφι, πού είναι το νερό;» Το κοτσύφι κοίταξε μακριά πάνω από τα δέντρα. «Από δω αριστερά!» κελάηδησε. Σε λίγο έφτασαν σε μια λαμπερή λιμνούλα, ήπιαν δροσερό νεράκι και ξεκουράστηκαν μαζί.",
        "story.babisKotsifi.scene5.narration": "Ύστερα ο Μπάμπης ρώτησε: «Και πού είναι το φαγητό;» Το κοτσύφι κοίταξε δεξιά και είδε ένα περιβόλι. Εκεί βρήκαν μήλα, αχλάδια, πορτοκάλια και όλα τα καλά. Έφαγαν ώσπου χόρτασε η κοιλίτσα τους και γύρισαν στη σπηλιά γελώντας.",
        "story.babisKotsifi.scene6.narration": "Κάθε μέρα ο Μπάμπης και το κοτσύφι βοηθούσαν ο ένας τον άλλο. Το κοτσύφι είχε τα κοφτερά του μάτια και ο Μπάμπης τη μεγάλη του δύναμη. Σύντομα έγιναν οι καλύτεροι φίλοι και τα ζώα του δάσους άρχισαν να καταλαβαίνουν πως ο Μπάμπης δεν ήταν τόσο τρομερός όσο νόμιζαν.",
        "story.babisKotsifi.scene7.narration": "Όμως μια πονηρή αλεπού τους παρακολουθούσε πίσω από έναν θάμνο. Είχε ήδη κλέψει φαγητά και ξύλα από άλλα ζώα. «Αφού ο Μπάμπης είναι τόσο καλός ώστε να έχει φίλο ένα μικρό κοτσύφι, ίσως μπορώ να κλέψω και από εκείνον», σκέφτηκε.",
        "story.babisKotsifi.scene8.narration": "Το επόμενο πρωί, μόλις ο Μπάμπης και το κοτσύφι έφυγαν, η αλεπού γλίστρησε κρυφά μέσα στη σπηλιά. Πήρε τα μισά φαγητά και τα μισά ξύλα που είχαν μαζέψει για τον χειμώνα και έτρεξε πίσω στη δική της σπηλιά πριν τη δει κανείς.",
        "story.babisKotsifi.scene9.narration": "Το απόγευμα ο Μπάμπης γύρισε και έμεινε άφωνος. «Κοτσύφι! Κάποιος πήρε τα φαγητά και τα ξύλα μας!» φώναξε. Το κοτσύφι δεν πανικοβλήθηκε. Ποιος είναι ο πιο έξυπνος τρόπος για να ανακαλύψει πού πήγαν τα πράγματά τους;",
        "story.babisKotsifi.scene9.choice0": "Πέτα στο πιο ψηλό δέντρο και κοίτα προσεκτικά γύρω",
        "story.babisKotsifi.scene9.choice1": "Μάντεψε χωρίς να ψάξεις για στοιχεία",
        "story.babisKotsifi.scene10.narration": "Το κοτσύφι πέταξε στην κορυφή του πιο ψηλού δέντρου και κοίταξε προσεκτικά όλο το δάσος. Από ψηλά παρατήρησε κάτι παράξενο: από τη σπηλιά της αλεπούς έβγαινε καπνός, παρόλο που εκείνη δεν είχε μαζέψει ξύλα για τον χειμώνα. Κατέβηκε και το είπε στον Μπάμπη. Ο Μπάμπης θύμωσε, αλλά αποφάσισε πρώτα να σκεφτεί και μετά να δράσει.",
        "story.babisKotsifi.scene11.narration": "«Ανέβα στη μύτη μου. Έχω ένα σχέδιο», είπε ο Μπάμπης. Πήγαν μαζί έξω από τη σπηλιά της αλεπούς και κρύφτηκαν πίσω από ένα μεγάλο δέντρο ώσπου νύχτωσε. Ήθελαν να μάθουν την αλήθεια και να επιστραφούν όλα όσα είχαν κλαπεί.",
        "story.babisKotsifi.scene12.narration": "Όταν η αλεπού ξύπνησε και είδε τον Μπάμπη στην είσοδο, φοβήθηκε πολύ. «Σε παρακαλώ, Μπάμπη! Θα σου επιστρέψω τα πράγματά σου!» είπε. Όμως ο Μπάμπης ήξερε πως για να διορθώσεις ένα λάθος πρέπει να βοηθήσεις όλους όσους αδίκησες. Τι πρέπει να κάνει η αλεπού;",
        "story.babisKotsifi.scene12.choice0": "Να επιστρέψει τα πάντα σε όλα τα ζώα και να ζητήσει συγγνώμη",
        "story.babisKotsifi.scene12.choice1": "Να επιστρέψει μόνο τα πράγματα του Μπάμπη",
        "story.babisKotsifi.scene13.narration": "Το επόμενο πρωί η αλεπού κράτησε την υπόσχεσή της. Γύρισε φαγητά και ξύλα σε όλο το δάσος και ζήτησε συγγνώμη από κάθε ζώο που είχε αδικήσει. Δεν ήταν εύκολο, όμως με κάθε συγγνώμη καταλάβαινε λίγο καλύτερα γιατί αυτό που είχε κάνει ήταν λάθος.",
        "story.babisKotsifi.scene14.narration": "Από εκείνη τη μέρα τα ζώα δεν έλεγαν πια τον Μπάμπη «τον φόβο του δάσους». Τον έλεγαν φίλο τους και ήρωά τους. Ο Μπάμπης και το κοτσύφι έμειναν αχώριστοι και απέδειξαν πως αληθινή δύναμη δεν είναι να φοβίζεις τους άλλους, αλλά να βοηθάς, να σκέφτεσαι και να κάνεις το σωστό. Και ζήσαν αυτοί καλά κι εμείς καλύτερα."
    ]

    static func value(for key: String, language: AppLanguage) -> String? {
        guard key.hasPrefix("story.babisKotsifi.") else { return nil }
        return language == .greek ? (el[key] ?? en[key]) : en[key]
    }
}

/// Resolves and looks up localized strings against the app's selected language.
enum Loc {
    private static var bundleCache: [String: Bundle] = [:]

    static func bundle(for language: AppLanguage) -> Bundle {
        let resolved = language == .system ? AppSettings.shared.resolvedLanguage : language
        guard let code = resolved.localeIdentifier else { return .main }
        if let cached = bundleCache[code] { return cached }
        guard let path = Bundle.main.path(forResource: code, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        bundleCache[code] = bundle
        return bundle
    }

    static var currentBundle: Bundle {
        bundle(for: AppSettings.shared.language)
    }

    static func t(_ key: String) -> String {
        let language = AppSettings.shared.resolvedLanguage
        if let storyText = BabisKotsifiStoryText.value(for: key, language: language) {
            return storyText
        }
        return NSLocalizedString(key, bundle: currentBundle, comment: "")
    }

    static func t(_ key: String, _ args: CVarArg...) -> String {
        String(format: t(key), arguments: args)
    }

    static func t(_ key: String, args: [CVarArg]) -> String {
        String(format: t(key), arguments: args)
    }
}
