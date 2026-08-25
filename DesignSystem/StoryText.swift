import Foundation

/// Story-specific copy that can evolve independently from the main string catalog.
/// The main Babis/Kotsifi story remains unchanged; the other stories receive
/// longer narration here without requiring edits to Localizable.xcstrings.
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
        "story.babisKotsifi.feedback.repair": "Making things right means repairing the harm done to everyone, not only to one friend. Try again.",

        "story.caveCrystals.scene0.narration": "At sunset, Babis and Kotsifi discovered a trail of tiny blue lights leading from the forest toward the old crystal cave. The lights pulsed like little stars, and a soft humming sound came from deep underground. Kotsifi suggested they follow the clues carefully instead of rushing in.",
        "story.caveCrystals.scene1.narration": "They entered through the narrow left passage. The walls sparkled with crystals, but the floor was slippery and every sound echoed twice. Babis slowed down so Kotsifi could fly ahead and check that the path was safe.",
        "story.caveCrystals.scene2.narration": "The right passage opened into a wide chamber filled with pale crystal columns. Their reflections made it hard to tell which way was real, so the friends watched the shadows and listened for the underground stream.",
        "story.caveCrystals.scene3.narration": "Near the deepest chamber they found the fox staring at a bright crystal trapped between two rocks. She admitted she had followed the glow alone and was now lost. Babis decided that finding the way out together mattered more than arguing about who had arrived first.",
        "story.caveCrystals.scene4.narration": "Behind the crystal they noticed old marks carved into the stone. Kotsifi recognized them as a map made by animals long ago. It showed a hidden bridge and warned that the brightest crystal should never be removed from the cave.",
        "story.caveCrystals.scene5.narration": "The hidden bridge crossed a dark underground river. Some stones were loose, so Babis tested each step while Kotsifi called out the safest route from above. The fox followed behind, carrying the small supplies they had collected.",
        "story.caveCrystals.scene6.narration": "On the other side, the great crystal began to dim. The fox wanted to carry it away, but Babis remembered the warning. They realized its light depended on the underground water flowing around its base, not on taking it somewhere else.",
        "story.caveCrystals.scene7.narration": "Working together, they cleared fallen stones from the stream. Water began to flow again, first as a trickle and then as a shining ribbon. One by one the crystals across the chamber lit up until the whole cave looked like a sky full of stars.",
        "story.caveCrystals.scene8.narration": "The three friends followed the glowing marks back toward daylight. Along the way they placed small stones at every turn so no younger animal would become lost. Kotsifi promised to draw a proper map for the village.",
        "story.caveCrystals.scene9.narration": "Back in the village, everyone gathered to hear what had happened. The friends did not bring home the great crystal; instead they brought knowledge of how to protect it. From then on, the cave became a place to visit respectfully, and its light belonged to everyone.",

        "story.forestHero.scene0.narration": "One moonless night, strange noises woke Babis. The forest paths were darker than usual because the fireflies had disappeared, and several small animals were afraid to leave their homes. Babis knew that a true night guardian first listens before deciding what is wrong.",
        "story.forestHero.scene1.narration": "Kotsifi joined him and flew above the treetops. From the air he noticed that the darkness was moving in patches, as if something were blocking the fireflies’ usual route. Together they began checking the forest one clearing at a time.",
        "story.forestHero.scene2.narration": "They met the fox beside a fallen tree. She had seen a strong wind push branches into the marsh where the fireflies lived. Instead of blaming her, Babis asked her to show them exactly what she had seen.",
        "story.forestHero.scene3.narration": "The three friends reached the marsh and heard tiny buzzing sounds behind a wall of branches. Dozens of fireflies were safe but trapped. Babis could move the heavy wood, while Kotsifi and the fox could guide the smallest insects away from danger.",
        "story.forestHero.scene4.narration": "They worked slowly because the night made every step harder. Babis lifted one branch at a time, Kotsifi watched from above, and the fox marked a safe path with pale stones. Soon the first fireflies escaped and began lighting the clearing again.",
        "story.forestHero.scene5.narration": "A frightened young hedgehog then called from across the stream. The bridge had washed away, so Babis could not simply walk over. Kotsifi found a fallen log downstream and showed Babis where to roll it into place.",
        "story.forestHero.scene6.narration": "As they helped the hedgehog cross, the fox heard another cry near the old oak. A family of mice had lost the path home. She used her sharp sense of smell to guide them while Babis kept the larger animals calm.",
        "story.forestHero.scene7.narration": "By the middle of the night, more fireflies had returned to the sky. The forest was still dark, but it no longer felt frightening because everyone was helping. Babis understood that being a guardian did not mean doing everything alone.",
        "story.forestHero.scene8.narration": "Just before dawn, Kotsifi flew high enough to see every rescued animal returning home. The fox checked the paths one last time, and Babis moved the final fallen branch away from the marsh. A warm line of sunlight appeared between the trees.",
        "story.forestHero.scene9.narration": "At the village, the animals thanked Babis for guarding the forest through the night. He pointed to Kotsifi, the fox and all the friends who had helped. ‘A forest is safest when everyone looks after one another,’ he said, and the returning fireflies sparkled above them like tiny lanterns."
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
        "story.babisKotsifi.feedback.repair": "Για να διορθώσεις ένα λάθος πρέπει να βοηθήσεις όλους όσους αδίκησες, όχι μόνο έναν φίλο. Προσπάθησε ξανά.",

        "story.caveCrystals.scene0.narration": "Καθώς έπεφτε ο ήλιος, ο Μπάμπης και το Κοτσύφι ανακάλυψαν ένα μονοπάτι από μικροσκοπικά γαλάζια φώτα που οδηγούσε από το δάσος προς την παλιά Σπηλιά των Κρυστάλλων. Τα φώτα αναβόσβηναν σαν αστεράκια και από τα βάθη της γης ακουγόταν ένα απαλό βουητό. Το Κοτσύφι πρότεινε να ακολουθήσουν τα σημάδια προσεκτικά και να μη βιαστούν.",
        "story.caveCrystals.scene1.narration": "Μπήκαν από το στενό αριστερό πέρασμα. Οι τοίχοι λαμπύριζαν από κρυστάλλους, όμως το έδαφος γλιστρούσε και κάθε ήχος αντηχούσε δύο φορές. Ο Μπάμπης προχωρούσε αργά, ενώ το Κοτσύφι πετούσε λίγο πιο μπροστά για να ελέγχει αν ο δρόμος ήταν ασφαλής.",
        "story.caveCrystals.scene2.narration": "Το δεξί πέρασμα άνοιγε σε μια μεγάλη αίθουσα γεμάτη ανοιχτόχρωμες κρυστάλλινες κολόνες. Οι αντανακλάσεις μπέρδευαν τα μάτια τους και δεν ήταν εύκολο να καταλάβουν ποιος δρόμος ήταν αληθινός. Έτσι παρατήρησαν τις σκιές και άκουσαν προσεκτικά το υπόγειο νερό.",
        "story.caveCrystals.scene3.narration": "Κοντά στη βαθύτερη αίθουσα βρήκαν την αλεπού να κοιτά έναν φωτεινό κρύσταλλο σφηνωμένο ανάμεσα σε δύο βράχους. Παραδέχτηκε ότι είχε ακολουθήσει μόνη της τη λάμψη και τώρα είχε χαθεί. Ο Μπάμπης αποφάσισε πως ήταν πιο σημαντικό να βρουν όλοι μαζί την έξοδο παρά να μαλώσουν για το ποιος έφτασε πρώτος.",
        "story.caveCrystals.scene4.narration": "Πίσω από τον κρύσταλλο πρόσεξαν παλιά σημάδια σκαλισμένα στην πέτρα. Το Κοτσύφι κατάλαβε ότι ήταν ένας χάρτης που είχαν αφήσει ζώα πολλά χρόνια πριν. Έδειχνε μια κρυφή γέφυρα και προειδοποιούσε ότι ο πιο λαμπερός κρύσταλλος δεν έπρεπε ποτέ να φύγει από τη σπηλιά.",
        "story.caveCrystals.scene5.narration": "Η κρυφή γέφυρα περνούσε πάνω από ένα σκοτεινό υπόγειο ποτάμι. Μερικές πέτρες κουνιόνταν, γι’ αυτό ο Μπάμπης δοκίμαζε κάθε βήμα πριν προχωρήσει, ενώ το Κοτσύφι τού έδειχνε από ψηλά το ασφαλέστερο σημείο. Η αλεπού ακολουθούσε κρατώντας τις μικρές προμήθειες που είχαν μαζί τους.",
        "story.caveCrystals.scene6.narration": "Στην άλλη πλευρά ο μεγάλος κρύσταλλος άρχισε να χάνει το φως του. Η αλεπού σκέφτηκε να τον πάρουν μαζί τους, όμως ο Μπάμπης θυμήθηκε την προειδοποίηση. Τότε κατάλαβαν πως το φως του εξαρτιόταν από το υπόγειο νερό που περνούσε γύρω από τη βάση του.",
        "story.caveCrystals.scene7.narration": "Δούλεψαν όλοι μαζί και απομάκρυναν τις πέτρες που είχαν φράξει το ρυάκι. Το νερό άρχισε πάλι να κυλά, πρώτα λίγο και ύστερα σαν φωτεινή κορδέλα. Ένας ένας οι κρύσταλλοι άναψαν, ώσπου ολόκληρη η σπηλιά έμοιαζε με ουρανό γεμάτο αστέρια.",
        "story.caveCrystals.scene8.narration": "Οι τρεις φίλοι ακολούθησαν τα φωτεινά σημάδια προς την έξοδο. Σε κάθε στροφή άφηναν μικρές πέτρες ώστε κανένα μικρότερο ζωάκι να μη χαθεί ξανά. Το Κοτσύφι υποσχέθηκε να φτιάξει έναν σωστό χάρτη για όλους στο χωριό.",
        "story.caveCrystals.scene9.narration": "Όταν επέστρεψαν στο χωριό, όλα τα ζώα μαζεύτηκαν για να ακούσουν την περιπέτεια. Οι φίλοι δεν έφεραν μαζί τους τον μεγάλο κρύσταλλο· έφεραν όμως τη γνώση για το πώς να τον προστατεύουν. Από τότε η σπηλιά έγινε ένα μέρος που όλοι επισκέπτονταν με σεβασμό και το φως της ανήκε σε όλους.",

        "story.forestHero.scene0.narration": "Μια νύχτα χωρίς φεγγάρι, παράξενοι ήχοι ξύπνησαν τον Μπάμπη. Τα μονοπάτια ήταν πιο σκοτεινά από ποτέ, γιατί οι πυγολαμπίδες είχαν εξαφανιστεί, και αρκετά μικρά ζωάκια φοβούνταν να βγουν από τα σπίτια τους. Ο Μπάμπης ήξερε πως ένας αληθινός Φύλακας της Νύχτας πρώτα ακούει και παρατηρεί και μετά αποφασίζει τι πρέπει να κάνει.",
        "story.forestHero.scene1.narration": "Το Κοτσύφι ήρθε μαζί του και πέταξε πάνω από τις κορυφές των δέντρων. Από ψηλά παρατήρησε ότι το σκοτάδι σχημάτιζε παράξενες κηλίδες, σαν κάτι να είχε κλείσει τον συνηθισμένο δρόμο των πυγολαμπίδων. Οι δυο φίλοι άρχισαν να ελέγχουν το δάσος ξέφωτο ξέφωτο.",
        "story.forestHero.scene2.narration": "Συνάντησαν την αλεπού δίπλα σε ένα πεσμένο δέντρο. Τους είπε πως είχε δει τον δυνατό αέρα να σπρώχνει πολλά κλαδιά προς τον βάλτο όπου ζούσαν οι πυγολαμπίδες. Αντί να την κατηγορήσει, ο Μπάμπης της ζήτησε να τους δείξει ακριβώς τι είχε συμβεί.",
        "story.forestHero.scene3.narration": "Οι τρεις φίλοι έφτασαν στον βάλτο και άκουσαν μικρά βουητά πίσω από έναν τοίχο από κλαδιά. Δεκάδες πυγολαμπίδες ήταν ασφαλείς αλλά παγιδευμένες. Ο Μπάμπης μπορούσε να μετακινήσει τα βαριά ξύλα, ενώ το Κοτσύφι και η αλεπού μπορούσαν να οδηγήσουν τα μικροσκοπικά έντομα μακριά από τον κίνδυνο.",
        "story.forestHero.scene4.narration": "Δούλεψαν αργά, γιατί το σκοτάδι έκανε κάθε βήμα δυσκολότερο. Ο Μπάμπης σήκωνε ένα κλαδί τη φορά, το Κοτσύφι παρατηρούσε από ψηλά και η αλεπού σημάδευε τον ασφαλή δρόμο με ανοιχτόχρωμες πέτρες. Σύντομα οι πρώτες πυγολαμπίδες ελευθερώθηκαν και άρχισαν να φωτίζουν ξανά το ξέφωτο.",
        "story.forestHero.scene5.narration": "Τότε ένα φοβισμένο σκαντζοχοιράκι φώναξε από την άλλη πλευρά του ρυακιού. Η μικρή γέφυρα είχε παρασυρθεί, οπότε ο Μπάμπης δεν μπορούσε απλώς να περάσει απέναντι. Το Κοτσύφι βρήκε έναν πεσμένο κορμό πιο κάτω και του έδειξε πού να τον κυλήσει για να φτιάξουν ένα ασφαλές πέρασμα.",
        "story.forestHero.scene6.narration": "Καθώς βοηθούσαν το σκαντζοχοιράκι, η αλεπού άκουσε άλλη μια φωνή κοντά στη μεγάλη βελανιδιά. Μια οικογένεια ποντικιών είχε χάσει το μονοπάτι για το σπίτι της. Η αλεπού χρησιμοποίησε την καλή όσφρησή της για να τους οδηγήσει, ενώ ο Μπάμπης καθησύχαζε τα μεγαλύτερα ζώα.",
        "story.forestHero.scene7.narration": "Στα μισά της νύχτας όλο και περισσότερες πυγολαμπίδες επέστρεφαν στον ουρανό. Το δάσος ήταν ακόμη σκοτεινό, όμως δεν έμοιαζε πια τρομακτικό, γιατί όλοι βοηθούσαν. Ο Μπάμπης κατάλαβε ότι το να είσαι φύλακας δεν σημαίνει να κάνεις τα πάντα μόνος σου.",
        "story.forestHero.scene8.narration": "Λίγο πριν ξημερώσει, το Κοτσύφι πέταξε τόσο ψηλά ώστε είδε όλα τα σωσμένα ζωάκια να επιστρέφουν στα σπίτια τους. Η αλεπού έλεγξε για τελευταία φορά τα μονοπάτια και ο Μπάμπης μετακίνησε το τελευταίο κλαδί από τον βάλτο. Μια ζεστή γραμμή φωτός εμφανίστηκε ανάμεσα στα δέντρα.",
        "story.forestHero.scene9.narration": "Στο χωριό τα ζώα ευχαρίστησαν τον Μπάμπη που φύλαξε το δάσος όλη τη νύχτα. Εκείνος έδειξε το Κοτσύφι, την αλεπού και όλους τους φίλους που είχαν βοηθήσει. «Το δάσος είναι πιο ασφαλές όταν φροντίζουμε ο ένας τον άλλον», είπε, και οι πυγολαμπίδες που είχαν επιστρέψει έλαμψαν από πάνω τους σαν μικρά φαναράκια."
    ]

    private static let expansionEN: [String: String] = [
        "story.foxFeather.s0": "She walked past the stream and the old oak, imagining how surprised everyone would be if she returned with a wonderful discovery.",
        "story.foxFeather.s1": "Kotsifi explained why the feather mattered: every bird had contributed something to the celebration, so losing it felt like losing a piece of their shared tradition.",
        "story.foxFeather.s2": "The feather was warmer than she expected, and for several quiet seconds she simply watched its golden light dance across the leaves.",
        "story.foxFeather.s3": "She tucked it away, but the excitement quickly turned into an uncomfortable secret that followed her all the way home.",
        "story.foxFeather.s4": "The fox watched from a distance and realized that her private choice was now affecting every bird in the village.",
        "story.foxFeather.s5": "Each time the moonlight touched the hidden feather, she remembered Kotsifi’s worried face and understood that keeping silent was also a choice.",
        "story.foxFeather.s6": "Saying the first words was difficult, but once the truth was out she felt lighter than she had all night.",
        "story.foxFeather.s7": "She stayed to hang ribbons, gather flowers and do the small jobs nobody else wanted, showing through actions that her apology was sincere.",
        "story.foxFeather.s8": "Trust did not return in a single second; it grew again through every helpful thing she chose to do.",
        "story.foxFeather.s9": "The golden feather shone at the center of the celebration, but the fox was proudest of something no one could see: the brave choice she had made.",
        "story.kotsifiStorm.s0": "He knew the forest so well that younger birds often followed him when they wanted to learn the safest routes between the trees.",
        "story.kotsifiStorm.s1": "Animals hurried toward shelter while leaves spun through the air and the familiar paths began to disappear beneath the rain.",
        "story.kotsifiStorm.s2": "A sudden gust pushed him sideways, and he finally understood that ignoring danger was not the same thing as being courageous.",
        "story.kotsifiStorm.s3": "The water was rising around the path, so there was no time to wait for the storm to stop on its own.",
        "story.kotsifiStorm.s4": "He took a steady breath, promised the fox he would return, and chose the safest plan instead of the fastest one.",
        "story.kotsifiStorm.s5": "Lightning lit the trees for a moment at a time, helping him recognize the landmarks he had seen on calmer days.",
        "story.kotsifiStorm.s6": "Babis listened carefully, gathered a rope and followed without wasting a moment, which made Kotsifi feel less alone.",
        "story.kotsifiStorm.s7": "They worked as a team: strength, sharp eyes and careful directions were all needed to make the rescue succeed.",
        "story.kotsifiStorm.s8": "They also checked the nearby nests and paths before resting, making sure no other animal had been left behind.",
        "story.kotsifiStorm.s9": "After that night, Kotsifi taught the younger birds both how to fly bravely and how to recognize when it was wiser to ask a friend for help.",
        "story.crystalPromise.s0": "Its light painted blue patterns on the cave walls, and even Babis’s footsteps seemed quieter beside something so rare.",
        "story.crystalPromise.s1": "The rule existed because the cave gave shelter, water and beautiful stones to many families, not to only one explorer.",
        "story.crystalPromise.s2": "For a moment the idea sounded easy, but hiding the crystal would also mean hiding the truth from every friend who trusted them.",
        "story.crystalPromise.s3": "He remembered that promises matter most precisely when keeping them costs us something we really want.",
        "story.crystalPromise.s4": "They wrapped the crystal carefully and agreed that nobody would decide its future alone.",
        "story.crystalPromise.s5": "The fox listened, then chose to come with them and explain her own temptation honestly at the village meeting.",
        "story.crystalPromise.s6": "The smallest animals spoke first, then the older ones, and Babis made sure every voice was heard before anyone voted.",
        "story.crystalPromise.s7": "Children gathered beneath its gentle glow each evening, and travelers used the light to find the village path after sunset.",
        "story.crystalPromise.s8": "Together they also placed a sign at the cave reminding future explorers that its rare treasures belonged to the whole forest.",
        "story.crystalPromise.s9": "Whenever the lantern glowed, it reminded them that cooperation can turn one beautiful object into something useful for an entire community."
    ]

    private static let expansionEL: [String: String] = [
        "story.foxFeather.s0": "Πέρασε από το ρυάκι και τη μεγάλη βελανιδιά, φανταζόμενη πόσο θα εντυπωσιάζονταν όλοι αν επέστρεφε με μια σπουδαία ανακάλυψη.",
        "story.foxFeather.s1": "Το Κοτσύφι της εξήγησε γιατί το φτερό ήταν τόσο σημαντικό: κάθε πουλί είχε προσφέρει κάτι στη γιορτή, γι’ αυτό η απώλειά του έμοιαζε σαν να έλειπε ένα κομμάτι από κάτι που ανήκε σε όλους.",
        "story.foxFeather.s2": "Το φτερό ήταν πιο ζεστό απ’ όσο περίμενε και για λίγες ήσυχες στιγμές απλώς κοιτούσε το χρυσό φως του να χορεύει πάνω στα φύλλα.",
        "story.foxFeather.s3": "Το έκρυψε, όμως ο ενθουσιασμός γρήγορα έγινε ένα άβολο μυστικό που την ακολούθησε μέχρι το σπίτι.",
        "story.foxFeather.s4": "Η αλεπού παρακολουθούσε από μακριά και κατάλαβε ότι μια δική της κρυφή επιλογή επηρέαζε τώρα όλα τα πουλιά του χωριού.",
        "story.foxFeather.s5": "Κάθε φορά που το φως του φεγγαριού έπεφτε πάνω στο κρυμμένο φτερό, θυμόταν το ανήσυχο πρόσωπο του Κοτσυφιού και καταλάβαινε ότι και η σιωπή ήταν μια επιλογή.",
        "story.foxFeather.s6": "Οι πρώτες λέξεις ήταν δύσκολες, αλλά μόλις είπε την αλήθεια ένιωσε πιο ανάλαφρη από ό,τι όλη τη νύχτα.",
        "story.foxFeather.s7": "Έμεινε για να κρεμάσει κορδέλες, να μαζέψει λουλούδια και να κάνει τις μικρές δουλειές που κανείς άλλος δεν ήθελε, δείχνοντας με πράξεις ότι η συγγνώμη της ήταν αληθινή.",
        "story.foxFeather.s8": "Η εμπιστοσύνη δεν γύρισε μέσα σε ένα δευτερόλεπτο· χτιζόταν ξανά με κάθε καλή επιλογή που έκανε.",
        "story.foxFeather.s9": "Το χρυσό φτερό έλαμπε στο κέντρο της γιορτής, όμως η αλεπού ήταν περισσότερο περήφανη για κάτι που κανείς δεν μπορούσε να δει: τη γενναία επιλογή που είχε κάνει.",
        "story.kotsifiStorm.s0": "Ήξερε το δάσος τόσο καλά, ώστε τα μικρότερα πουλιά συχνά το ακολουθούσαν για να μάθουν τα ασφαλέστερα περάσματα ανάμεσα στα δέντρα.",
        "story.kotsifiStorm.s1": "Τα ζώα έτρεχαν να βρουν καταφύγιο, ενώ τα φύλλα στριφογύριζαν στον αέρα και τα γνώριμα μονοπάτια άρχισαν να χάνονται κάτω από τη βροχή.",
        "story.kotsifiStorm.s2": "Μια ξαφνική ριπή το έσπρωξε στο πλάι και τότε κατάλαβε ότι το να αγνοείς τον κίνδυνο δεν είναι το ίδιο με το να είσαι γενναίος.",
        "story.kotsifiStorm.s3": "Το νερό ανέβαινε γύρω από το μονοπάτι, οπότε δεν υπήρχε χρόνος να περιμένουν απλώς να τελειώσει η καταιγίδα.",
        "story.kotsifiStorm.s4": "Πήρε μια βαθιά ανάσα, υποσχέθηκε στην αλεπού ότι θα επιστρέψει και διάλεξε το πιο ασφαλές σχέδιο αντί για το πιο γρήγορο.",
        "story.kotsifiStorm.s5": "Οι αστραπές φώτιζαν τα δέντρα για λίγες στιγμές κάθε φορά και τον βοηθούσαν να αναγνωρίζει σημάδια που ήξερε από τις ήρεμες μέρες.",
        "story.kotsifiStorm.s6": "Ο Μπάμπης άκουσε προσεκτικά, πήρε ένα σχοινί και ξεκίνησε μαζί του χωρίς να χάσει χρόνο, κάνοντας το Κοτσύφι να νιώσει ότι δεν ήταν μόνο του.",
        "story.kotsifiStorm.s7": "Δούλεψαν σαν ομάδα: η δύναμη, τα καλά μάτια και οι προσεκτικές οδηγίες ήταν όλα απαραίτητα για να πετύχει η διάσωση.",
        "story.kotsifiStorm.s8": "Πριν ξεκουραστούν, έλεγξαν και τις κοντινές φωλιές και τα μονοπάτια για να βεβαιωθούν ότι κανένα άλλο ζωάκι δεν είχε μείνει πίσω.",
        "story.kotsifiStorm.s9": "Μετά από εκείνη τη νύχτα, το Κοτσύφι μάθαινε στα μικρότερα πουλιά όχι μόνο να πετούν με θάρρος, αλλά και να καταλαβαίνουν πότε είναι πιο σοφό να ζητούν βοήθεια από έναν φίλο.",
        "story.crystalPromise.s0": "Το φως του ζωγράφιζε γαλάζια σχέδια στους τοίχους της σπηλιάς και ακόμη και τα βήματα του Μπάμπη έμοιαζαν πιο ήσυχα μπροστά σε κάτι τόσο σπάνιο.",
        "story.crystalPromise.s1": "Ο κανόνας υπήρχε επειδή η σπηλιά πρόσφερε καταφύγιο, νερό και όμορφες πέτρες σε πολλές οικογένειες και όχι μόνο σε έναν εξερευνητή.",
        "story.crystalPromise.s2": "Για μια στιγμή η ιδέα φάνηκε εύκολη, όμως το να κρύψουν τον κρύσταλλο θα σήμαινε ότι θα έκρυβαν και την αλήθεια από όλους τους φίλους που τους εμπιστεύονταν.",
        "story.crystalPromise.s3": "Θυμήθηκε ότι μια υπόσχεση έχει μεγαλύτερη αξία ακριβώς όταν είναι δύσκολο να την κρατήσουμε επειδή θέλουμε πολύ κάτι άλλο.",
        "story.crystalPromise.s4": "Τύλιξαν τον κρύσταλλο προσεκτικά και συμφώνησαν ότι κανείς δεν θα αποφάσιζε μόνος του για το μέλλον του.",
        "story.crystalPromise.s5": "Η αλεπού άκουσε, ύστερα αποφάσισε να πάει μαζί τους και να μιλήσει με ειλικρίνεια στο χωριό για τον δικό της πειρασμό.",
        "story.crystalPromise.s6": "Πρώτα μίλησαν τα μικρότερα ζώα και μετά τα μεγαλύτερα, ενώ ο Μπάμπης φρόντισε να ακουστεί κάθε γνώμη πριν αποφασίσουν.",
        "story.crystalPromise.s7": "Κάθε βράδυ τα παιδιά μαζεύονταν κάτω από το απαλό φως του και οι ταξιδιώτες το χρησιμοποιούσαν για να βρίσκουν το μονοπάτι του χωριού μετά τη δύση του ήλιου.",
        "story.crystalPromise.s8": "Όλοι μαζί έβαλαν και μια πινακίδα στη σπηλιά που θύμιζε στους μελλοντικούς εξερευνητές ότι οι σπάνιοι θησαυροί της ανήκαν σε ολόκληρο το δάσος.",
        "story.crystalPromise.s9": "Κάθε φορά που άναβε το φανάρι, τους θύμιζε ότι η συνεργασία μπορεί να μετατρέψει ένα όμορφο αντικείμενο σε κάτι χρήσιμο για μια ολόκληρη κοινότητα."
    ]

    static func t(_ key: String) -> String {
        let language = AppSettings.shared.resolvedLanguage

        if let direct = language == .greek ? el[key] : en[key] { return direct }

        if let additional = AdditionalStoryText.value(for: key, language: language) {
            let expansion = language == .greek ? expansionEL[key] : expansionEN[key]
            return expansion.map { additional + " " + $0 } ?? additional
        }

        if language == .greek, let value = el[key] { return value }
        if let value = en[key] { return value }
        return Loc.t(key)
    }
}
