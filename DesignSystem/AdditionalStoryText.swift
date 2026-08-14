import Foundation

enum AdditionalStoryText {
    private static let en: [String: String] = [
        "story.common.continue": "Continue",
        "story.foxFeather.title": "The Fox and the Golden Feather",
        "story.foxFeather.desc": "A story about honesty, courage and making things right.",
        "story.foxFeather.s0": "One bright morning, the fox wandered through the forest looking for something special she could show everyone.",
        "story.foxFeather.s1": "She met Kotsifi, who told her that the forest birds had lost a precious golden feather used in their spring celebration.",
        "story.foxFeather.s2": "A little later, the fox found the golden feather shining beneath a bush. Her eyes widened with excitement.",
        "story.foxFeather.s3": "For a moment she thought about hiding it and pretending it belonged to her. No one had seen her find it.",
        "story.foxFeather.s4": "Back at the village, Kotsifi searched everywhere. The celebration could not begin without the feather.",
        "story.foxFeather.s5": "That night, the fox could not sleep. Keeping the feather had made her feel important for a moment, but now she felt heavy inside.",
        "story.foxFeather.s6": "In the morning she found Kotsifi and admitted the truth. She expected anger, but Kotsifi thanked her for being brave enough to tell the truth.",
        "story.foxFeather.s7": "The fox returned the feather to the birds and apologized for keeping it. Then she helped prepare the celebration.",
        "story.foxFeather.s8": "The animals welcomed her. They had not forgotten the mistake, but they could see that she had chosen to repair it.",
        "story.foxFeather.s9": "From that day on, the fox learned that honesty does not mean never making a mistake. It means having the courage to tell the truth and make things right.",

        "story.kotsifiStorm.title": "Kotsifi and the Great Storm",
        "story.kotsifiStorm.desc": "A story about courage, asking for help and helping others.",
        "story.kotsifiStorm.s0": "Kotsifi loved flying above the forest because from high in the sky he could see every path, river and tree.",
        "story.kotsifiStorm.s1": "One afternoon dark clouds covered the sun. The wind grew stronger and the first heavy drops began to fall.",
        "story.kotsifiStorm.s2": "Kotsifi wanted to prove he was brave, so he kept flying even when the branches started bending in the wind.",
        "story.kotsifiStorm.s3": "Then he heard the fox calling from below. A fallen branch had blocked the path to her cave and she was frightened.",
        "story.kotsifiStorm.s4": "Kotsifi landed beside her. He was too small to move the branch alone, and for the first time he understood that courage could also mean asking for help.",
        "story.kotsifiStorm.s5": "He flew through the rain toward Babis's cave, following the safest route he could remember.",
        "story.kotsifiStorm.s6": "Kotsifi told Babis what had happened. Babis did not laugh at him for being afraid. He immediately followed him into the storm.",
        "story.kotsifiStorm.s7": "Together they reached the fox. Babis lifted the heavy branch while Kotsifi showed them the safest way back.",
        "story.kotsifiStorm.s8": "When the storm passed, the three friends shared warm food and talked about what they had learned.",
        "story.kotsifiStorm.s9": "Kotsifi still loved being brave, but now he knew that real courage is not doing everything alone. Sometimes the bravest words are: I need help.",

        "story.crystalPromise.title": "The Promise of the Crystal Cave",
        "story.crystalPromise.desc": "A story about sharing, promises and cooperation.",
        "story.crystalPromise.s0": "Deep inside the crystal cave, Babis discovered a glowing blue crystal unlike anything he had ever seen.",
        "story.crystalPromise.s1": "Kotsifi reminded him of an old forest rule: rare treasures found in the common cave belonged to everyone and had to be shared.",
        "story.crystalPromise.s2": "The fox arrived and whispered that they could hide the crystal before anyone else found out.",
        "story.crystalPromise.s3": "Babis was tempted. The crystal was beautiful, but he had promised the animals that he would protect the cave for everyone.",
        "story.crystalPromise.s4": "Kotsifi suggested a better idea: take the crystal to the village and let all the animals decide together what to do with it.",
        "story.crystalPromise.s5": "The fox admitted that she had wanted the treasure for herself. Babis told her that wanting something was not wrong, but breaking a promise would hurt everyone.",
        "story.crystalPromise.s6": "At the village meeting, every animal had a chance to speak. They decided to place the crystal where everyone could enjoy its light.",
        "story.crystalPromise.s7": "The crystal became a lantern for the village square, shining every evening for every family in the forest.",
        "story.crystalPromise.s8": "The fox helped build the stand that held it, and Babis kept his promise to guard the cave fairly.",
        "story.crystalPromise.s9": "They learned that some treasures become more valuable when they are shared, and that a promise is strongest when we keep it even when nobody is watching."
    ]

    private static let el: [String: String] = [
        "story.common.continue": "Συνέχεια",
        "story.foxFeather.title": "Η Αλεπού και το Χρυσό Φτερό",
        "story.foxFeather.desc": "Ένα παραμύθι για την ειλικρίνεια, το θάρρος και τη διόρθωση των λαθών.",
        "story.foxFeather.s0": "Ένα φωτεινό πρωινό η αλεπού τριγυρνούσε στο δάσος ψάχνοντας κάτι ξεχωριστό για να εντυπωσιάσει τα υπόλοιπα ζώα.",
        "story.foxFeather.s1": "Συνάντησε το Κοτσύφι, που της είπε πως τα πουλιά είχαν χάσει ένα πολύτιμο χρυσό φτερό που χρησιμοποιούσαν στη γιορτή της άνοιξης.",
        "story.foxFeather.s2": "Λίγο αργότερα η αλεπού βρήκε το χρυσό φτερό να λάμπει κάτω από έναν θάμνο. Τα μάτια της άνοιξαν από τον ενθουσιασμό.",
        "story.foxFeather.s3": "Για μια στιγμή σκέφτηκε να το κρύψει και να πει πως ήταν δικό της. Κανείς δεν την είχε δει να το βρίσκει.",
        "story.foxFeather.s4": "Στο χωριό το Κοτσύφι έψαχνε παντού. Χωρίς το φτερό η γιορτή δεν μπορούσε να ξεκινήσει.",
        "story.foxFeather.s5": "Εκείνο το βράδυ η αλεπού δεν μπορούσε να κοιμηθεί. Για λίγο είχε νιώσει σημαντική, αλλά τώρα ένιωθε ένα βάρος μέσα της.",
        "story.foxFeather.s6": "Το πρωί βρήκε το Κοτσύφι και του είπε όλη την αλήθεια. Περίμενε να θυμώσει, όμως εκείνο την ευχαρίστησε που βρήκε το θάρρος να παραδεχτεί το λάθος της.",
        "story.foxFeather.s7": "Η αλεπού επέστρεψε το φτερό στα πουλιά, ζήτησε συγγνώμη και βοήθησε να ετοιμαστεί η γιορτή.",
        "story.foxFeather.s8": "Τα ζώα την καλωσόρισαν. Δεν ξέχασαν το λάθος, αλλά είδαν ότι προσπάθησε πραγματικά να το διορθώσει.",
        "story.foxFeather.s9": "Από τότε η αλεπού έμαθε πως ειλικρίνεια δεν σημαίνει να μην κάνουμε ποτέ λάθος. Σημαίνει να έχουμε το θάρρος να λέμε την αλήθεια και να διορθώνουμε ό,τι κάναμε.",

        "story.kotsifiStorm.title": "Το Κοτσύφι και η Μεγάλη Καταιγίδα",
        "story.kotsifiStorm.desc": "Ένα παραμύθι για το θάρρος, τη βοήθεια και τη δύναμη της συνεργασίας.",
        "story.kotsifiStorm.s0": "Το Κοτσύφι αγαπούσε να πετά ψηλά πάνω από το δάσος, γιατί από εκεί έβλεπε κάθε μονοπάτι, ποτάμι και δέντρο.",
        "story.kotsifiStorm.s1": "Ένα απόγευμα μαύρα σύννεφα σκέπασαν τον ήλιο. Ο αέρας δυνάμωσε και οι πρώτες χοντρές σταγόνες άρχισαν να πέφτουν.",
        "story.kotsifiStorm.s2": "Το Κοτσύφι ήθελε να αποδείξει ότι ήταν γενναίο και συνέχισε να πετά, ακόμη κι όταν τα κλαδιά λύγιζαν από τον αέρα.",
        "story.kotsifiStorm.s3": "Τότε άκουσε την αλεπού να φωνάζει από κάτω. Ένα πεσμένο κλαδί είχε κλείσει το μονοπάτι προς τη σπηλιά της και εκείνη είχε φοβηθεί.",
        "story.kotsifiStorm.s4": "Το Κοτσύφι προσγειώθηκε δίπλα της. Ήταν πολύ μικρό για να μετακινήσει μόνο του το κλαδί και κατάλαβε πως θάρρος σημαίνει και να ζητάς βοήθεια όταν τη χρειάζεσαι.",
        "story.kotsifiStorm.s5": "Πέταξε μέσα στη βροχή προς τη σπηλιά του Μπάμπη, ακολουθώντας το πιο ασφαλές μονοπάτι που θυμόταν.",
        "story.kotsifiStorm.s6": "Είπε στον Μπάμπη τι είχε συμβεί. Ο Μπάμπης δεν γέλασε επειδή φοβήθηκε. Σηκώθηκε αμέσως και τον ακολούθησε μέσα στην καταιγίδα.",
        "story.kotsifiStorm.s7": "Μαζί έφτασαν στην αλεπού. Ο Μπάμπης σήκωσε το βαρύ κλαδί και το Κοτσύφι τους έδειξε τον ασφαλέστερο δρόμο.",
        "story.kotsifiStorm.s8": "Όταν πέρασε η καταιγίδα, οι τρεις φίλοι μοιράστηκαν ζεστό φαγητό και μίλησαν για όσα είχαν μάθει.",
        "story.kotsifiStorm.s9": "Το Κοτσύφι εξακολουθούσε να αγαπά το θάρρος, αλλά τώρα ήξερε ότι πραγματική γενναιότητα δεν είναι να τα κάνεις όλα μόνος. Μερικές φορές οι πιο γενναίες λέξεις είναι: χρειάζομαι βοήθεια.",

        "story.crystalPromise.title": "Η Υπόσχεση της Κρυστάλλινης Σπηλιάς",
        "story.crystalPromise.desc": "Ένα παραμύθι για το μοίρασμα, τις υποσχέσεις και τη συνεργασία.",
        "story.crystalPromise.s0": "Βαθιά μέσα στην κρυστάλλινη σπηλιά ο Μπάμπης ανακάλυψε έναν γαλάζιο κρύσταλλο που έλαμπε περισσότερο από οτιδήποτε είχε δει.",
        "story.crystalPromise.s1": "Το Κοτσύφι του θύμισε έναν παλιό κανόνα του δάσους: οι σπάνιοι θησαυροί της κοινής σπηλιάς ανήκαν σε όλους και έπρεπε να μοιράζονται.",
        "story.crystalPromise.s2": "Η αλεπού εμφανίστηκε και ψιθύρισε πως μπορούσαν να κρύψουν τον κρύσταλλο πριν μάθει κανείς ότι τον βρήκαν.",
        "story.crystalPromise.s3": "Ο Μπάμπης μπήκε σε πειρασμό. Ο κρύσταλλος ήταν πανέμορφος, αλλά είχε υποσχεθεί στα ζώα ότι θα προστάτευε τη σπηλιά για όλους.",
        "story.crystalPromise.s4": "Το Κοτσύφι πρότεινε μια καλύτερη ιδέα: να πάρουν τον κρύσταλλο στο χωριό και να αποφασίσουν όλα τα ζώα μαζί τι θα τον κάνουν.",
        "story.crystalPromise.s5": "Η αλεπού παραδέχτηκε ότι ήθελε τον θησαυρό μόνο για εκείνη. Ο Μπάμπης της είπε πως δεν είναι κακό να θέλεις κάτι, αλλά το να σπάσεις μια υπόσχεση πληγώνει όλους.",
        "story.crystalPromise.s6": "Στη συγκέντρωση του χωριού κάθε ζώο μίλησε. Τελικά αποφάσισαν να βάλουν τον κρύσταλλο σε ένα σημείο όπου όλοι θα απολάμβαναν το φως του.",
        "story.crystalPromise.s7": "Ο κρύσταλλος έγινε το φανάρι της κεντρικής πλατείας και κάθε βράδυ φώτιζε για όλες τις οικογένειες του δάσους.",
        "story.crystalPromise.s8": "Η αλεπού βοήθησε να χτιστεί η βάση του και ο Μπάμπης κράτησε την υπόσχεσή του να προστατεύει δίκαια τη σπηλιά.",
        "story.crystalPromise.s9": "Έμαθαν πως μερικοί θησαυροί γίνονται πιο πολύτιμοι όταν τους μοιραζόμαστε και πως μια υπόσχεση έχει αξία όταν την κρατάμε ακόμη κι όταν κανείς δεν μας βλέπει."
    ]

    static func value(for key: String, language: AppLanguage) -> String? {
        if language == .greek { return el[key] ?? en[key] }
        return en[key]
    }
}
