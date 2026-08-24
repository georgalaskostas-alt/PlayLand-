import SwiftUI

private struct SortCreature: Identifiable {
    let id: Int
    let imageName: String
    let name: String
    let isBig: Bool
    var sorted = false
}

struct DinoSortGame: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    var onChallengeComplete: ((Int) -> Void)?

    @State private var level = 1
    @State private var creatures: [SortCreature] = []
    @State private var selectedId: Int?
    @State private var mistakes = 0
    @State private var totalMistakes = 0
    @State private var showLevelComplete = false
    @State private var isFinished = false
    private let totalLevels = 6
    private let figuresPerLevel = 12

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    GameHeader(title: Loc.t("dino.sort.title"), subtitle: Loc.t("dino.sort.instruction"))
                    HStack {
                        Text(levelLabel).font(PlayLandTypography.heading).foregroundColor(PlayLandColors.sunOrange)
                        Spacer(); Text(creatureCountLabel).font(PlayLandTypography.caption).foregroundColor(PlayLandColors.secondaryText)
                    }
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                        ForEach(creatures) { creature in
                            if !creature.sorted {
                                Button(action: { selectedId = creature.id }) {
                                    VStack(spacing: 4) {
                                        AppAssets.image(creature.imageName).resizable().scaledToFit().frame(height: 66)
                                        Text(creature.name).font(.caption2.weight(.bold)).foregroundStyle(PlayLandColors.primaryText).lineLimit(1)
                                    }.padding(6).frame(maxWidth: .infinity, minHeight: 92)
                                    .background(selectedId == creature.id ? PlayLandColors.sunOrange.opacity(0.3) : PlayLandColors.skyBlue.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
                                }
                            }
                        }
                    }.padding(.horizontal, 4)
                    HStack(spacing: 20) { sortBin(title: Loc.t("dino.sort.small"), emoji: "🐞", isBig: false); sortBin(title: Loc.t("dino.sort.big"), emoji: "🦕", isBig: true) }.padding(.horizontal)
                    Text(Loc.t("dino.sort.mistakes", mistakes)).font(PlayLandTypography.body).foregroundColor(PlayLandColors.secondaryText)
                }.padding()
            }.onAppear(perform: setupLevel)
            if showLevelComplete { CompletionCelebrationView(title: levelCompleteTitle, message: levelCompleteMessage, stars: levelStars, buttonTitle: level < totalLevels ? nextLevelTitle : Loc.t("action.continue"), action: advanceLevel) }
            if isFinished { CompletionCelebrationView(title: Loc.t("dino.sort.completeTitle"), message: finalMessage, stars: finalStars, buttonTitle: Loc.t("dino.sort.completeButton"), action: { progressManager.completeGame("dino_sort", stars: finalStars); if let onChallengeComplete { onChallengeComplete(finalStars) } else { dismiss() } }) }
        }
    }

    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }
    private var levelLabel: String { isGreek ? "Επίπεδο \(level) από \(totalLevels)" : "Level \(level) of \(totalLevels)" }
    private var creatureCountLabel: String { isGreek ? "12 φιγούρες" : "12 figures" }
    private var levelCompleteTitle: String { isGreek ? "Σωστή ταξινόμηση!" : "Great sorting!" }
    private var levelCompleteMessage: String { isGreek ? "Στην επόμενη πίστα εμφανίζονται 12 νέες φιγούρες." : "The next level brings 12 new figures." }
    private var nextLevelTitle: String { isGreek ? "Επόμενη πίστα" : "Next level" }
    private var finalMessage: String { isGreek ? "Ολοκλήρωσες και τα \(totalLevels) επίπεδα με δεινόσαυρους, ζώα, έντομα και μαγικά πλάσματα." : "You completed all \(totalLevels) levels with dinosaurs, animals, insects and magical creatures." }
    private var levelStars: Int { mistakes == 0 ? 3 : (mistakes <= 2 ? 2 : 1) }
    private var finalStars: Int { totalMistakes <= 3 ? 3 : (totalMistakes <= 8 ? 2 : 1) }

    private func pool() -> [SortCreature] {
        let values: [(String,String,String,Bool)] = [
            ("triceratops_rpg_neutral","Τρικεράτοπας","Triceratops",true),("stegosaurus_rpg_neutral","Στεγόσαυρος","Stegosaurus",true),("ankylosaurus_rpg_neutral","Αγκυλόσαυρος","Ankylosaurus",true),("parasaurolophus_rpg_neutral","Παρασαυρόλοφος","Parasaurolophus",true),("brachiosaurus_rpg_neutral","Βραχιόσαυρος","Brachiosaurus",true),("velociraptor_rpg_neutral","Βελοσιράπτορας","Velociraptor",true),("trex_rpg_neutral","Τυραννόσαυρος","T-Rex",true),("spinosaurus_rpg_neutral","Σπινόσαυρος","Spinosaurus",true),("pteranodon_rpg_neutral","Πτερανόδοντας","Pteranodon",true),("dilophosaurus_rpg_neutral","Διλοφόσαυρος","Dilophosaurus",true),("iguanodon_rpg_neutral","Ιγκουανόδοντας","Iguanodon",true),("pachycephalosaurus_rpg_neutral","Παχυκεφαλόσαυρος","Pachycephalosaurus",true),
            ("bear_rpg_neutral","Αρκούδα","Bear",true),("deer_rpg_neutral","Ελάφι","Deer",true),("hedgehog_rpg_neutral","Σκαντζόχοιρος","Hedgehog",false),("squirrel_rpg_neutral","Σκίουρος","Squirrel",false),("owl_rpg_neutral","Κουκουβάγια","Owl",false),("frog_rpg_neutral","Βάτραχος","Frog",false),("raccoon_rpg_neutral","Ρακούν","Raccoon",false),("badger_rpg_neutral","Ασβός","Badger",false),("beaver_rpg_neutral","Κάστορας","Beaver",false),("otter_rpg_neutral","Βίδρα","Otter",false),("turtle_rpg_neutral","Χελώνα","Turtle",false),("mouse_rpg_neutral","Ποντικάκι","Mouse",false),
            ("butterfly_rpg_neutral","Πεταλούδα","Butterfly",false),("bee_rpg_neutral","Μέλισσα","Bee",false),("ladybug_rpg_neutral","Πασχαλίτσα","Ladybug",false),("dragonfly_rpg_neutral","Λιβελούλα","Dragonfly",false),("grasshopper_rpg_neutral","Ακρίδα","Grasshopper",false),("snail_rpg_neutral","Σαλιγκάρι","Snail",false),("caterpillar_rpg_neutral","Κάμπια","Caterpillar",false),("firefly_rpg_neutral","Πυγολαμπίδα","Firefly",false),
            ("baby_dragon_rpg_neutral","Μικρός Δράκος","Baby Dragon",true),("pegasus_rpg_neutral","Πήγασος","Pegasus",true),("forest_fairy_rpg_neutral","Νεράιδα του Δάσους","Forest Fairy",false),("forest_spirit_rpg_neutral","Πνεύμα του Δάσους","Forest Spirit",true),("unicorn_rpg_happy","Μονόκερος","Unicorn",true)
        ]
        return values.enumerated().map { i,v in SortCreature(id:i,imageName:v.0,name:isGreek ? v.1:v.2,isBig:v.3) }
    }

    private func setupLevel() { creatures = Array(pool().shuffled().prefix(figuresPerLevel)).enumerated().map { offset,value in SortCreature(id:offset,imageName:value.imageName,name:value.name,isBig:value.isBig) }; selectedId=nil; mistakes=0; showLevelComplete=false }
    private func sortBin(title:String,emoji:String,isBig:Bool)->some View { Button(action:{sort(intoBig:isBig)}) { VStack(spacing:8){Text(emoji).font(.system(size:40));Text(title).font(.headline)}.frame(maxWidth:.infinity).padding(.vertical,20).frame(minHeight:PlayLandMetrics.primaryTouchTarget).background(PlayLandColors.warmCream).clipShape(RoundedRectangle(cornerRadius:PlayLandMetrics.cornerRadiusLarge)).shadow(color:.black.opacity(0.1),radius:3,y:2) }.disabled(selectedId==nil) }
    private func sort(intoBig big:Bool){ guard let selectedId,let index=creatures.firstIndex(where:{$0.id==selectedId}) else{return}; if creatures[index].isBig==big{creatures[index].sorted=true;AudioManager.shared.play(.correct)}else{mistakes+=1;totalMistakes+=1;AudioManager.shared.play(.wrong)};self.selectedId=nil;if creatures.allSatisfy({$0.sorted}){withAnimation{showLevelComplete=true}} }
    private func advanceLevel(){if level>=totalLevels{showLevelComplete=false;isFinished=true}else{level+=1;setupLevel()}}
}
