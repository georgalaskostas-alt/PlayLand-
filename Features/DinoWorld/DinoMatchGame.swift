import SwiftUI

private struct MatchTile: Identifiable {
    let id: Int
    let imageName: String
    let displayName: String
    var isCompleted = false
}

struct DinoMatchGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    private let totalLevels = 6
    private let tileCount = 15

    @State private var level = 1
    @State private var tiles: [MatchTile] = []
    @State private var targetOrder: [String] = []
    @State private var targetIndex = 0
    @State private var mistakes = 0
    @State private var totalMistakes = 0
    @State private var showLevelComplete = false
    @State private var isFinished = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 18) {
                    GameHeader(title: Loc.t("dino.match.title"), subtitle: Loc.t("dino.match.instruction"))
                    HStack {
                        Text(levelLabel).font(PlayLandTypography.heading).foregroundColor(PlayLandColors.sunOrange)
                        Spacer()
                        Text(progressLabel).font(PlayLandTypography.caption).foregroundColor(PlayLandColors.secondaryText)
                    }
                    if let target = currentTarget {
                        VStack(spacing: 8) {
                            Text(isGreek ? "Βρες το ίδιο!" : "Find the same one!").font(.headline.weight(.black)).foregroundStyle(PlayLandColors.primaryText)
                            AppAssets.image(target).resizable().scaledToFit().frame(height: 112).padding(10)
                                .background(PlayLandColors.warmCream)
                                .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge))
                                .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
                        }.padding(.bottom, 4)
                    }
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                        ForEach(tiles) { tile in
                            Button(action: { choose(tile) }) {
                                VStack(spacing: 3) {
                                    AppAssets.image(tile.imageName).resizable().scaledToFit().frame(height: 64)
                                    Text(tile.displayName).font(.system(size: 10, weight: .bold, design: .rounded)).foregroundStyle(PlayLandColors.primaryText).lineLimit(1)
                                }
                                .padding(5).frame(maxWidth: .infinity, minHeight: 88)
                                .background(tile.isCompleted ? PlayLandColors.leafGreen.opacity(0.20) : PlayLandColors.skyBlue.opacity(0.10))
                                .overlay(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium).stroke(tile.isCompleted ? PlayLandColors.leafGreen : Color.clear, lineWidth: 2))
                                .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
                            }.disabled(tile.isCompleted || currentTarget == nil)
                        }
                    }.padding(.horizontal, 4)
                    Text(isGreek ? "Λάθη: \(mistakes)" : "Mistakes: \(mistakes)").font(PlayLandTypography.body).foregroundColor(PlayLandColors.secondaryText)
                }.padding()
            }.onAppear(perform: setupLevel)

            if showLevelComplete {
                CompletionCelebrationView(title: isGreek ? "Ταίριαξες και τα 15!" : "All 15 matched!", message: isGreek ? "Στην επόμενη πίστα εμφανίζονται άλλοι χαρακτήρες." : "New characters appear on the next level.", stars: levelStars, buttonTitle: level < totalLevels ? (isGreek ? "Επόμενη πίστα" : "Next level") : Loc.t("action.continue"), action: advanceLevel)
            }
            if isFinished {
                CompletionCelebrationView(title: Loc.t("dino.match.completeTitle"), message: finalMessage, stars: finalStars, buttonTitle: Loc.t("dino.match.completeButton"), action: { progressManager.completeGame("dino_match", stars: finalStars); dismiss() })
            }
        }
    }

    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }
    private var levelLabel: String { isGreek ? "Επίπεδο \(level) από \(totalLevels) — 15 κουτάκια" : "Level \(level) of \(totalLevels) — 15 tiles" }
    private var progressLabel: String { isGreek ? "\(targetIndex)/15 σωστά" : "\(targetIndex)/15 correct" }
    private var levelStars: Int { mistakes == 0 ? 3 : (mistakes <= 3 ? 2 : 1) }
    private var finalStars: Int { totalMistakes <= 6 ? 3 : (totalMistakes <= 15 ? 2 : 1) }
    private var finalMessage: String { isGreek ? "Ολοκλήρωσες \(totalLevels) επίπεδα με δεινόσαυρους, ζώα, έντομα και μαγικά πλάσματα." : "You completed \(totalLevels) levels with dinosaurs, animals, insects and magical creatures." }
    private var currentTarget: String? { targetIndex < targetOrder.count ? targetOrder[targetIndex] : nil }

    private func creaturePool() -> [(String, String, String)] {
        [
            ("triceratops_rpg_neutral", "Τρικεράτοπας", "Triceratops"), ("stegosaurus_rpg_neutral", "Στεγόσαυρος", "Stegosaurus"),
            ("ankylosaurus_rpg_neutral", "Αγκυλόσαυρος", "Ankylosaurus"), ("parasaurolophus_rpg_neutral", "Παρασαυρόλοφος", "Parasaurolophus"),
            ("brachiosaurus_rpg_neutral", "Βραχιόσαυρος", "Brachiosaurus"), ("velociraptor_rpg_neutral", "Βελοσιράπτορας", "Velociraptor"),
            ("trex_rpg_neutral", "Τυραννόσαυρος", "T-Rex"), ("spinosaurus_rpg_neutral", "Σπινόσαυρος", "Spinosaurus"),
            ("pteranodon_rpg_neutral", "Πτερανόδοντας", "Pteranodon"), ("dilophosaurus_rpg_neutral", "Διλοφόσαυρος", "Dilophosaurus"),
            ("iguanodon_rpg_neutral", "Ιγκουανόδοντας", "Iguanodon"), ("pachycephalosaurus_rpg_neutral", "Παχυκεφαλόσαυρος", "Pachycephalosaurus"),
            ("bear_rpg_neutral", "Αρκούδα", "Bear"), ("deer_rpg_neutral", "Ελάφι", "Deer"), ("hedgehog_rpg_neutral", "Σκαντζόχοιρος", "Hedgehog"),
            ("squirrel_rpg_neutral", "Σκίουρος", "Squirrel"), ("owl_rpg_neutral", "Κουκουβάγια", "Owl"), ("frog_rpg_neutral", "Βάτραχος", "Frog"),
            ("raccoon_rpg_neutral", "Ρακούν", "Raccoon"), ("badger_rpg_neutral", "Ασβός", "Badger"), ("beaver_rpg_neutral", "Κάστορας", "Beaver"),
            ("otter_rpg_neutral", "Βίδρα", "Otter"), ("turtle_rpg_neutral", "Χελώνα", "Turtle"), ("mouse_rpg_neutral", "Ποντικάκι", "Mouse"),
            ("butterfly_rpg_neutral", "Πεταλούδα", "Butterfly"), ("bee_rpg_neutral", "Μέλισσα", "Bee"), ("ladybug_rpg_neutral", "Πασχαλίτσα", "Ladybug"),
            ("dragonfly_rpg_neutral", "Λιβελούλα", "Dragonfly"), ("grasshopper_rpg_neutral", "Ακρίδα", "Grasshopper"), ("snail_rpg_neutral", "Σαλιγκάρι", "Snail"),
            ("caterpillar_rpg_neutral", "Κάμπια", "Caterpillar"), ("firefly_rpg_neutral", "Πυγολαμπίδα", "Firefly"),
            ("baby_dragon_rpg_neutral", "Μικρός Δράκος", "Baby Dragon"), ("pegasus_rpg_neutral", "Πήγασος", "Pegasus"),
            ("forest_fairy_rpg_neutral", "Νεράιδα του Δάσους", "Forest Fairy"), ("forest_spirit_rpg_neutral", "Πνεύμα του Δάσους", "Forest Spirit"),
            ("unicorn_rpg_happy", "Μονόκερος", "Unicorn")
        ]
    }

    private func setupLevel() {
        let selected = Array(creaturePool().shuffled().prefix(tileCount))
        tiles = selected.enumerated().map { index, value in MatchTile(id: index, imageName: value.0, displayName: isGreek ? value.1 : value.2) }
        targetOrder = tiles.map(\.imageName).shuffled(); targetIndex = 0; mistakes = 0; showLevelComplete = false
    }
    private func choose(_ tile: MatchTile) {
        guard let target = currentTarget else { return }
        if tile.imageName == target {
            guard let index = tiles.firstIndex(where: { $0.id == tile.id }) else { return }
            tiles[index].isCompleted = true; targetIndex += 1; AudioManager.shared.play(.correct)
            if targetIndex >= targetOrder.count { withAnimation { showLevelComplete = true } }
        } else { mistakes += 1; totalMistakes += 1; AudioManager.shared.play(.wrong) }
    }
    private func advanceLevel() { if level >= totalLevels { showLevelComplete = false; isFinished = true } else { level += 1; setupLevel() } }
}
