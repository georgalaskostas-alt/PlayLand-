import SpriteKit
import UIKit

final class BabisRPGScene: SKScene {
    private enum MovementState { case idle, walking, running }

    private let gameState: RPGGameState
    private let player = SKSpriteNode()
    private let companion = SKSpriteNode()
    private let world = SKNode()
    private let cameraNode = SKCameraNode()

    private let worldSize = CGSize(width: 4200, height: 2800)
    private let pathHalfWidth: CGFloat = 135

    private var joystickVector = CGVector.zero
    private var joystickMagnitude: CGFloat = 0
    private var lastUpdateTime: TimeInterval = 0
    private var animationTime: TimeInterval = 0
    private var companionAnimationTime: TimeInterval = 0
    private var animationFrame = 0
    private var companionFrame = 0
    private var movementState: MovementState = .idle
    private var facingAway = false
    private var pathQueue: [CGPoint] = []
    private var interactionNodes: [SKSpriteNode] = []
    private var collectibleNodes: [SKSpriteNode] = []
    private weak var nearbyInteractionNode: SKSpriteNode?
    private weak var activeChallengeNode: SKSpriteNode?
    private weak var pinchGesture: UIPinchGestureRecognizer?
    private var isTransitioning = false

    private let minCameraScale: CGFloat = 0.42
    private let maxCameraScale: CGFloat = 1.35

    private lazy var idleTexture = texture(named: "babis_rpg_idle", fallback: "babis_rpg_master")
    private lazy var backIdleTexture = texture(named: "babis_rpg_back_idle", fallback: "babis_rpg_idle")
    private lazy var walkTextures: [SKTexture] = (1...4).map { texture(named: String(format: "babis_rpg_walk_%02d", $0), fallback: "babis_rpg_idle") }
    private lazy var runTextures: [SKTexture] = (1...4).map { texture(named: String(format: "babis_rpg_run_%02d", $0), fallback: "babis_rpg_idle") }
    private lazy var backWalkTextures: [SKTexture] = (1...4).map { texture(named: String(format: "babis_rpg_back_walk_%02d", $0), fallback: "babis_rpg_walk_01") }
    private lazy var backRunTextures: [SKTexture] = (1...4).map { texture(named: String(format: "babis_rpg_back_run_%02d", $0), fallback: "babis_rpg_run_01") }

    private lazy var companionIdleTexture = texture(named: "kotsifi_rpg_idle", fallback: "kotsifi_rpg_master")
    private lazy var companionBackIdleTexture = texture(named: "kotsifi_rpg_back_idle", fallback: "kotsifi_rpg_idle")
    private lazy var companionFlyTextures: [SKTexture] = (1...4).map { texture(named: String(format: "kotsifi_rpg_fly_%02d", $0), fallback: "kotsifi_rpg_idle") }
    private lazy var companionBackFlyTextures: [SKTexture] = (1...4).map { texture(named: String(format: "kotsifi_rpg_back_fly_%02d", $0), fallback: "kotsifi_rpg_fly_01") }

    // One continuous, hand-authored route through each large map. Every interactive
    // element is placed on or beside this route, and player movement is constrained
    // to its corridor. This prevents walking through trees, bushes and scenery.
    private let routePoints: [CGPoint] = [
        .init(x: 520, y: 430), .init(x: 820, y: 520), .init(x: 1110, y: 690), .init(x: 1390, y: 560),
        .init(x: 1670, y: 760), .init(x: 1940, y: 960), .init(x: 2240, y: 800), .init(x: 2530, y: 1010),
        .init(x: 2820, y: 1240), .init(x: 3130, y: 1090), .init(x: 3420, y: 1320), .init(x: 3710, y: 1540),
        .init(x: 3540, y: 1830), .init(x: 3260, y: 2070), .init(x: 2960, y: 2250), .init(x: 2650, y: 2110),
        .init(x: 2370, y: 2330), .init(x: 2070, y: 2160), .init(x: 1770, y: 2360), .init(x: 1460, y: 2180),
        .init(x: 1170, y: 2390), .init(x: 880, y: 2200), .init(x: 620, y: 2380), .init(x: 500, y: 2050),
        .init(x: 760, y: 1780), .init(x: 1040, y: 1580), .init(x: 1340, y: 1750), .init(x: 1630, y: 1510),
        .init(x: 1920, y: 1690), .init(x: 2210, y: 1510), .init(x: 2500, y: 1740), .init(x: 2800, y: 1880)
    ]

    init(size: CGSize, gameState: RPGGameState) {
        self.gameState = gameState
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = UIColor(red: 0.07, green: 0.12, blue: 0.07, alpha: 1)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func didMove(to view: SKView) {
        guard world.parent == nil else { return }
        view.isMultipleTouchEnabled = true
        addChild(world)
        camera = cameraNode
        addChild(cameraNode)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinch.cancelsTouchesInView = false
        view.addGestureRecognizer(pinch)
        pinchGesture = pinch

        AudioManager.shared.playLoop(named: "rpg_adventure_theme", volume: 0.24)
        loadArea(gameState.area)
    }

    override func willMove(from view: SKView) {
        if let pinchGesture { view.removeGestureRecognizer(pinchGesture) }
        AudioManager.shared.stopMusic()
        SpeechManager.shared.stop()
    }

    // MARK: - Controls

    func setMovementVector(_ vector: CGVector) {
        let magnitude = min(1, hypot(vector.dx, vector.dy))
        joystickMagnitude = magnitude
        if magnitude < 0.04 {
            joystickVector = .zero
        } else {
            joystickVector = CGVector(dx: vector.dx / magnitude, dy: vector.dy / magnitude)
            pathQueue.removeAll()
        }
    }

    func stopMovement() {
        joystickVector = .zero
        joystickMagnitude = 0
        pathQueue.removeAll()
        setMovementState(.idle)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isTransitioning, joystickMagnitude < 0.04, let touch = touches.first else { return }
        let tapped = touch.location(in: world)
        let target = nearestPointOnRoute(to: tapped)
        buildRoute(from: player.position, to: target)
    }

    func talkToCompanion() {
        guard !isTransitioning else { return }
        let messages: [(String, String)] = [
            ("Ακολούθησε το μονοπάτι. Αν πατήσεις πιο μακριά, θα σε οδηγήσω από τον ασφαλή δρόμο.", "Follow the path. If you tap farther away, I will guide you along the safe route."),
            ("Ψάξε και τις στροφές του δρόμου. Οι φίλοι και τα αντικείμενα βρίσκονται κοντά στα μονοπάτια.", "Check the bends in the road too. Friends and items are placed near the paths."),
            ("Μην προσπαθείς να περάσεις μέσα από δέντρα και θάμνους — το μονοπάτι είναι πάντα η σωστή διαδρομή.", "Do not try to walk through trees and bushes — the path is always the safe route.")
        ]
        let pair = messages[gameState.area.rawValue % messages.count]
        gameState.setMessage(greek: pair.0, english: pair.1)
        SpeechManager.shared.speak(text: gameState.message)
        AudioManager.shared.play(.storyNext)
    }

    func performInteraction() {
        guard !isTransitioning, let node = nearbyInteractionNode, let name = node.name else { return }
        stopMovement()

        if name.hasPrefix("puzzle:") {
            let parts = name.split(separator: ":")
            guard parts.count >= 2, let challenge = RPGChallenge(rawValue: String(parts[1])) else { return }
            activeChallengeNode = node
            gameState.requestChallenge(challenge)
            return
        }

        if name.hasPrefix("treasure:") { openTreasure(node); return }
        if name.hasPrefix("npc:") { interactWithAnimal(node); return }

        switch name {
        case "unicorn:worried":
            gameState.helpUnicorn()
            node.texture = SKTexture(imageNamed: "unicorn_rpg_happy")
            node.name = "unicorn:happy"
            showHeart(over: node, symbol: "✨")
            SpeechManager.shared.speak(text: gameState.message)
        case "unicorn:happy":
            node.texture = SKTexture(imageNamed: "unicorn_rpg_talking")
            gameState.setMessage(greek: "Σε ευχαριστώ! Η μαγεία μου επέστρεψε. Συνέχισε από το μονοπάτι!", english: "Thank you! My magic is back. Keep following the path!")
            SpeechManager.shared.speak(text: gameState.message)
            returnTexture(node, asset: "unicorn_rpg_happy")
        case "fox":
            gameState.meetFox()
            node.texture = texture(named: "fox_talking", fallback: "fox_friendly")
            SpeechManager.shared.speak(text: gameState.message)
        case "area_exit":
            guard gameState.areaGoalComplete else {
                AudioManager.shared.play(.wrong)
                gameState.setMessage(greek: "Υπάρχουν ακόμη στόχοι στην περιοχή. Ακολούθησε όλο το μονοπάτι και έλεγξε τις διακλαδώσεις.", english: "There are still objectives here. Follow the whole path and check every branch.")
                SpeechManager.shared.speak(text: gameState.message)
                return
            }
            isTransitioning = true
            let finishing = gameState.area == .foxDen
            gameState.advanceArea()
            if finishing {
                node.texture = SKTexture(imageNamed: "rpg_chest_crystal_open")
                isTransitioning = false
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { [weak self] in
                    guard let self else { return }
                    self.loadArea(self.gameState.area)
                }
            }
        default: break
        }
    }

    func completeActiveChallenge() {
        guard let node = activeChallengeNode else { return }
        node.texture = SKTexture(imageNamed: "rpg_chest_magic_open")
        node.name = "puzzle:solved"
        interactionNodes.removeAll { $0 === node }
        activeChallengeNode = nil
        nearbyInteractionNode = nil
        gameState.nearbyAction = nil
        showRewardBurst(at: node.position, asset: "rpg_treasure_gems")
    }

    // MARK: - Camera

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard !isTransitioning else { return }
        if gesture.state == .began || gesture.state == .changed {
            let proposed = cameraNode.xScale / gesture.scale
            cameraNode.setScale(min(maxCameraScale, max(minCameraScale, proposed)))
            gesture.scale = 1
            clampCameraToWorld()
        }
    }

    private func clampCameraToWorld() {
        let halfW = min(worldSize.width / 2, size.width * cameraNode.xScale / 2)
        let halfH = min(worldSize.height / 2, size.height * cameraNode.yScale / 2)
        cameraNode.position.x = min(worldSize.width - halfW, max(halfW, cameraNode.position.x))
        cameraNode.position.y = min(worldSize.height - halfH, max(halfH, cameraNode.position.y))
    }

    // MARK: - World

    private func loadArea(_ area: RPGArea) {
        isTransitioning = true
        stopMovement()
        world.removeAllChildren()
        interactionNodes.removeAll()
        collectibleNodes.removeAll()
        nearbyInteractionNode = nil
        activeChallengeNode = nil
        gameState.nearbyAction = nil

        let background = SKSpriteNode(imageNamed: backgroundAsset(for: area))
        background.size = worldSize
        background.position = CGPoint(x: worldSize.width / 2, y: worldSize.height / 2)
        background.zPosition = -3000
        world.addChild(background)

        addRenderedPath()
        addEnvironment(for: area)
        buildArea(area)

        setupPlayer(at: routePoints[0])
        setupCompanion()
        cameraNode.setScale(0.88)
        cameraNode.position = player.position
        clampCameraToWorld()
        gameState.setMessageForCurrentArea()
        isTransitioning = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            guard let self else { return }
            SpeechManager.shared.speak(text: self.gameState.message)
        }
    }

    private func backgroundAsset(for area: RPGArea) -> String {
        switch area {
        case .forest, .rescueClearing, .unicornGrove, .treasureClearing:
            return UIImage(named: "rpg_forest_ground_01") != nil ? "rpg_forest_ground_01" : area.groundAsset
        case .village: return "rpg_village_ground"
        case .riverCrossing: return UIImage(named: "rpg_forest_ground_01") != nil ? "rpg_forest_ground_01" : area.groundAsset
        case .puzzleClearing: return UIImage(named: "rpg_forest_ground_01") != nil ? "rpg_forest_ground_01" : area.groundAsset
        case .crystalCave: return "rpg_crystal_cave_ground"
        case .nightForest: return "rpg_night_forest_ground"
        case .foxDen: return UIImage(named: "rpg_fox_area_ground") != nil ? "rpg_fox_area_ground" : area.groundAsset
        }
    }

    private func addRenderedPath() {
        for index in 0..<(routePoints.count - 1) {
            let a = routePoints[index]
            let b = routePoints[index + 1]
            let dx = b.x - a.x
            let dy = b.y - a.y
            let distance = hypot(dx, dy)
            let angle = atan2(dy, dx)
            let steps = max(1, Int(distance / 150))
            for step in 0...steps {
                let t = CGFloat(step) / CGFloat(steps)
                let point = CGPoint(x: a.x + dx * t, y: a.y + dy * t)
                let path = SKSpriteNode(imageNamed: "rpg_path_straight")
                path.size = CGSize(width: 190, height: 125)
                path.position = point
                path.zRotation = angle
                path.zPosition = -1800
                path.alpha = 0.96
                world.addChild(path)
            }
        }
        for index in stride(from: 4, to: routePoints.count, by: 5) {
            let junction = SKSpriteNode(imageNamed: "rpg_path_junction")
            junction.size = CGSize(width: 210, height: 180)
            junction.position = routePoints[index]
            junction.zPosition = -1750
            world.addChild(junction)
        }
    }

    private func addEnvironment(for area: RPGArea) {
        let treeAssets = ["rpg_tree_large_01", "rpg_tree_large_02", "rpg_tree_large_03"]
        let candidates: [CGPoint] = [
            .init(x: 420, y: 1050), .init(x: 840, y: 1180), .init(x: 1330, y: 1040), .init(x: 1840, y: 1180),
            .init(x: 2420, y: 520), .init(x: 3010, y: 650), .init(x: 3650, y: 820), .init(x: 3910, y: 1220),
            .init(x: 3820, y: 2120), .init(x: 3410, y: 2440), .init(x: 2780, y: 2580), .init(x: 2150, y: 2580),
            .init(x: 1580, y: 2590), .init(x: 990, y: 2620), .init(x: 360, y: 2460), .init(x: 330, y: 1640)
        ]
        for (i, p) in candidates.enumerated() where distanceToRoute(p) > 260 {
            addScenery(asset: treeAssets[i % treeAssets.count], at: p, size: CGSize(width: 330, height: 420))
        }

        let bushCandidates: [CGPoint] = [
            .init(x: 1150, y: 1110), .init(x: 1530, y: 1260), .init(x: 2550, y: 620), .init(x: 3290, y: 760),
            .init(x: 3740, y: 2370), .init(x: 3150, y: 2570), .init(x: 1940, y: 2570), .init(x: 720, y: 2570)
        ]
        for (i, p) in bushCandidates.enumerated() where distanceToRoute(p) > 220 {
            addScenery(asset: i.isMultiple(of: 2) ? "rpg_bush_tall_01" : "rpg_bush_tall_02", at: p, size: CGSize(width: 220, height: 190))
        }

        if area == .village {
            addScenery(asset: "rpg_village_house_01", at: CGPoint(x: 850, y: 1250), size: CGSize(width: 620, height: 560))
            addScenery(asset: "rpg_village_house_02", at: CGPoint(x: 3350, y: 730), size: CGSize(width: 650, height: 570))
        }
        if area == .riverCrossing {
            let bridge = SKSpriteNode(imageNamed: "rpg_bridge_wood")
            bridge.position = routePoints[16]
            bridge.size = CGSize(width: 520, height: 260)
            bridge.zPosition = -1650
            world.addChild(bridge)
        }
    }

    private func addScenery(asset: String, at position: CGPoint, size: CGSize) {
        let node = SKSpriteNode(imageNamed: asset)
        node.size = size
        node.position = position
        node.zPosition = depth(forY: position.y)
        world.addChild(node)
    }

    private func buildArea(_ area: RPGArea) {
        switch area {
        case .forest:
            addCollectibles(kind: "apple", asset: "apple_item", count: 12, start: 1, step: 2, size: 72)
            addCollectibles(kind: "wood", asset: "log", count: 8, start: 3, step: 3, size: 82)
            addCollectibles(kind: "water", asset: "water_item", count: 6, start: 5, step: 4, size: 70)
            addAnimal(kind: "rabbit", worried: "rabbit_rpg_worried", index: 20, size: 165)
            addPuzzle(.memory, index: 11)
            addExit(index: 30, asset: "rpg_chest_wood_closed")
        case .rescueClearing:
            addCollectibles(kind: "berries", asset: "berries_item", count: 12, start: 2, step: 2, size: 70)
            addCollectibles(kind: "carrot", asset: "carrot_item", count: 10, start: 4, step: 3, size: 70)
            addAnimal(kind: "hedgehog", worried: "hedgehog_rpg_worried", index: 18, size: 160)
            addAnimal(kind: "deer", worried: "deer_rpg_worried", index: 28, size: 180)
            addPuzzle(.shapes, index: 10)
            addTreasure(style: "wood", index: 24, id: 1)
            addExit(index: 31, asset: "rpg_chest_wood_closed")
        case .village:
            addCollectibles(kind: "wood", asset: "log", count: 12, start: 1, step: 2, size: 82)
            addCollectibles(kind: "berries", asset: "berries_item", count: 10, start: 7, step: 3, size: 68)
            addCollectibles(kind: "carrot", asset: "carrot_item", count: 10, start: 4, step: 3, size: 68)
            addAnimal(kind: "squirrel", worried: "squirrel_rpg_worried", index: 17, size: 160)
            addTreasure(style: "wood", index: 24, id: 1)
            addExit(index: 31, asset: "rpg_chest_magic_closed")
        case .riverCrossing:
            addCollectibles(kind: "water", asset: "water_item", count: 12, start: 1, step: 2, size: 70)
            addCollectibles(kind: "wood", asset: "log", count: 10, start: 6, step: 3, size: 82)
            addCollectibles(kind: "key", asset: "key_item", count: 3, start: 13, step: 7, size: 68)
            addAnimal(kind: "deer", worried: "deer_rpg_worried", index: 20, size: 180)
            addPuzzle(.numbers, index: 15)
            addExit(index: 31, asset: "rpg_chest_magic_closed")
        case .puzzleClearing:
            addCollectibles(kind: "crystal", asset: "crystal_item", count: 10, start: 1, step: 3, size: 74)
            addCollectibles(kind: "key", asset: "key_item", count: 5, start: 5, step: 6, size: 68)
            addPuzzle(.memory, index: 7)
            addPuzzle(.numbers, index: 15)
            addPuzzle(.shapes, index: 25)
            addTreasure(style: "wood", index: 20, id: 1)
            addTreasure(style: "magic", index: 29, id: 2)
            addExit(index: 31, asset: "rpg_chest_magic_closed")
        case .crystalCave:
            addCollectibles(kind: "crystal", asset: "crystal_item", count: 18, start: 0, step: 2, size: 76)
            addCollectibles(kind: "key", asset: "key_item", count: 6, start: 7, step: 5, size: 68)
            addAnimal(kind: "hedgehog", worried: "hedgehog_rpg_worried", index: 21, size: 160)
            addPuzzle(.words, index: 8)
            addPuzzle(.shapes, index: 24)
            addTreasure(style: "crystal", index: 29, id: 1)
            addExit(index: 31, asset: "rpg_chest_crystal_closed")
        case .nightForest:
            addCollectibles(kind: "fragment", asset: "map_fragment", count: 12, start: 1, step: 2, size: 74)
            addCollectibles(kind: "feather", asset: "golden_feather", count: 8, start: 8, step: 3, size: 70)
            addAnimal(kind: "squirrel", worried: "squirrel_rpg_worried", index: 18, size: 160)
            addAnimal(kind: "owl", worried: "owl_rpg_neutral", index: 27, size: 160)
            addPuzzle(.memory, index: 15)
            addExit(index: 31, asset: "rpg_chest_magic_closed")
        case .unicornGrove:
            addCollectibles(kind: "crystal", asset: "crystal_item", count: 12, start: 0, step: 2, size: 76)
            addCollectibles(kind: "fragment", asset: "map_fragment", count: 7, start: 7, step: 4, size: 74)
            addPuzzle(.numbers, index: 8)
            addPuzzle(.words, index: 24)
            addTreasure(style: "magic", index: 29, id: 1)
            addNPC(asset: "unicorn_rpg_worried", name: "unicorn:worried", index: 20, size: 210, action: .unicorn)
            addExit(index: 31, asset: "rpg_chest_magic_closed")
        case .treasureClearing:
            addCollectibles(kind: "key", asset: "key_item", count: 8, start: 2, step: 3, size: 70)
            addCollectibles(kind: "crystal", asset: "crystal_item", count: 12, start: 1, step: 2, size: 76)
            addPuzzle(.shapes, index: 8)
            addPuzzle(.numbers, index: 24)
            addTreasure(style: "wood", index: 17, id: 1)
            addTreasure(style: "magic", index: 22, id: 2)
            addTreasure(style: "crystal", index: 29, id: 3)
            addExit(index: 31, asset: "rpg_chest_crystal_closed")
        case .foxDen:
            addPuzzle(.words, index: 8)
            addTreasure(style: "crystal", index: 26, id: 1)
            addNPC(asset: "fox_friendly", name: "fox", index: 20, size: 190, action: .fox)
            addExit(index: 31, asset: "rpg_chest_crystal_closed")
        }
    }

    // MARK: - Placement helpers

    private func routePoint(_ index: Int, sideOffset: CGFloat = 0) -> CGPoint {
        let i = ((index % routePoints.count) + routePoints.count) % routePoints.count
        let p = routePoints[i]
        guard sideOffset != 0 else { return p }
        let next = routePoints[min(i + 1, routePoints.count - 1)]
        let dx = next.x - p.x
        let dy = next.y - p.y
        let length = max(1, hypot(dx, dy))
        return CGPoint(x: p.x - dy / length * sideOffset, y: p.y + dx / length * sideOffset)
    }

    private func addCollectibles(kind: String, asset: String, count: Int, start: Int, step: Int, size: CGFloat) {
        for n in 0..<count {
            let index = (start + n * step) % routePoints.count
            let offset: CGFloat = n.isMultiple(of: 2) ? 58 : -58
            let node = SKSpriteNode(imageNamed: asset)
            node.size = CGSize(width: size, height: size)
            node.position = routePoint(index, sideOffset: offset)
            node.name = "collect:\(kind)"
            node.zPosition = depth(forY: node.position.y) + 3
            world.addChild(node)
            collectibleNodes.append(node)
            node.run(.repeatForever(.sequence([.moveBy(x: 0, y: 8, duration: 0.75), .moveBy(x: 0, y: -8, duration: 0.75)])))
        }
    }

    private func addAnimal(kind: String, worried: String, index: Int, size: CGFloat) {
        addNPC(asset: worried, name: "npc:\(kind):worried", index: index, size: size, action: .animalRescue)
    }

    private func addPuzzle(_ challenge: RPGChallenge, index: Int) {
        let asset: String
        switch challenge {
        case .memory: asset = "rpg_chest_wood_closed"
        case .numbers: asset = "rpg_chest_magic_closed"
        case .shapes: asset = "rpg_chest_magic_closed"
        case .words: asset = "rpg_chest_crystal_closed"
        }
        addNPC(asset: asset, name: "puzzle:\(challenge.rawValue)", index: index, size: 130, action: .puzzle)
    }

    private func addTreasure(style: String, index: Int, id: Int) {
        let asset: String
        switch style {
        case "magic": asset = "rpg_chest_magic_closed"
        case "crystal": asset = "rpg_chest_crystal_closed"
        default: asset = "rpg_chest_wood_closed"
        }
        addNPC(asset: asset, name: "treasure:\(style):\(id)", index: index, size: 132, action: .treasure)
    }

    private func addExit(index: Int, asset: String) {
        addNPC(asset: asset, name: "area_exit", index: index, size: 145, action: .exit)
    }

    private func addNPC(asset: String, name: String, index: Int, size: CGFloat, action: RPGNearbyAction) {
        let node = SKSpriteNode(imageNamed: asset)
        node.size = CGSize(width: size, height: size)
        node.position = routePoint(index, sideOffset: 85)
        node.name = name
        node.zPosition = depth(forY: node.position.y) + 5
        node.userData = NSMutableDictionary()
        node.userData?["action"] = actionKey(action)
        world.addChild(node)
        interactionNodes.append(node)
    }

    private func setupPlayer(at position: CGPoint) {
        player.removeFromParent()
        player.texture = idleTexture
        player.size = CGSize(width: 145, height: 175)
        player.position = position
        player.anchorPoint = CGPoint(x: 0.5, y: 0.18)
        player.zPosition = depth(forY: position.y) + 10
        world.addChild(player)
    }

    private func setupCompanion() {
        companion.removeFromParent()
        companion.texture = companionIdleTexture
        companion.size = CGSize(width: 92, height: 108)
        companion.position = CGPoint(x: player.position.x - 100, y: player.position.y + 110)
        companion.zPosition = depth(forY: companion.position.y) + 14
        world.addChild(companion)
    }

    // MARK: - Navigation

    private func buildRoute(from start: CGPoint, to target: CGPoint) {
        let startIndex = nearestRouteIndex(to: start)
        let endIndex = nearestRouteIndex(to: target)
        if startIndex == endIndex {
            pathQueue = [target]
            return
        }
        if startIndex < endIndex {
            pathQueue = Array(routePoints[(startIndex + 1)...endIndex])
        } else {
            pathQueue = Array(routePoints[endIndex..<startIndex].reversed())
        }
        if pathQueue.last != target { pathQueue.append(target) }
    }

    private func nearestRouteIndex(to point: CGPoint) -> Int {
        var best = 0
        var bestDistance = CGFloat.greatestFiniteMagnitude
        for (i, p) in routePoints.enumerated() {
            let d = hypot(p.x - point.x, p.y - point.y)
            if d < bestDistance { bestDistance = d; best = i }
        }
        return best
    }

    private func nearestPointOnRoute(to point: CGPoint) -> CGPoint {
        var best = routePoints[0]
        var bestDistance = CGFloat.greatestFiniteMagnitude
        for i in 0..<(routePoints.count - 1) {
            let candidate = closestPoint(point, onSegmentFrom: routePoints[i], to: routePoints[i + 1])
            let d = hypot(candidate.x - point.x, candidate.y - point.y)
            if d < bestDistance { bestDistance = d; best = candidate }
        }
        return best
    }

    private func isWalkable(_ point: CGPoint) -> Bool {
        distanceToRoute(point) <= pathHalfWidth
    }

    private func distanceToRoute(_ point: CGPoint) -> CGFloat {
        var best = CGFloat.greatestFiniteMagnitude
        for i in 0..<(routePoints.count - 1) {
            let candidate = closestPoint(point, onSegmentFrom: routePoints[i], to: routePoints[i + 1])
            best = min(best, hypot(candidate.x - point.x, candidate.y - point.y))
        }
        return best
    }

    private func closestPoint(_ p: CGPoint, onSegmentFrom a: CGPoint, to b: CGPoint) -> CGPoint {
        let abx = b.x - a.x
        let aby = b.y - a.y
        let lengthSq = abx * abx + aby * aby
        guard lengthSq > 0 else { return a }
        let t = max(0, min(1, ((p.x - a.x) * abx + (p.y - a.y) * aby) / lengthSq))
        return CGPoint(x: a.x + abx * t, y: a.y + aby * t)
    }

    // MARK: - Frame update

    override func update(_ currentTime: TimeInterval) {
        let delta = lastUpdateTime == 0 ? 1.0 / 60.0 : min(1.0 / 20.0, currentTime - lastUpdateTime)
        lastUpdateTime = currentTime
        updatePlayerMovement(delta: delta)
        updateAnimations(delta: delta)
        updateCompanion(delta: delta)
        updateCamera(delta: delta)
        updateNearbyInteraction()
        collectNearbyItems()
    }

    private func updatePlayerMovement(delta: TimeInterval) {
        guard !isTransitioning else { return }

        var direction = CGVector.zero
        var speed: CGFloat = 0

        if joystickMagnitude >= 0.04 {
            direction = joystickVector
            speed = joystickMagnitude > 0.72 ? 360 : 245
        } else if let target = pathQueue.first {
            let dx = target.x - player.position.x
            let dy = target.y - player.position.y
            let distance = hypot(dx, dy)
            if distance < 18 {
                pathQueue.removeFirst()
                if pathQueue.isEmpty { setMovementState(.idle); return }
                return
            }
            direction = CGVector(dx: dx / max(distance, 1), dy: dy / max(distance, 1))
            speed = 285
        } else {
            setMovementState(.idle)
            return
        }

        let step = speed * CGFloat(delta)
        let candidate = CGPoint(x: player.position.x + direction.dx * step, y: player.position.y + direction.dy * step)
        if isWalkable(candidate) {
            player.position = candidate
        } else {
            let snapped = nearestPointOnRoute(to: candidate)
            if hypot(snapped.x - player.position.x, snapped.y - player.position.y) < step * 1.8 {
                player.position = snapped
            }
        }

        setMovementState(speed > 320 ? .running : .walking)
        if direction.dy > 0.18 { facingAway = true }
        if direction.dy < -0.18 { facingAway = false }
        if abs(direction.dx) > 0.12 { player.xScale = direction.dx < 0 ? -1 : 1 }
        player.zPosition = depth(forY: player.position.y) + 10
    }

    private func updateAnimations(delta: TimeInterval) {
        animationTime += delta
        let interval = movementState == .running ? 0.10 : 0.15
        guard movementState != .idle else {
            player.texture = facingAway ? backIdleTexture : idleTexture
            return
        }
        guard animationTime >= interval else { return }
        animationTime = 0
        animationFrame = (animationFrame + 1) % 4
        switch movementState {
        case .walking: player.texture = facingAway ? backWalkTextures[animationFrame] : walkTextures[animationFrame]
        case .running: player.texture = facingAway ? backRunTextures[animationFrame] : runTextures[animationFrame]
        case .idle: break
        }
    }

    private func updateCompanion(delta: TimeInterval) {
        let targetX = player.position.x + (player.xScale < 0 ? 95 : -95)
        let targetY = player.position.y + (facingAway ? -70 : 105)
        let follow = min(1, CGFloat(delta) * 5.2)
        companion.position.x += (targetX - companion.position.x) * follow
        companion.position.y += (targetY - companion.position.y) * follow
        companion.zPosition = depth(forY: companion.position.y) + 14
        companion.xScale = player.xScale

        companionAnimationTime += delta
        let moving = movementState != .idle
        if moving && companionAnimationTime > 0.12 {
            companionAnimationTime = 0
            companionFrame = (companionFrame + 1) % 4
            companion.texture = facingAway ? companionBackFlyTextures[companionFrame] : companionFlyTextures[companionFrame]
        } else if !moving {
            companion.texture = facingAway ? companionBackIdleTexture : companionIdleTexture
        }
    }

    private func updateCamera(delta: TimeInterval) {
        let follow = min(1, CGFloat(delta) * 5.5)
        cameraNode.position.x += (player.position.x - cameraNode.position.x) * follow
        cameraNode.position.y += (player.position.y - cameraNode.position.y) * follow
        clampCameraToWorld()
    }

    private func updateNearbyInteraction() {
        var closest: SKSpriteNode?
        var closestDistance: CGFloat = 205
        for node in interactionNodes where node.parent != nil {
            let d = hypot(node.position.x - player.position.x, node.position.y - player.position.y)
            if d < closestDistance { closestDistance = d; closest = node }
        }
        nearbyInteractionNode = closest
        guard let closest, let key = closest.userData?["action"] as? String else {
            gameState.nearbyAction = nil
            return
        }
        gameState.nearbyAction = action(from: key)
    }

    private func collectNearbyItems() {
        for node in collectibleNodes where node.parent != nil && node.name != nil {
            let d = hypot(node.position.x - player.position.x, node.position.y - player.position.y)
            guard d < 95, let name = node.name, name.hasPrefix("collect:") else { continue }
            let kind = String(name.dropFirst("collect:".count))
            node.name = nil
            gameState.collect(kind: kind)
            node.removeAllActions()
            node.run(.sequence([
                .group([.moveBy(x: 70, y: 120, duration: 0.28), .scale(to: 1.35, duration: 0.18), .fadeOut(withDuration: 0.28)]),
                .removeFromParent()
            ]))
        }
        collectibleNodes.removeAll { $0.parent == nil }
    }

    // MARK: - Interactions

    private func interactWithAnimal(_ node: SKSpriteNode) {
        guard let name = node.name else { return }
        let parts = name.split(separator: ":")
        guard parts.count >= 3 else { return }
        let kind = String(parts[1])
        let state = String(parts[2])
        if state == "worried" {
            gameState.rescueAnimal(kind: kind)
            node.texture = SKTexture(imageNamed: happyAsset(for: kind))
            node.name = "npc:\(kind):happy"
            node.userData?["action"] = actionKey(.animalTalk)
            showHeart(over: node, symbol: "💛")
            SpeechManager.shared.speak(text: gameState.message)
        } else {
            node.texture = SKTexture(imageNamed: talkingAsset(for: kind))
            gameState.setMessage(greek: animalTalkingGreek(kind), english: "Thank you, Babis! Keep following the path and help the other forest friends too.")
            SpeechManager.shared.speak(text: gameState.message)
            returnTexture(node, asset: happyAsset(for: kind))
        }
    }

    private func openTreasure(_ node: SKSpriteNode) {
        guard let name = node.name else { return }
        let parts = name.split(separator: ":")
        let style = parts.count > 1 ? String(parts[1]) : "wood"
        let openAsset = style == "magic" ? "rpg_chest_magic_open" : (style == "crystal" ? "rpg_chest_crystal_open" : "rpg_chest_wood_open")
        node.texture = SKTexture(imageNamed: openAsset)
        node.name = "treasure:opened"
        interactionNodes.removeAll { $0 === node }
        nearbyInteractionNode = nil
        gameState.nearbyAction = nil
        gameState.openTreasure()
        showRewardBurst(at: node.position, asset: style == "crystal" ? "rpg_treasure_gems" : "rpg_treasure_coin_pile")
    }

    private func showRewardBurst(at position: CGPoint, asset: String) {
        let reward = SKSpriteNode(imageNamed: asset)
        reward.size = CGSize(width: 150, height: 120)
        reward.position = CGPoint(x: position.x, y: position.y + 100)
        reward.zPosition = 20000
        world.addChild(reward)
        reward.setScale(0.3)
        reward.alpha = 0
        reward.run(.sequence([.group([.fadeIn(withDuration: 0.18), .scale(to: 1.15, duration: 0.28), .moveBy(x: 0, y: 35, duration: 0.28)]), .wait(forDuration: 0.6), .fadeOut(withDuration: 0.25), .removeFromParent()]))
    }

    private func showHeart(over node: SKSpriteNode, symbol: String) {
        let label = SKLabelNode(text: symbol)
        label.fontSize = 52
        label.position = CGPoint(x: node.position.x, y: node.position.y + node.size.height * 0.65)
        label.zPosition = 22000
        world.addChild(label)
        label.run(.sequence([.group([.moveBy(x: 0, y: 55, duration: 0.75), .scale(to: 1.4, duration: 0.75)]), .fadeOut(withDuration: 0.35), .removeFromParent()]))
    }

    private func returnTexture(_ node: SKSpriteNode, asset: String) {
        node.run(.sequence([.wait(forDuration: 1.5), .run { [weak node] in node?.texture = SKTexture(imageNamed: asset) }]))
    }

    private func setMovementState(_ state: MovementState) {
        if movementState != state { movementState = state; animationTime = 0; animationFrame = 0 }
    }

    private func depth(forY y: CGFloat) -> CGFloat { 10000 - y }

    private func texture(named name: String, fallback: String) -> SKTexture {
        if UIImage(named: name) != nil { return SKTexture(imageNamed: name) }
        return SKTexture(imageNamed: fallback)
    }

    private func happyAsset(for kind: String) -> String {
        switch kind {
        case "rabbit": return "rabbit_rpg_happy"
        case "hedgehog": return "hedgehog_rpg_happy"
        case "deer": return "deer_rpg_happy"
        case "squirrel": return "squirrel_rpg_happy"
        case "owl": return "owl_rpg_happy"
        default: return "rabbit_rpg_happy"
        }
    }

    private func talkingAsset(for kind: String) -> String {
        switch kind {
        case "rabbit": return "rabbit_rpg_talking"
        case "hedgehog": return "hedgehog_rpg_talking"
        case "deer": return "deer_rpg_talking"
        case "squirrel": return "squirrel_rpg_talking"
        case "owl": return "owl_rpg_talking"
        default: return "rabbit_rpg_talking"
        }
    }

    private func animalTalkingGreek(_ kind: String) -> String {
        switch kind {
        case "rabbit": return "Ευχαριστώ, Μπάμπη! Το μονοπάτι συνεχίζει πιο βαθιά στο δάσος."
        case "hedgehog": return "Σε ευχαριστώ! Μείνε στο μονοπάτι και θα βρεις το επόμενο σημάδι."
        case "deer": return "Μπράβο! Ακολούθησε τις στροφές και μην κόψεις δρόμο μέσα από τους θάμνους."
        case "squirrel": return "Ευχαριστώ! Ένα κλειδί βρίσκεται πιο πέρα, δίπλα στο μονοπάτι."
        case "owl": return "Ο σωστός δρόμος είναι αυτός που φαίνεται καθαρά. Ακολούθησέ τον μέχρι το τέλος."
        default: return "Σε ευχαριστώ, Μπάμπη! Συνέχισε την αποστολή σου."
        }
    }

    private func actionKey(_ action: RPGNearbyAction) -> String {
        switch action {
        case .kotsifi: return "kotsifi"
        case .exit: return "exit"
        case .fox: return "fox"
        case .puzzle: return "puzzle"
        case .animalRescue: return "animalRescue"
        case .animalTalk: return "animalTalk"
        case .treasure: return "treasure"
        case .unicorn: return "unicorn"
        }
    }

    private func action(from key: String) -> RPGNearbyAction? {
        switch key {
        case "kotsifi": return .kotsifi
        case "exit": return .exit
        case "fox": return .fox
        case "puzzle": return .puzzle
        case "animalRescue": return .animalRescue
        case "animalTalk": return .animalTalk
        case "treasure": return .treasure
        case "unicorn": return .unicorn
        default: return nil
        }
    }
}
