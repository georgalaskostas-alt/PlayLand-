import SwiftUI
import SpriteKit
import Combine
import UIKit

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
            setMessage(
                greek: "Ο στόχος της περιοχής ολοκληρώθηκε! Βρες το σεντούκι και άνοιξέ το.",
                english: "Area objective complete! Find the chest and open it."
            )
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
        setMessage(
            greek: "Μεγάλη αποστολή ολοκληρώθηκε! Ο Μπάμπης βοήθησε όλο το δάσος!",
            english: "Great quest complete! Babis helped the whole forest!"
        )
    }

    func setMessageForCurrentArea() {
        switch area {
        case .forest:
            setMessage(greek: "Αποστολή: μάζεψε 3 μήλα, 2 ξύλα και 1 νερό.", english: "Quest: collect 3 apples, 2 logs and 1 water.")
        case .village:
            setMessage(greek: "Αποστολή: βοήθησε το χωριό — βρες 2 μούρα, 1 καρότο και ακόμη 1 ξύλο.", english: "Quest: help the village — find 2 berries, 1 carrot and one more log.")
        case .crystalCave:
            setMessage(greek: "Αποστολή: βρες 3 κρυστάλλους και το κλειδί της σπηλιάς.", english: "Quest: find 3 crystals and the cave key.")
        case .nightForest:
            setMessage(greek: "Αποστολή: βρες 2 κομμάτια χάρτη και το Χρυσό Φτερό.", english: "Quest: find 2 map fragments and the Golden Feather.")
        case .foxArea:
            setMessage(greek: "Τελική αποστολή: βρες την αλεπού και μίλησέ της.", english: "Final quest: find the fox and talk to her.")
        }
    }

    func setMessage(greek: String, english: String) {
        message = isGreek ? greek : english
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
                RPGOrientation.request(.portrait)
            }
            .onChange(of: geometry.size) { newSize in
                scene?.size = newSize
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .statusBarHidden(true)
    }

    private var premiumHUD: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    playerCard
                    objectivePanel

                    Spacer(minLength: 10)

                    if !gameState.message.isEmpty {
                        Text(gameState.message)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .frame(maxWidth: 430)
                            .background(.black.opacity(0.54))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(.white.opacity(0.18), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }

                    Spacer(minLength: 10)

                    companionButton
                    miniMap
                    inventoryButton
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)

                Spacer()

                HStack(alignment: .bottom) {
                    RPGJoystick { vector in
                        scene?.setMovementVector(vector)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 10) {
                        Text(appSettings.resolvedLanguage == .greek ? "Κίνηση" : "Move")
                            .font(.caption2.weight(.black))
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.black.opacity(0.42))
                            .clipShape(Capsule())

                        if gameState.nearbyAction != nil {
                            interactionButton
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.75), value: gameState.nearbyAction)
        .allowsHitTesting(true)
    }

    private var playerCard: some View {
        HStack(spacing: 10) {
            Image(uiImage: UIImage(named: "babis_rpg_idle") ?? UIImage(named: "babis_neutral") ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(width: 62, height: 62)
                .padding(3)
                .background(
                    Circle()
                        .fill(.black.opacity(0.48))
                        .overlay(Circle().stroke(PlayLandColors.sunOrange, lineWidth: 2))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text("Babis")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text(gameState.currentAreaTitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.82))

                HStack(spacing: 5) {
                    Image(systemName: gameState.areaGoalComplete ? "checkmark.circle.fill" : "sparkles")
                        .foregroundStyle(gameState.areaGoalComplete ? PlayLandColors.leafGreen : PlayLandColors.sunOrange)
                    Text(gameState.areaGoalComplete
                         ? (gameState.isGreek ? "Στόχος έτοιμος" : "Goal ready")
                         : (gameState.isGreek ? "Σε αποστολή" : "On quest"))
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .background(.black.opacity(0.55))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var objectivePanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(gameState.isGreek ? "ΑΠΟΣΤΟΛΗ" : "QUEST")
                .font(.caption2.weight(.black))
                .foregroundStyle(.white.opacity(0.78))

            HStack(spacing: 6) {
                ForEach(Array(gameState.objectiveItems.enumerated()), id: \.offset) { _, item in
                    objectiveChip(
                        icon: item.0,
                        value: "\(min(item.1, item.2))/\(item.2)",
                        complete: item.1 >= item.2
                    )
                }
            }
        }
        .padding(10)
        .background(.black.opacity(0.48))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var miniMap: some View {
        ZStack {
            Image(gameState.area.groundAsset)
                .resizable()
                .scaledToFill()
                .frame(width: 82, height: 82)
                .clipShape(Circle())

            Circle()
                .stroke(PlayLandColors.sunOrange, lineWidth: 3)
                .frame(width: 82, height: 82)

            Image(systemName: "location.north.fill")
                .font(.title3.weight(.black))
                .foregroundStyle(.white)
                .shadow(color: .black, radius: 3)
        }
        .accessibilityLabel(gameState.isGreek ? "Μίνι χάρτης" : "Mini map")
    }

    private var companionButton: some View {
        Button {
            scene?.talkToCompanion()
        } label: {
            Image(uiImage: UIImage(named: "kotsifi_rpg_idle") ?? UIImage(named: "kotsifi_idle") ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .padding(6)
                .background(.black.opacity(0.5))
                .clipShape(Circle())
                .overlay(Circle().stroke(.white.opacity(0.22), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(gameState.isGreek ? "Μίλα στο Κοτσύφι" : "Talk to Kotsifi")
    }

    private var inventoryButton: some View {
        Button {
            withAnimation { showInventory.toggle() }
        } label: {
            Image(systemName: "backpack.fill")
                .font(.title3.weight(.black))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(.black.opacity(0.52))
                .clipShape(Circle())
                .overlay(Circle().stroke(.white.opacity(0.18), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(gameState.isGreek ? "Σακίδιο" : "Inventory")
    }

    private var interactionButton: some View {
        Button {
            scene?.performInteraction()
        } label: {
            VStack(spacing: 5) {
                Image(systemName: gameState.interactionIcon)
                    .font(.system(size: 27, weight: .black))
                Text(gameState.interactionTitle)
                    .font(.caption.weight(.black))
                    .lineLimit(1)
            }
            .foregroundStyle(.white)
            .frame(width: 96, height: 96)
            .background(
                Circle()
                    .fill(PlayLandColors.sunOrange.opacity(0.94))
                    .shadow(color: .black.opacity(0.35), radius: 8, y: 4)
            )
            .overlay(Circle().stroke(.white.opacity(0.65), lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    private var inventoryPanel: some View {
        ZStack(alignment: .trailing) {
            Color.black.opacity(0.46)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { showInventory = false } }

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label(gameState.isGreek ? "Σακίδιο" : "Inventory", systemImage: "backpack.fill")
                        .font(.title2.weight(.black))
                    Spacer()
                    Button {
                        withAnimation { showInventory = false }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                    }
                }

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 10
                ) {
                    ForEach(Array(gameState.inventoryItems.enumerated()), id: \.offset) { _, item in
                        VStack(spacing: 4) {
                            AppAssets.image(item.0)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 42)

                            Text("×\(item.2)")
                                .font(.headline.monospacedDigit())

                            Text(item.1)
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
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
            .shadow(color: .black.opacity(0.35), radius: 18, x: -4)
            .padding(.vertical, 14)
            .padding(.trailing, 14)
        }
    }

    private func objectiveChip(icon: String, value: String, complete: Bool) -> some View {
        HStack(spacing: 3) {
            Text(icon)
            Text(value)
                .font(.caption.weight(.black).monospacedDigit())
                .foregroundStyle(.white)

            if complete {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(PlayLandColors.leafGreen)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.white.opacity(0.12))
        .clipShape(Capsule())
    }
}

private struct RPGJoystick: View {
    let onVectorChanged: (CGVector) -> Void

    @State private var knobOffset: CGSize = .zero

    private let diameter: CGFloat = 120
    private let knobDiameter: CGFloat = 54

    var body: some View {
        ZStack {
            Circle()
                .fill(.black.opacity(0.42))
                .overlay(Circle().stroke(.white.opacity(0.22), lineWidth: 2))

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
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.72)) {
                        knobOffset = .zero
                    }
                    onVectorChanged(.zero)
                }
        )
        .accessibilityLabel("Movement joystick")
    }
}

private enum RPGOrientation {
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