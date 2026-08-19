import SwiftUI
import SpriteKit
import Combine
import UIKit

enum RPGArea: Int, CaseIterable, Identifiable {
    case forest
    case rescueClearing
    case village
    case riverCrossing
    case puzzleClearing
    case crystalCave
    case nightForest
    case unicornGrove
    case treasureClearing
    case foxDen

    var id: Int { rawValue }

    var groundAsset: String {
        switch self {
        case .forest: return "rpg_forest_ground_v2"
        case .rescueClearing: return "rpg_rescue_clearing"
        case .village: return "rpg_village_ground"
        case .riverCrossing: return "rpg_bridge_wood"
        case .puzzleClearing: return "rpg_puzzle_clearing"
        case .crystalCave: return "rpg_crystal_cave_ground"
        case .nightForest: return "rpg_night_forest_ground"
        case .unicornGrove: return "rpg_forest_ground_v2"
        case .treasureClearing: return "rpg_treasure_clearing"
        case .foxDen: return "rpg_fox_den"
        }
    }

    var completionId: String {
        switch self {
        case .forest: return "rpg_campaign_01_forest"
        case .rescueClearing: return "rpg_campaign_02_rescue"
        case .village: return "rpg_campaign_03_village"
        case .riverCrossing: return "rpg_campaign_04_river"
        case .puzzleClearing: return "rpg_campaign_05_puzzles"
        case .crystalCave: return "rpg_campaign_06_crystal_cave"
        case .nightForest: return "rpg_campaign_07_night_forest"
        case .unicornGrove: return "rpg_campaign_08_unicorn"
        case .treasureClearing: return "rpg_campaign_09_treasure"
        case .foxDen: return "rpg_campaign_10_finale"
        }
    }

    var icon: String {
        switch self {
        case .forest: return "🌲"
        case .rescueClearing: return "🐾"
        case .village: return "🏘️"
        case .riverCrossing: return "🌉"
        case .puzzleClearing: return "🧩"
        case .crystalCave: return "💎"
        case .nightForest: return "🌙"
        case .unicornGrove: return "🦄"
        case .treasureClearing: return "🏆"
        case .foxDen: return "🦊"
        }
    }
}

enum RPGNearbyAction: Equatable {
    case kotsifi
    case exit
    case fox
    case puzzle
    case animalRescue
    case animalTalk
    case treasure
    case unicorn
}

enum RPGChallenge: String, Identifiable, Equatable {
    case memory
    case numbers
    case shapes
    case words

    var id: String { rawValue }
}

struct RPGObjective: Identifiable {
    let id: String
    let icon: String
    let current: Int
    let target: Int
}

final class RPGGameState: ObservableObject {
    @Published var area: RPGArea = .forest
    @Published var areaCounters: [String: Int] = [:]
    @Published var inventory: [String: Int] = [:]
    @Published var questComplete = false
    @Published var message = ""
    @Published var nearbyAction: RPGNearbyAction?
    @Published var pendingChallenge: RPGChallenge?

    private weak var progress: ProgressViewModel?
    var isGreek: Bool { AppSettings.shared.resolvedLanguage == .greek }

    func attach(progress: ProgressViewModel) {
        self.progress = progress
        inventory = [
            "apple": progress.itemCount("apple_item"),
            "wood": progress.itemCount("log"),
            "water": progress.itemCount("water_item"),
            "berries": progress.itemCount("berries_item"),
            "carrot": progress.itemCount("carrot_item"),
            "crystal": progress.itemCount("crystal_item"),
            "key": progress.itemCount("key_item"),
            "fragment": progress.itemCount("map_fragment"),
            "feather": progress.itemCount("golden_feather")
        ]

        if let firstIncomplete = RPGArea.allCases.first(where: { !progress.isChallengeCompleted($0.completionId) }) {
            area = firstIncomplete
        } else {
            area = .foxDen
            questComplete = true
        }
        areaCounters = [:]
    }

    var currentAreaTitle: String {
        switch area {
        case .forest: return isGreek ? "Μεγάλο Δάσος" : "Great Forest"
        case .rescueClearing: return isGreek ? "Ξέφωτο Διάσωσης" : "Rescue Clearing"
        case .village: return isGreek ? "Χωριό των Ζώων" : "Animal Village"
        case .riverCrossing: return isGreek ? "Πέρασμα του Ποταμού" : "River Crossing"
        case .puzzleClearing: return isGreek ? "Ξέφωτο των Γρίφων" : "Puzzle Clearing"
        case .crystalCave: return isGreek ? "Κρυστάλλινη Σπηλιά" : "Crystal Cave"
        case .nightForest: return isGreek ? "Νυχτερινό Δάσος" : "Night Forest"
        case .unicornGrove: return isGreek ? "Άλσος του Μονόκερου" : "Unicorn Grove"
        case .treasureClearing: return isGreek ? "Ξέφωτο του Θησαυρού" : "Treasure Clearing"
        case .foxDen: return isGreek ? "Φωλιά της Αλεπούς" : "Fox Den"
        }
    }

    var areaNumberText: String {
        "\(area.rawValue + 1)/\(RPGArea.allCases.count)"
    }

    private func count(_ key: String) -> Int { areaCounters[key, default: 0] }

    var objectiveItems: [RPGObjective] {
        func o(_ key: String, _ icon: String, _ target: Int) -> RPGObjective {
            RPGObjective(id: key, icon: icon, current: count(key), target: target)
        }

        switch area {
        case .forest:
            return [o("apple", "🍎", 8), o("wood", "🪵", 5), o("water", "💧", 4), o("rescue", "🐾", 1), o("puzzle", "🧠", 1)]
        case .rescueClearing:
            return [o("berries", "🫐", 8), o("carrot", "🥕", 6), o("rescue", "🐾", 2), o("puzzle", "🧠", 1), o("treasure", "🧰", 1)]
        case .village:
            return [o("wood", "🪵", 8), o("berries", "🫐", 6), o("carrot", "🥕", 6), o("rescue", "🐾", 1), o("treasure", "🧰", 1)]
        case .riverCrossing:
            return [o("water", "💧", 8), o("wood", "🪵", 6), o("key", "🗝️", 2), o("rescue", "🐾", 1), o("puzzle", "🧩", 1)]
        case .puzzleClearing:
            return [o("crystal", "💎", 6), o("key", "🗝️", 3), o("puzzle", "🧩", 3), o("treasure", "🧰", 2)]
        case .crystalCave:
            return [o("crystal", "💎", 12), o("key", "🗝️", 4), o("puzzle", "🧩", 2), o("rescue", "🐾", 1), o("treasure", "🧰", 1)]
        case .nightForest:
            return [o("fragment", "🗺️", 8), o("feather", "⭐", 5), o("rescue", "🐾", 2), o("puzzle", "🧩", 1)]
        case .unicornGrove:
            return [o("crystal", "💎", 8), o("fragment", "🗺️", 4), o("puzzle", "🧩", 2), o("unicorn", "🦄", 1), o("treasure", "🧰", 1)]
        case .treasureClearing:
            return [o("key", "🗝️", 5), o("crystal", "💎", 8), o("treasure", "🧰", 3), o("puzzle", "🧩", 2)]
        case .foxDen:
            return [o("fox", "🦊", 1), o("puzzle", "🧩", 1), o("treasure", "🧰", 1)]
        }
    }

    var inventoryItems: [(String, String, Int)] {
        [
            ("apple_item", isGreek ? "Μήλα" : "Apples", inventory["apple", default: 0]),
            ("log", isGreek ? "Ξύλα" : "Logs", inventory["wood", default: 0]),
            ("water_item", isGreek ? "Νερό" : "Water", inventory["water", default: 0]),
            ("berries_item", isGreek ? "Μούρα" : "Berries", inventory["berries", default: 0]),
            ("carrot_item", isGreek ? "Καρότα" : "Carrots", inventory["carrot", default: 0]),
            ("crystal_item", isGreek ? "Κρύσταλλοι" : "Crystals", inventory["crystal", default: 0]),
            ("key_item", isGreek ? "Κλειδιά" : "Keys", inventory["key", default: 0]),
            ("map_fragment", isGreek ? "Κομμάτια χάρτη" : "Map pieces", inventory["fragment", default: 0]),
            ("golden_feather", isGreek ? "Χρυσά Φτερά" : "Golden feathers", inventory["feather", default: 0])
        ]
    }

    var areaGoalComplete: Bool {
        objectiveItems.allSatisfy { $0.current >= $0.target }
    }

    var interactionTitle: String {
        switch nearbyAction {
        case .kotsifi: return isGreek ? "Μίλα" : "Talk"
        case .exit: return areaGoalComplete ? (isGreek ? "Συνέχισε" : "Continue") : (isGreek ? "Έλεγξε" : "Check")
        case .fox: return isGreek ? "Μίλα στην Αλεπού" : "Talk to Fox"
        case .puzzle: return isGreek ? "Λύσε τον γρίφο" : "Solve puzzle"
        case .animalRescue: return isGreek ? "Βοήθησέ το" : "Help animal"
        case .animalTalk: return isGreek ? "Μίλα" : "Talk"
        case .treasure: return isGreek ? "Άνοιξε" : "Open"
        case .unicorn: return isGreek ? "Βοήθησε" : "Help"
        case .none: return ""
        }
    }

    var interactionIcon: String {
        switch nearbyAction {
        case .kotsifi: return "bubble.left.fill"
        case .exit: return "arrow.right.circle.fill"
        case .fox: return "bubble.left.and.bubble.right.fill"
        case .puzzle: return "brain.head.profile"
        case .animalRescue, .animalTalk: return "pawprint.fill"
        case .treasure: return "shippingbox.fill"
        case .unicorn: return "sparkles"
        case .none: return "hand.tap.fill"
        }
    }

    func collect(kind: String) {
        areaCounters[kind, default: 0] += 1
        inventory[kind, default: 0] += 1

        let itemId: String
        switch kind {
        case "apple": itemId = "apple_item"
        case "wood": itemId = "log"
        case "water": itemId = "water_item"
        case "berries": itemId = "berries_item"
        case "carrot": itemId = "carrot_item"
        case "crystal": itemId = "crystal_item"
        case "key": itemId = "key_item"
        case "fragment": itemId = "map_fragment"
        case "feather": itemId = "golden_feather"
        default: return
        }
        progress?.collectItem(itemId)
        AudioManager.shared.play(.correct)
        announceGoalIfReady()
    }

    func rescueAnimal(kind: String) {
        areaCounters["rescue", default: 0] += 1
        AudioManager.shared.play(.starReward)
        setMessage(
            greek: "Το \(animalGreekName(kind)) είναι ασφαλές! Συνέχισε την εξερεύνηση — υπάρχουν κι άλλες εκπλήξεις μπροστά.",
            english: "The \(kind) is safe! Keep exploring — more surprises are waiting ahead."
        )
        announceGoalIfReady()
    }

    func requestChallenge(_ challenge: RPGChallenge) {
        pendingChallenge = challenge
    }

    func completeChallenge(_ challenge: RPGChallenge) {
        pendingChallenge = nil
        areaCounters["puzzle", default: 0] += 1
        AudioManager.shared.play(.starReward)
        setMessage(
            greek: "Μπράβο! Έλυσες τον γρίφο. Το μονοπάτι συνεχίζεται!",
            english: "Great job! You solved the puzzle. The adventure continues!"
        )
        announceGoalIfReady()
    }

    func openTreasure() {
        areaCounters["treasure", default: 0] += 1
        AudioManager.shared.play(.starReward)
        setMessage(
            greek: "Θησαυρός! Μπράβο — βρήκες ένα κρυμμένο σεντούκι.",
            english: "Treasure! Great job — you found a hidden chest."
        )
        announceGoalIfReady()
    }

    func helpUnicorn() {
        areaCounters["unicorn"] = 1
        AudioManager.shared.play(.starReward)
        setMessage(
            greek: "Η μαγεία επέστρεψε! Ο μονόκερος σε ευχαριστεί και φωτίζει το μονοπάτι προς τον θησαυρό.",
            english: "The magic is back! The unicorn thanks you and lights the path toward the treasure."
        )
        announceGoalIfReady()
    }

    func meetFox() {
        areaCounters["fox"] = 1
        setMessage(
            greek: "Η Αλεπού δεν θέλει να πολεμήσει. Άκουσε την ιστορία της και βρες τον τελευταίο θησαυρό.",
            english: "The Fox does not want to fight. Hear her story and find the final treasure."
        )
        AudioManager.shared.play(.storyNext)
        announceGoalIfReady()
    }

    func advanceArea() {
        guard areaGoalComplete else { return }
        progress?.completeChallenge(area.completionId, rewardStars: area == .foxDen ? 5 : 3)
        nearbyAction = nil

        if area == .foxDen {
            questComplete = true
            AudioManager.shared.play(.gameCompletion)
            setMessage(
                greek: "Μεγάλη Περιπέτεια ολοκληρώθηκε! Ο Μπάμπης, το Κοτσύφι και οι φίλοι τους έσωσαν όλο το δάσος!",
                english: "Great Adventure complete! Babis, Kotsifi and their friends saved the whole forest!"
            )
            return
        }

        guard let next = RPGArea(rawValue: area.rawValue + 1) else { return }
        area = next
        areaCounters = [:]
        setMessageForCurrentArea()
    }

    func setMessageForCurrentArea() {
        switch area {
        case .forest:
            setMessage(greek: "Κεφάλαιο 1: εξερεύνησε το Μεγάλο Δάσος. Μάζεψε προμήθειες, σώσε το κουνελάκι και άνοιξε το πρώτο μαγικό σεντούκι.", english: "Chapter 1: explore the Great Forest. Gather supplies, rescue the rabbit and open the first magic chest.")
        case .rescueClearing:
            setMessage(greek: "Κεφάλαιο 2: στο Ξέφωτο Διάσωσης δύο ζωάκια χρειάζονται βοήθεια. Ψάξε κάθε μονοπάτι και κάθε γωνιά.", english: "Chapter 2: two animals need help in Rescue Clearing. Search every path and every corner.")
        case .village:
            setMessage(greek: "Κεφάλαιο 3: το Χωριό χρειάζεται προμήθειες. Μίλα στους φίλους, βρες το κρυμμένο σεντούκι και ετοίμασε το πέρασμα.", english: "Chapter 3: the Village needs supplies. Help your friends, find the hidden chest and prepare the crossing.")
        case .riverCrossing:
            setMessage(greek: "Κεφάλαιο 4: πέρασε το ποτάμι. Βρες ξύλα, νερό και τα δύο κλειδιά χωρίς να φύγεις από τα ασφαλή μονοπάτια.", english: "Chapter 4: cross the river. Find wood, water and two keys while staying on the safe routes.")
        case .puzzleClearing:
            setMessage(greek: "Κεφάλαιο 5: τρεις διαφορετικοί γρίφοι προστατεύουν το Ξέφωτο. Λύσε τους και βρες δύο θησαυρούς.", english: "Chapter 5: three different puzzles guard the Clearing. Solve them and find two treasures.")
        case .crystalCave:
            setMessage(greek: "Κεφάλαιο 6: μπες βαθιά στην Κρυστάλλινη Σπηλιά. Βρες τους κρυστάλλους, τα κλειδιά και το χαμένο ζωάκι.", english: "Chapter 6: travel deep into Crystal Cave. Find the crystals, keys and the lost animal.")
        case .nightForest:
            setMessage(greek: "Κεφάλαιο 7: νύχτωσε. Ακολούθησε τα κομμάτια του χάρτη και τα Χρυσά Φτερά και βοήθησε δύο φίλους.", english: "Chapter 7: night has fallen. Follow map pieces and Golden Feathers and help two friends.")
        case .unicornGrove:
            setMessage(greek: "Κεφάλαιο 8: ο μονόκερος έχασε τη μαγεία του. Βρες τους κρυστάλλους και λύσε τους γρίφους για να τον βοηθήσεις.", english: "Chapter 8: the unicorn lost its magic. Find the crystals and solve the puzzles to help it.")
        case .treasureClearing:
            setMessage(greek: "Κεφάλαιο 9: η μεγάλη αναζήτηση θησαυρού. Τρία σεντούκια, δύο γρίφοι και πέντε κλειδιά κρύβονται στο ξέφωτο.", english: "Chapter 9: the great treasure hunt. Three chests, two puzzles and five keys are hidden in the clearing.")
        case .foxDen:
            setMessage(greek: "Τελικό Κεφάλαιο: βρες την Αλεπού, λύσε τον τελευταίο γρίφο και άνοιξε τον τελευταίο θησαυρό.", english: "Final Chapter: find the Fox, solve the last puzzle and open the final treasure.")
        }
    }

    func setMessage(greek: String, english: String) {
        message = isGreek ? greek : english
    }

    private func announceGoalIfReady() {
        if areaGoalComplete {
            setMessage(
                greek: area == .foxDen ? "Όλα είναι έτοιμα. Πήγαινε στην έξοδο για να ολοκληρώσεις τη Μεγάλη Περιπέτεια!" : "Όλοι οι στόχοι ολοκληρώθηκαν! Βρες την πύλη ή το μεγάλο σεντούκι για να περάσεις στην επόμενη περιοχή.",
                english: area == .foxDen ? "Everything is ready. Go to the exit to finish the Great Adventure!" : "Every objective is complete! Find the gate or great chest to reach the next area."
            )
        }
    }

    private func animalGreekName(_ kind: String) -> String {
        switch kind {
        case "rabbit": return "κουνελάκι"
        case "hedgehog": return "σκαντζοχοιράκι"
        case "deer": return "ελαφάκι"
        case "squirrel": return "σκιουράκι"
        case "owl": return "κουκουβάγια"
        default: return "ζωάκι"
        }
    }
}

struct BabisRPGGameView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var progressManager: ProgressViewModel

    @StateObject private var gameState = RPGGameState()
    @State private var scene: BabisRPGScene?
    @State private var showInventory = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let scene {
                    SpriteView(scene: scene, options: [.allowsTransparency])
                        .ignoresSafeArea()
                } else {
                    Color.black.ignoresSafeArea()
                }

                premiumHUD

                if showInventory {
                    inventoryPanel
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        .zIndex(50)
                }
            }
            .background(Color.black)
            .onAppear {
                RPGOrientation.request(.landscape)
                if scene == nil {
                    gameState.attach(progress: progressManager)
                    gameState.setMessageForCurrentArea()
                    scene = BabisRPGScene(size: geometry.size, gameState: gameState)
                }
            }
            .onDisappear {
                scene?.stopMovement()
                SpeechManager.shared.stop()
                RPGOrientation.request(.portrait)
            }
            .onChange(of: geometry.size) { newSize in
                scene?.size = newSize
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .statusBarHidden(true)
        .fullScreenCover(item: $gameState.pendingChallenge) { challenge in
            NavigationStack {
                if challenge == .memory {
                    MemoryGame { _ in
                        gameState.completeChallenge(.memory)
                        scene?.completeActiveChallenge()
                        RPGOrientation.request(.landscape)
                        SpeechManager.shared.speak(text: gameState.message)
                    }
                    .environmentObject(progressManager)
                    .environmentObject(appSettings)
                } else {
                    RPGPuzzleChallengeView(
                        challenge: challenge,
                        isGreek: gameState.isGreek,
                        onSolved: {
                            gameState.completeChallenge(challenge)
                            scene?.completeActiveChallenge()
                            RPGOrientation.request(.landscape)
                            SpeechManager.shared.speak(text: gameState.message)
                        },
                        onCancel: {
                            gameState.pendingChallenge = nil
                            RPGOrientation.request(.landscape)
                        }
                    )
                }
            }
        }
    }

    private var premiumHUD: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 9) {
                playerCard
                objectivePanel
                Spacer(minLength: 8)

                if !gameState.message.isEmpty {
                    Text(gameState.message)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .frame(maxWidth: 420)
                        .background(.black.opacity(0.56))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Spacer(minLength: 8)
                companionButton
                miniMap
                inventoryButton
            }
            .padding(.horizontal, 14)
            .padding(.top, 9)

            Spacer()

            HStack(alignment: .bottom) {
                RPGJoystick { vector in scene?.setMovementVector(vector) }
                Spacer()
                if gameState.nearbyAction != nil {
                    interactionButton
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 16)
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.75), value: gameState.nearbyAction)
    }

    private var playerCard: some View {
        HStack(spacing: 9) {
            Image(uiImage: UIImage(named: "babis_rpg_idle") ?? UIImage(named: "babis_rpg_master") ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(width: 58, height: 58)
                .padding(3)
                .background(Circle().fill(.black.opacity(0.48)))
                .overlay(Circle().stroke(PlayLandColors.sunOrange, lineWidth: 2))

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text("Babis")
                    Text(gameState.areaNumberText)
                        .font(.caption2.weight(.black))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(.white.opacity(0.15))
                        .clipShape(Capsule())
                }
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(.white)

                Text(gameState.currentAreaTitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.82))
                    .lineLimit(1)
                Text(gameState.areaGoalComplete ? (gameState.isGreek ? "Στόχος έτοιμος" : "Goal ready") : (gameState.isGreek ? "Σε αποστολή" : "On quest"))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.black.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var objectivePanel: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(gameState.isGreek ? "ΑΠΟΣΤΟΛΗ" : "QUEST")
                .font(.caption2.weight(.black))
                .foregroundStyle(.white.opacity(0.78))

            HStack(spacing: 4) {
                ForEach(gameState.objectiveItems) { item in
                    objectiveChip(icon: item.icon, value: "\(min(item.current, item.target))/\(item.target)", complete: item.current >= item.target)
                }
            }
        }
        .padding(8)
        .background(.black.opacity(0.48))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var miniMap: some View {
        ZStack {
            Image(gameState.area.groundAsset)
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(Circle())
            Circle().stroke(PlayLandColors.sunOrange, lineWidth: 3).frame(width: 72, height: 72)
            Image(systemName: "location.north.fill")
                .font(.title3.weight(.black))
                .foregroundStyle(.white)
                .shadow(color: .black, radius: 3)
        }
    }

    private var companionButton: some View {
        Button { scene?.talkToCompanion() } label: {
            Image(uiImage: UIImage(named: "kotsifi_rpg_idle") ?? UIImage(named: "kotsifi_rpg_master") ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(width: 46, height: 46)
                .padding(6)
                .background(.black.opacity(0.5))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var inventoryButton: some View {
        Button { withAnimation { showInventory.toggle() } } label: {
            Image(systemName: "backpack.fill")
                .font(.title3.weight(.black))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(.black.opacity(0.52))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var interactionButton: some View {
        Button { scene?.performInteraction() } label: {
            VStack(spacing: 5) {
                Image(systemName: gameState.interactionIcon)
                    .font(.system(size: 25, weight: .black))
                Text(gameState.interactionTitle)
                    .font(.caption.weight(.black))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(.white)
            .frame(width: 98, height: 98)
            .background(Circle().fill(PlayLandColors.sunOrange.opacity(0.96)).shadow(color: .black.opacity(0.35), radius: 8, y: 4))
            .overlay(Circle().stroke(.white.opacity(0.65), lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    private var inventoryPanel: some View {
        ZStack(alignment: .trailing) {
            Color.black.opacity(0.46).ignoresSafeArea().onTapGesture { withAnimation { showInventory = false } }

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label(gameState.isGreek ? "Σακίδιο" : "Inventory", systemImage: "backpack.fill")
                        .font(.title2.weight(.black))
                    Spacer()
                    Button { withAnimation { showInventory = false } } label: {
                        Image(systemName: "xmark.circle.fill").font(.title2)
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(Array(gameState.inventoryItems.enumerated()), id: \.offset) { _, item in
                        VStack(spacing: 4) {
                            AppAssets.image(item.0)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 42)
                            Text("×\(item.2)").font(.headline.monospacedDigit())
                            Text(item.1).font(.caption2).multilineTextAlignment(.center).lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, minHeight: 90)
                        .padding(7)
                        .background(PlayLandColors.warmCream.opacity(0.96))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(18)
            .frame(width: 380)
            .frame(maxHeight: .infinity)
            .background(.ultraThickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.vertical, 14)
            .padding(.trailing, 14)
        }
    }

    private func objectiveChip(icon: String, value: String, complete: Bool) -> some View {
        HStack(spacing: 2) {
            Text(icon)
            Text(value)
                .font(.caption2.weight(.black).monospacedDigit())
                .foregroundStyle(.white)
            if complete {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(PlayLandColors.leafGreen)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
        .background(.white.opacity(0.12))
        .clipShape(Capsule())
    }
}

private struct RPGPuzzleChallengeView: View {
    let challenge: RPGChallenge
    let isGreek: Bool
    let onSolved: () -> Void
    let onCancel: () -> Void

    @State private var feedback = ""

    private var prompt: String {
        switch challenge {
        case .numbers: return isGreek ? "Ποιος αριθμός συνεχίζει τη σειρά; 2, 4, 6, 8, …" : "Which number continues the sequence? 2, 4, 6, 8, …"
        case .shapes: return isGreek ? "Ποιο σχήμα έρχεται μετά; ⭐ ▲ ● ⭐ ▲ …" : "Which shape comes next? ⭐ ▲ ● ⭐ ▲ …"
        case .words: return isGreek ? "Ποιο αντικείμενο ανοίγει ένα σεντούκι;" : "Which item opens a chest?"
        case .memory: return ""
        }
    }

    private var choices: [(String, Bool)] {
        switch challenge {
        case .numbers: return [("10", true), ("9", false), ("12", false)]
        case .shapes: return [("●", true), ("■", false), ("◆", false)]
        case .words: return [(isGreek ? "ΚΛΕΙΔΙ" : "KEY", true), (isGreek ? "ΜΗΛΟ" : "APPLE", false), (isGreek ? "ΝΕΡΟ" : "WATER", false)]
        case .memory: return []
        }
    }

    private var lockAsset: String {
        switch challenge {
        case .numbers: return "rpg_lock_numbers"
        case .shapes: return "pg_lock_shapes"
        case .words: return "rpg_lock_words"
        case .memory: return "rpg_lock_memory"
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.indigo.opacity(0.95), .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                HStack {
                    Spacer()
                    Button(action: onCancel) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                Image(lockAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 250)

                Text(isGreek ? "Μαγικός Γρίφος" : "Magic Puzzle")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text(prompt)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                HStack(spacing: 18) {
                    ForEach(Array(choices.enumerated()), id: \.offset) { _, choice in
                        Button {
                            if choice.1 {
                                feedback = isGreek ? "Μπράβο!" : "Great!"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { onSolved() }
                            } else {
                                feedback = isGreek ? "Δοκίμασε ξανά!" : "Try again!"
                                AudioManager.shared.play(.wrong)
                            }
                        } label: {
                            Text(choice.0)
                                .font(.system(size: 25, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(minWidth: 120, minHeight: 70)
                                .background(PlayLandColors.sunOrange)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                    }
                }

                Text(feedback)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                    .frame(height: 24)
            }
            .padding(26)
        }
        .statusBarHidden(true)
    }
}

private struct RPGJoystick: View {
    let onVectorChanged: (CGVector) -> Void
    @State private var knobOffset: CGSize = .zero

    private let diameter: CGFloat = 120
    private let knobDiameter: CGFloat = 54

    var body: some View {
        ZStack {
            Circle().fill(.black.opacity(0.42)).overlay(Circle().stroke(.white.opacity(0.22), lineWidth: 2))
            Circle()
                .fill(.white.opacity(0.23))
                .frame(width: knobDiameter, height: knobDiameter)
                .overlay(Circle().stroke(.white.opacity(0.35), lineWidth: 1))
                .offset(knobOffset)
        }
        .frame(width: diameter, height: diameter)
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    let center = CGPoint(x: diameter / 2, y: diameter / 2)
                    let rawX = value.location.x - center.x
                    let rawY = value.location.y - center.y
                    let radius = (diameter - knobDiameter) / 2
                    let distance = hypot(rawX, rawY)
                    let scale: CGFloat = distance > radius && distance > 0 ? radius / distance : 1
                    let x = rawX * scale
                    let y = rawY * scale
                    knobOffset = CGSize(width: x, height: y)
                    onVectorChanged(CGVector(dx: x / radius, dy: -y / radius))
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.72)) { knobOffset = .zero }
                    onVectorChanged(.zero)
                }
        )
    }
}

enum RPGOrientation {
    static func request(_ mask: UIInterfaceOrientationMask) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else { return }

        let preferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: mask)
        windowScene.requestGeometryUpdate(preferences) { error in
            print("RPG orientation request failed: \(error.localizedDescription)")
        }
        UIViewController.attemptRotationToDeviceOrientation()
    }
}
