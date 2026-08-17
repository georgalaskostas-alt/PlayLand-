import SwiftUI
import SpriteKit
import Combine

enum RPGArea: Int, CaseIterable {
    case forest, village, crystalCave, nightForest, foxArea

    var groundAsset: String {
        switch self {
        case .forest: return "rpg_forest_ground_01"
        case .village: return "rpg_village_ground"
        case .crystalCave: return "rpg_crystal_cave_ground"
        case .nightForest: return "rpg_night_forest_ground"
        case .foxArea: return "rpg_fox_area_ground"
        }
    }

    var completionId: String {
        switch self {
        case .forest: return "rpg_area_forest"
        case .village: return "rpg_area_village"
        case .crystalCave: return "rpg_area_crystal_cave"
        case .nightForest: return "rpg_area_night_forest"
        case .foxArea: return "rpg_finale"
        }
    }
}

enum RPGNearbyAction: Equatable {
    case kotsifi
    case exit
    case fox
}

final class RPGGameState: ObservableObject {
    @Published var area: RPGArea = .forest
    @Published var apples = 0
    @Published var wood = 0
    @Published var water = 0
    @Published var berries = 0
    @Published var carrots = 0
    @Published var crystals = 0
    @Published var keys = 0
    @Published var fragments = 0
    @Published var goldenFeathers = 0
    @Published var questComplete = false
    @Published var message = ""
    @Published var nearbyAction: RPGNearbyAction?

    private weak var progress: ProgressViewModel?
    var isGreek: Bool { AppSettings.shared.resolvedLanguage == .greek }

    func attach(progress: ProgressViewModel) {
        self.progress = progress
        apples = progress.itemCount("apple_item")
        wood = progress.itemCount("log")
        water = progress.itemCount("water_item")
        berries = progress.itemCount("berries_item")
        carrots = progress.itemCount("carrot_item")
        crystals = progress.itemCount("crystal_item")
        keys = progress.itemCount("key_item")
        fragments = progress.itemCount("map_fragment")
        goldenFeathers = progress.itemCount("golden_feather")
        questComplete = progress.isChallengeCompleted(RPGArea.foxArea.completionId)

        if progress.isChallengeCompleted(RPGArea.nightForest.completionId) { area = .foxArea }
        else if progress.isChallengeCompleted(RPGArea.crystalCave.completionId) { area = .nightForest }
        else if progress.isChallengeCompleted(RPGArea.village.completionId) { area = .crystalCave }
        else if progress.isChallengeCompleted(RPGArea.forest.completionId) { area = .village }
        else { area = .forest }
    }

    var currentAreaTitle: String {
        switch area {
        case .forest: return isGreek ? "Δάσος" : "Forest"
        case .village: return isGreek ? "Χωριό" : "Village"
        case .crystalCave: return isGreek ? "Κρυστάλλινη Σπηλιά" : "Crystal Cave"
        case .nightForest: return isGreek ? "Νυχτερινό Δάσος" : "Night Forest"
        case .foxArea: return isGreek ? "Περιοχή της Αλεπούς" : "Fox Area"
        }
    }

    var objectiveItems: [(String, Int, Int)] {
        switch area {
        case .forest: return [("🍎", apples, 3), ("🪵", wood, 2), ("💧", water, 1)]
        case .village: return [("🫐", berries, 2), ("🥕", carrots, 1), ("🪵", wood, 3)]
        case .crystalCave: return [("💎", crystals, 3), ("🗝️", keys, 1)]
        case .nightForest: return [("🗺️", fragments, 2), ("⭐", goldenFeathers, 1)]
        case .foxArea: return [("🦊", questComplete ? 1 : 0, 1)]
        }
    }

    var inventoryItems: [(String, String, Int)] {
        [
            ("apple_item", isGreek ? "Μήλα" : "Apples", apples),
            ("log", isGreek ? "Ξύλα" : "Logs", wood),
            ("water_item", isGreek ? "Νερό" : "Water", water),
            ("berries_item", isGreek ? "Μούρα" : "Berries", berries),
            ("carrot_item", isGreek ? "Καρότα" : "Carrots", carrots),
            ("crystal_item", isGreek ? "Κρύσταλλοι" : "Crystals", crystals),
            ("key_item", isGreek ? "Κλειδιά" : "Keys", keys),
            ("map_fragment", isGreek ? "Χάρτης" : "Map pieces", fragments),
            ("golden_feather", isGreek ? "Χρυσά Φτερά" : "Golden feathers", goldenFeathers)
        ]
    }

    var areaGoalComplete: Bool {
        switch area {
        case .forest: return apples >= 3 && wood >= 2 && water >= 1
        case .village: return berries >= 2 && carrots >= 1 && wood >= 3
        case .crystalCave: return crystals >= 3 && keys >= 1
        case .nightForest: return fragments >= 2 && goldenFeathers >= 1
        case .foxArea: return questComplete
        }
    }

    var interactionTitle: String {
        switch nearbyAction {
        case .kotsifi: return isGreek ? "Μίλα" : "Talk"
        case .exit: return areaGoalComplete ? (isGreek ? "Άνοιξε" : "Open") : (isGreek ? "Έλεγξε" : "Check")
        case .fox: return isGreek ? "Μίλα στην Αλεπού" : "Talk to Fox"
        case .none: return ""
        }
    }

    var interactionIcon: String {
        switch nearbyAction {
        case .kotsifi: return "bubble.left.fill"
        case .exit: return "lock.open.fill"
        case .fox: return "bubble.left.and.bubble.right.fill"
        case .none: return "hand.tap.fill"
        }
    }

    func collect(kind: String) {
        let itemId: String
        switch kind {
        case "apple": apples += 1; itemId = "apple_item"
        case "wood": wood += 1; itemId = "log"
        case "water": water += 1; itemId = "water_item"
        case "berries": berries += 1; itemId = "berries_item"
        case "carrot": carrots += 1; itemId = "carrot_item"
        case "crystal": crystals += 1; itemId = "crystal_item"
        case "key": keys += 1; itemId = "key_item"
        case "fragment": fragments += 1; itemId = "map_fragment"
        case "feather": goldenFeathers += 1; itemId = "golden_feather"
        default: return
        }
        progress?.collectItem(itemId)
        AudioManager.shared.play(.correct)
        if areaGoalComplete && area != .foxArea {
            setMessage(greek: "Ο στόχος της περιοχής ολοκληρώθηκε! Βρες το σεντούκι και άνοιξέ το.", english: "Area objective complete! Find the chest and open it.")
        }
    }

    func advanceArea() {
        guard area != .foxArea, let next = RPGArea(rawValue: area.rawValue + 1) else { return }
        progress?.completeChallenge(area.completionId, rewardStars: 2)
        nearbyAction = nil
        area = next
        setMessageForCurrentArea()
    }

    func completeQuest() {
        questComplete = true
        nearbyAction = nil
        progress?.completeChallenge(RPGArea.foxArea.completionId, rewardStars: 5)
        AudioManager.shared.play(.storyNext)
        setMessage(greek: "Μεγάλη αποστολή ολοκληρώθηκε! Ο Μπάμπης βοήθησε όλο το δάσος!", english: "Great quest complete! Babis helped the whole forest!")
    }

    func setMessageForCurrentArea() {
        switch area {
        case .forest: setMessage(greek: "Αποστολή: μάζεψε 3 μήλα, 2 ξύλα και 1 νερό.", english: "Quest: collect 3 apples, 2 logs and 1 water.")
        case .village: setMessage(greek: "Αποστολή: βοήθησε το χωριό — βρες 2 μούρα, 1 καρότο και ακόμη 1 ξύλο.", english: "Quest: help the village — find 2 berries, 1 carrot and one more log.")
        case .crystalCave: setMessage(greek: "Αποστολή: βρες 3 κρυστάλλους και το κλειδί της σπηλιάς.", english: "Quest: find 3 crystals and the cave key.")
        case .nightForest: setMessage(greek: "Αποστολή: βρες 2 κομμάτια χάρτη και το Χρυσό Φτερό.", english: "Quest: find 2 map fragments and the Golden Feather.")
        case .foxArea: setMessage(greek: "Τελική αποστολή: βρες την αλεπού και μίλησέ της.", english: "Final quest: find the fox and talk to her.")
        }
    }

    func setMessage(greek: String, english: String) { message = isGreek ? greek : english }
}

struct BabisRPGGameView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var progressManager: ProgressViewModel
    @StateObject private var gameState = RPGGameState()
    @State private var scene: BabisRPGScene?
    @State private var showInventory = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if let scene {
                    SpriteView(scene: scene, options: [.allowsTransparency])
                        .ignoresSafeArea()
                } else {
                    Color.black.ignoresSafeArea()
                }

                VStack(spacing: 8) {
                    HStack {
                        Text(gameState.currentAreaTitle)
                            .font(.headline.weight(.bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())

                        Spacer()

                        Button {
                            withAnimation { showInventory.toggle() }
                        } label: {
                            Image(systemName: "backpack.fill")
                                .font(.title3.weight(.bold))
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .accessibilityLabel(appSettings.resolvedLanguage == .greek ? "Σακίδιο" : "Inventory")
                    }

                    HStack(spacing: 8) {
                        ForEach(Array(gameState.objectiveItems.enumerated()), id: \.offset) { _, item in
                            objectiveChip(icon: item.0, value: "\(min(item.1, item.2))/\(item.2)", complete: item.1 >= item.2)
                        }
                        Spacer()
                    }

                    if !gameState.message.isEmpty {
                        Text(gameState.message)
                            .font(.subheadline.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .frame(maxWidth: 620)
                    }

                    Spacer()

                    HStack(alignment: .bottom) {
                        Text(appSettings.resolvedLanguage == .greek ? "Άγγιξε το έδαφος για κίνηση" : "Tap the ground to move")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())

                        Spacer()

                        if gameState.nearbyAction != nil {
                            Button {
                                scene?.performInteraction()
                            } label: {
                                HStack(spacing: 7) {
                                    Image(systemName: gameState.interactionIcon)
                                    Text(gameState.interactionTitle)
                                }
                                .font(.headline.weight(.bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .frame(minHeight: 50)
                                .background(PlayLandColors.sunOrange)
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.25), radius: 5, y: 3)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.bottom, 12)
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)

                if showInventory {
                    inventoryPanel
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        .zIndex(30)
                }
            }
            .onAppear {
                if scene == nil {
                    gameState.attach(progress: progressManager)
                    gameState.setMessageForCurrentArea()
                    scene = BabisRPGScene(size: geometry.size, gameState: gameState)
                }
            }
            .onChange(of: geometry.size) { newSize in
                scene?.size = newSize
            }
        }
        .navigationTitle(appSettings.resolvedLanguage == .greek ? "Η Περιπέτεια του Μπάμπη" : "Babis Adventure")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var inventoryPanel: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.opacity(0.28)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { showInventory = false } }

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label(appSettings.resolvedLanguage == .greek ? "Σακίδιο" : "Inventory", systemImage: "backpack.fill")
                        .font(.title2.weight(.bold))
                    Spacer()
                    Button {
                        withAnimation { showInventory = false }
                    } label: {
                        Image(systemName: "xmark.circle.fill").font(.title2)
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(Array(gameState.inventoryItems.enumerated()), id: \.offset) { _, item in
                        VStack(spacing: 5) {
                            AppAssets.image(item.0)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 48)
                            Text("×\(item.2)")
                                .font(.headline.monospacedDigit())
                            Text(item.1)
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, minHeight: 98)
                        .padding(8)
                        .background(PlayLandColors.warmCream.opacity(0.95))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: 390)
            .background(.ultraThickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
            .padding(16)
        }
    }

    private func objectiveChip(icon: String, value: String, complete: Bool) -> some View {
        HStack(spacing: 4) {
            Text(icon)
            Text(value).font(.subheadline.weight(.bold).monospacedDigit())
            if complete {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(PlayLandColors.leafGreen)
            }
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}
