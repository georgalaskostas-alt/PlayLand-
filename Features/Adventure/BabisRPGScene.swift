import SpriteKit
import UIKit

final class BabisRPGScene: SKScene {
    private enum MovementState { case idle, walking, running }
    private enum FacingDirection { case front, back, left, right }

    private let gameState: RPGGameState
    private let player = SKSpriteNode()
    private let companion = SKSpriteNode()
    private let world = SKNode()
    private let cameraNode = SKCameraNode()

    private let worldSize = CGSize(width: 4200, height: 2800)
    private let playerCollisionRadius: CGFloat = 42

    private var joystickVector = CGVector.zero
    private var joystickMagnitude: CGFloat = 0
    private var lastUpdateTime: TimeInterval = 0
    private var animationTime: TimeInterval = 0
    private var companionAnimationTime: TimeInterval = 0
    private var animationFrame = 0
    private var companionFrame = 0
    private var movementState: MovementState = .idle
    private var facingDirection: FacingDirection = .front
    private var pathQueue: [CGPoint] = []
    private var interactionNodes: [SKSpriteNode] = []
    private var collectibleNodes: [SKSpriteNode] = []
    private var obstacleRects: [CGRect] = []
    private weak var nearbyInteractionNode: SKSpriteNode?
    private weak var activeChallengeNode: SKSpriteNode?
    private weak var activeEncounterNode: SKSpriteNode?
    private weak var pinchGesture: UIPinchGestureRecognizer?
    private var isTransitioning = false

    private let minCameraScale: CGFloat = 0.42
    private let maxCameraScale: CGFloat = 2.20

    private lazy var idleTexture = texture(named: "babis_rpg_idle", fallback: "babis_rpg_master")
    private lazy var backIdleTexture = texture(named: "babis_rpg_back_idle", fallback: "babis_rpg_idle")
    private lazy var walkTextures: [SKTexture] = (1...4).map { texture(named: String(format: "babis_rpg_walk_%02d", $0), fallback: "babis_rpg_idle") }
    private lazy var runTextures: [SKTexture] = (1...4).map { texture(named: String(format: "babis_rpg_run_%02d", $0), fallback: "babis_rpg_idle") }
    private lazy var backWalkTextures: [SKTexture] = (1...4).map { texture(named: String(format: "babis_rpg_back_walk_%02d", $0), fallback: "babis_rpg_back_idle") }
    private lazy var backRunTextures: [SKTexture] = (1...4).map { texture(named: String(format: "babis_rpg_back_run_%02d", $0), fallback: "babis_rpg_back_idle") }

    private lazy var companionIdleTexture = texture(named: "kotsifi_rpg_idle", fallback: "kotsifi_rpg_master")
    private lazy var companionBackIdleTexture = texture(named: "kotsifi_rpg_back_idle", fallback: "kotsifi_rpg_idle")
    private lazy var companionFlyTextures: [SKTexture] = (1...4).map { texture(named: String(format: "kotsifi_rpg_fly_%02d", $0), fallback: "kotsifi_rpg_idle") }
    private lazy var companionBackFlyTextures: [SKTexture] = (1...4).map { texture(named: String(format: "kotsifi_rpg_back_fly_%02d", $0), fallback: "kotsifi_rpg_fly_01") }

    private let contentPoints: [CGPoint] = [
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

    func setMovementVector(_ vector: CGVector) {
        guard gameState.pendingChallenge == nil, gameState.pendingEncounter == nil else { return }
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
        guard !isTransitioning,
              gameState.pendingChallenge == nil,
              gameState.pendingEncounter == nil,
              joystickMagnitude < 0.04,
              let touch = touches.first else { return }
        let tapped = touch.location(in: world)
        let target = CGPoint(
            x: min(max(tapped.x, 90), worldSize.width - 90),
            y: min(max(tapped.y, 90), worldSize.height - 90)
        )
        pathQueue = [target]
    }

    func talkToCompanion() {
        guard !isTransitioning else { return }
        let messages: [(String, String)] = [
            ("Εξερεύνησε ελεύθερα την περιοχή. Μπορείς να πατήσεις οπουδήποτε για να κινηθείς προς τα εκεί.", "Explore freely. Tap anywhere to move there."),
            ("Ψάξε πίσω από δέντρα, κοντά στους βράχους και στις άκρες της περιοχής.", "Look behind trees, near rocks and around the edges of the area."),
            ("Μπορείς να πας όπου θέλεις, αλλά τα δέντρα, οι θάμνοι, οι κορμοί και οι βράχοι είναι πραγματικά εμπόδια.", "You can go wherever you want, but trees, bushes, logs and rocks are real obstacles.")
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

        if name.hasPrefix("treasure:") {
            activeEncounterNode = node
            let style = name.split(separator: ":").dropFirst().first.map(String.init) ?? "wood"
            gameState.pendingEncounter = .treasure(style: style)
            return
        }

        if name.hasPrefix("npc:") {
            let parts = name.split(separator: ":")
            guard parts.count >= 3 else { return }
            let kind = String(parts[1])
            let state = String(parts[2])
            if state == "worried" {
                activeEncounterNode = node
                gameState.pendingEncounter = .animal(kind: kind)
            } else {
                interactWithAnimal(node)
            }
            return
        }

        switch name {
        case "unicorn:worried":
            activeEncounterNode = node
            gameState.pendingEncounter = .unicorn
        case "unicorn:happy":
            node.texture = SKTexture(imageNamed: "unicorn_rpg_talking")
            gameState.setMessage(greek: "Σε ευχαριστώ! Η μαγεία μου επέστρεψε. Συνέχισε την εξερεύνηση!", english: "Thank you! My magic is back. Keep exploring!")
            SpeechManager.shared.speak(text: gameState.message)
            returnTexture(node, asset: "unicorn_rpg_happy")
        case "fox":
            activeEncounterNode = node
            gameState.pendingEncounter = .fox
        case "area_exit":
            guard gameState.areaGoalComplete else {
                AudioManager.shared.play(.wrong)
                gameState.setMessage(greek: "Υπάρχουν ακόμη στόχοι στην περιοχή. Εξερεύνησε όλο τον χάρτη και έλεγξε κάθε γωνιά.", english: "There are still objectives here. Explore the whole map and check every corner.")
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

    func confirmPendingEncounter() {
        guard let node = activeEncounterNode, let encounter = gameState.pendingEncounter else { return }
        gameState.pendingEncounter = nil

        switch encounter {
        case .animal(let kind):
            gameState.rescueAnimal(kind: kind)
            node.texture = SKTexture(imageNamed: happyAsset(for: kind))
            node.name = "npc:\(kind):happy"
            node.userData?["action"] = actionKey(.animalTalk)
            showHeart(over: node, symbol: "💛")
        case .treasure:
            openTreasure(node)
        case .unicorn:
            gameState.helpUnicorn()
            node.texture = SKTexture(imageNamed: "unicorn_rpg_happy")
            node.name = "unicorn:happy"
            showHeart(over: node, symbol: "✨")
        case .fox:
            gameState.meetFox()
            node.texture = texture(named: "fox_talking", fallback: "fox_friendly")
        }
        activeEncounterNode = nil
        SpeechManager.shared.speak(text: gameState.message)
    }

    func cancelPendingEncounter() {
        gameState.pendingEncounter = nil
        activeEncounterNode = nil
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

    private func loadArea(_ area: RPGArea) {
        isTransitioning = true
        stopMovement()
        world.removeAllChildren()
        interactionNodes.removeAll()
        collectibleNodes.removeAll()
        obstacleRects.removeAll()
        nearbyInteractionNode = nil
        activeChallengeNode = nil
        activeEncounterNode = nil
        gameState.nearbyAction = nil
        gameState.pendingEncounter = nil
        gameState.pendingChallenge = nil

        let background = SKSpriteNode(imageNamed: backgroundAsset(for: area))
        background.size = worldSize
        background.position = CGPoint(x: worldSize.width / 2, y: worldSize.height / 2)
        background.zPosition = -3000
        world.addChild(background)

        addBackgroundCollisionZones(for: area)
        addEnvironment(for: area)
        buildArea(area)

        let spawn = safeSpawnPoint()
        setupPlayer(at: spawn)
        setupCompanion()
        cameraNode.setScale(1.05)
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
        case .riverCrossing, .puzzleClearing:
            return UIImage(named: "rpg_forest_ground_01") != nil ? "rpg_forest_ground_01" : area.groundAsset
        case .crystalCave: return "rpg_crystal_cave_ground"
        case .nightForest: return "rpg_night_forest_ground"
        case .foxDen: return UIImage(named: "rpg_fox_area_ground") != nil ? "rpg_fox_area_ground" : area.groundAsset
        }
    }

    private func addBackgroundCollisionZones(for area: RPGArea) {
        guard area != .crystalCave else { return }
        // The ground art contains large baked-in tree trunks, roots and dense bushes.
        // These zones stop Babis from appearing to climb over those painted objects.
        let zones: [CGRect] = [
            CGRect(x: 2420, y: 980, width: 980, height: 760),
            CGRect(x: 0, y: 1850, width: 620, height: 950),
            CGRect(x: 0, y: 0, width: 420, height: 920),
            CGRect(x: 3500, y: 1960, width: 700, height: 840)
        ]
        obstacleRects.append(contentsOf: zones)
    }

    private func addEnvironment(for area: RPGArea) {
        let treeAssets = ["rpg_tree_large_01", "rpg_tree_large_02", "rpg_tree_large_03"]
        let treePositions: [CGPoint] = [
            .init(x: 420, y: 1050), .init(x: 840, y: 1180), .init(x: 1330, y: 1040), .init(x: 1840, y: 1180),
            .init(x: 2420, y: 520), .init(x: 3010, y: 650), .init(x: 3650, y: 820), .init(x: 3910, y: 1220),
            .init(x: 3820, y: 2120), .init(x: 3410, y: 2440), .init(x: 2780, y: 2580), .init(x: 2150, y: 2580),
            .init(x: 1580, y: 2590), .init(x: 990, y: 2620), .init(x: 360, y: 2460), .init(x: 330, y: 1640)
        ]
        for (i, p) in treePositions.enumerated() {
            addScenery(asset: treeAssets[i % treeAssets.count], at: p, size: CGSize(width: 330, height: 420))
        }

        let bushPositions: [CGPoint] = [
            .init(x: 1150, y: 1110), .init(x: 1530, y: 1260), .init(x: 2550, y: 620), .init(x: 3290, y: 760),
            .init(x: 3740, y: 2370), .init(x: 3150, y: 2570), .init(x: 1940, y: 2570), .init(x: 720, y: 2570)
        ]
        for (i, p) in bushPositions.enumerated() {
            addScenery(asset: i.isMultiple(of: 2) ? "rpg_bush_tall_01" : "rpg_bush_tall_02", at: p, size: CGSize(width: 220, height: 190))
        }

        let rockPositions: [CGPoint] = [
            .init(x: 760, y: 820), .init(x: 1720, y: 520), .init(x: 2360, y: 1320),
            .init(x: 3020, y: 1720), .init(x: 3650, y: 1050), .init(x: 1260, y: 2140)
        ]
        for (i, p) in rockPositions.enumerated() {
            addScenery(asset: i.isMultiple(of: 2) ? "rpg_rock_large" : "rpg_rock_small", at: p, size: CGSize(width: 190, height: 160))
        }

        addScenery(asset: "rpg_fallen_tree", at: CGPoint(x: 1450, y: 1760), size: CGSize(width: 360, height: 190))
        addScenery(asset: "rpg_tree_stump", at: CGPoint(x: 3220, y: 1180), size: CGSize(width: 190, height: 170))

        if area == .village {
            addScenery(asset: "rpg_village_house_01", at: CGPoint(x: 850, y: 1250), size: CGSize(width: 620, height: 560))
            addScenery(asset: "rpg_village_house_02", at: CGPoint(x: 3350, y: 730), size: CGSize(width: 650, height: 570))
        }
        if area == .riverCrossing {
            addScenery(asset: "rpg_bridge_wood", at: CGPoint(x: 2200, y: 1540), size: CGSize(width: 520, height: 260))
        }
    }

    private func addScenery(asset: String, at position: CGPoint, size: CGSize) {
        let node = SKSpriteNode(imageNamed: asset)
        node.size = size
        node.position = position
        node.zPosition = depth(forY: position.y)
        world.addChild(node)

        let lower = asset.lowercased()
        let widthFactor: CGFloat
        let heightFactor: CGFloat
        let verticalOffset: CGFloat

        if lower.contains("fallen_tree") {
            widthFactor = 0.92; heightFactor = 0.72; verticalOffset = -0.04
        } else if lower.contains("stump") {
            widthFactor = 0.88; heightFactor = 0.72; verticalOffset = -0.04
        } else if lower.contains("tree") {
            widthFactor = 0.58; heightFactor = 0.52; verticalOffset = -0.17
        } else if lower.contains("bush") {
            widthFactor = 0.88; heightFactor = 0.78; verticalOffset = -0.04
        } else if lower.contains("rock") {
            widthFactor = 0.88; heightFactor = 0.78; verticalOffset = -0.02
        } else if lower.contains("house") {
            widthFactor = 0.82; heightFactor = 0.62; verticalOffset = -0.10
        } else {
            widthFactor = 0.72; heightFactor = 0.60; verticalOffset = -0.08
        }

        let collisionSize = CGSize(width: size.width * widthFactor, height: size.height * heightFactor)
        let center = CGPoint(x: position.x, y: position.y + size.height * verticalOffset)
        obstacleRects.append(CGRect(
            x: center.x - collisionSize.width / 2,
            y: center.y - collisionSize.height / 2,
            width: collisionSize.width,
            height: collisionSize.height
        ))
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

    private func routePoint(_ index: Int, sideOffset: CGFloat = 0) -> CGPoint {
        let i = ((index % contentPoints.count) + contentPoints.count) % contentPoints.count
        var p = contentPoints[i]
        p.x += sideOffset
        return CGPoint(x: min(max(p.x, 180), worldSize.width - 180), y: min(max(p.y, 180), worldSize.height - 180))
    }

    private func addCollectibles(kind: String, asset: String, count: Int, start: Int, step: Int, size: CGFloat) {
        for n in 0..<count {
            let index = (start + n * step) % contentPoints.count
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
        case .numbers, .shapes: asset = "rpg_chest_magic_closed"
        case .words: asset = "rpg_chest_crystal_closed"
        }
        addNPC(asset: asset, name: "puzzle:\(challenge.rawValue)", index: index, size: 130, action: .puzzle)
    }

    private func addTreasure(style: String, index: Int, id: Int) {
        let asset = style == "magic" ? "rpg_chest_magic_closed" : (style == "crystal" ? "rpg_chest_crystal_closed" : "rpg_chest_wood_closed")
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

        let isChest = name.hasPrefix("puzzle:") || name.hasPrefix("treasure:") || name == "area_exit"
        let width = size * (isChest ? 0.78 : 0.62)
        let height = size * (isChest ? 0.62 : 0.54)
        obstacleRects.append(CGRect(
            x: node.position.x - width / 2,
            y: node.position.y - height * 0.35,
            width: width,
            height: height
        ))
    }

    private func setupPlayer(at position: CGPoint) {
        player.removeFromParent()
        player.texture = idleTexture
        player.size = CGSize(width: 145, height: 175)
        player.position = position
        player.anchorPoint = CGPoint(x: 0.5, y: 0.18)
        player.zPosition = depth(forY: position.y) + 10
        player.xScale = 1
        facingDirection = .front
        world.addChild(player)
    }

    private func setupCompanion() {
        companion.removeFromParent()
        companion.texture = companionIdleTexture
        companion.size = CGSize(width: 92, height: 108)
        companion.position = CGPoint(x: player.position.x - 100, y: player.position.y + 110)
        companion.zPosition = depth(forY: companion.position.y) + 14
        companion.xScale = 1
        world.addChild(companion)
    }

    private func safeSpawnPoint() -> CGPoint {
        let candidates = [
            CGPoint(x: 1960, y: 1620), CGPoint(x: 1820, y: 1510), CGPoint(x: 2140, y: 1780),
            CGPoint(x: 1680, y: 1380), CGPoint(x: 2240, y: 1860), CGPoint(x: 1500, y: 1450)
        ]
        return candidates.first(where: isWalkable) ?? CGPoint(x: 1960, y: 1620)
    }

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

    private func isWalkable(_ point: CGPoint) -> Bool {
        let margin: CGFloat = 70
        guard point.x >= margin, point.y >= margin,
              point.x <= worldSize.width - margin, point.y <= worldSize.height - margin else { return false }

        let feetRect = CGRect(
            x: point.x - playerCollisionRadius,
            y: point.y - playerCollisionRadius * 0.45,
            width: playerCollisionRadius * 2,
            height: playerCollisionRadius * 0.90
        )
        return !obstacleRects.contains { $0.intersects(feetRect) }
    }

    private func updatePlayerMovement(delta: TimeInterval) {
        guard !isTransitioning, gameState.pendingChallenge == nil, gameState.pendingEncounter == nil else {
            setMovementState(.idle)
            return
        }

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
            let candidateX = CGPoint(x: player.position.x + direction.dx * step, y: player.position.y)
            let candidateY = CGPoint(x: player.position.x, y: player.position.y + direction.dy * step)
            if isWalkable(candidateX) {
                player.position = candidateX
            } else if isWalkable(candidateY) {
                player.position = candidateY
            } else if joystickMagnitude < 0.04 {
                pathQueue.removeAll()
            }
        }

        updateFacing(direction)
        setMovementState(speed > 320 ? .running : .walking)
        player.zPosition = depth(forY: player.position.y) + 10
    }

    private func updateFacing(_ direction: CGVector) {
        // Favor front/back frames for diagonal travel. Side frames are used only
        // when movement is predominantly horizontal.
        if abs(direction.dy) >= abs(direction.dx) * 0.55 {
            facingDirection = direction.dy > 0 ? .back : .front
            player.xScale = 1
        } else {
            facingDirection = direction.dx < 0 ? .left : .right
            player.xScale = direction.dx < 0 ? -1 : 1
        }
    }

    private func updateAnimations(delta: TimeInterval) {
        animationTime += delta
        let interval = movementState == .running ? 0.10 : 0.15
        guard movementState != .idle else {
            player.texture = facingDirection == .back ? backIdleTexture : idleTexture
            return
        }
        guard animationTime >= interval else { return }
        animationTime = 0
        animationFrame = (animationFrame + 1) % 4
        if facingDirection == .back {
            player.texture = movementState == .running ? backRunTextures[animationFrame] : backWalkTextures[animationFrame]
        } else {
            player.texture = movementState == .running ? runTextures[animationFrame] : walkTextures[animationFrame]
        }
    }

    private func updateCompanion(delta: TimeInterval) {
        let targetX = player.position.x + (player.xScale < 0 ? 95 : -95)
        let targetY = player.position.y + (facingDirection == .back ? -70 : 105)
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
            companion.texture = facingDirection == .back ? companionBackFlyTextures[companionFrame] : companionFlyTextures[companionFrame]
        } else if !moving {
            companion.texture = facingDirection == .back ? companionBackIdleTexture : companionIdleTexture
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
        var closestDistance: CGFloat = 220
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

    private func interactWithAnimal(_ node: SKSpriteNode) {
        guard let name = node.name else { return }
        let parts = name.split(separator: ":")
        guard parts.count >= 3 else { return }
        let kind = String(parts[1])
        node.texture = SKTexture(imageNamed: talkingAsset(for: kind))
        gameState.setMessage(greek: animalTalkingGreek(kind), english: "Thank you, Babis! Keep exploring and help the other forest friends too.")
        SpeechManager.shared.speak(text: gameState.message)
        returnTexture(node, asset: happyAsset(for: kind))
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
        case "rabbit": return "Ευχαριστώ, Μπάμπη! Συνέχισε την εξερεύνηση."
        case "hedgehog": return "Σε ευχαριστώ! Ψάξε προσεκτικά γύρω από τα εμπόδια."
        case "deer": return "Μπράβο! Το Κοτσύφι μπορεί να σε βοηθήσει να βρεις τον δρόμο."
        case "squirrel": return "Ευχαριστώ! Ένα κλειδί βρίσκεται πιο πέρα."
        case "owl": return "Παρατήρησε καλά όλη την περιοχή. Δεν είναι όλα μπροστά στα μάτια σου."
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
