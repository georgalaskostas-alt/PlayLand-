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

    // Larger exploration space. Each RPGArea is now a substantial map.
    private let worldSize = CGSize(width: 6800, height: 4200)
    private let playerCollisionRadius: CGFloat = 44

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
    private var tapRunActive = false
    private var interactionNodes: [SKSpriteNode] = []
    private var collectibleNodes: [SKSpriteNode] = []
    private var obstacleRects: [CGRect] = []
    private var reservedRects: [CGRect] = []
    private weak var nearbyInteractionNode: SKSpriteNode?
    private weak var activeChallengeNode: SKSpriteNode?
    private weak var activeEncounterNode: SKSpriteNode?
    private weak var pinchGesture: UIPinchGestureRecognizer?
    private var isTransitioning = false

    private let minCameraScale: CGFloat = 0.42
    private let maxCameraScale: CGFloat = 2.60

    private lazy var idleTexture = texture(named: "babis_rpg_idle", fallback: "babis_rpg_master")
    private lazy var backIdleTexture = texture(named: "babis_rpg_back_idle", fallback: "babis_rpg_idle")
    private lazy var walkTextures = (1...4).map { texture(named: String(format: "babis_rpg_walk_%02d", $0), fallback: "babis_rpg_idle") }
    private lazy var runTextures = (1...4).map { texture(named: String(format: "babis_rpg_run_%02d", $0), fallback: "babis_rpg_idle") }
    private lazy var backWalkTextures = (1...4).map { texture(named: String(format: "babis_rpg_back_walk_%02d", $0), fallback: "babis_rpg_back_idle") }
    private lazy var backRunTextures = (1...4).map { texture(named: String(format: "babis_rpg_back_run_%02d", $0), fallback: "babis_rpg_back_idle") }

    private lazy var companionIdleTexture = texture(named: "kotsifi_rpg_idle", fallback: "kotsifi_rpg_master")
    private lazy var companionBackIdleTexture = texture(named: "kotsifi_rpg_back_idle", fallback: "kotsifi_rpg_idle")
    private lazy var companionFlyTextures = (1...4).map { texture(named: String(format: "kotsifi_rpg_fly_%02d", $0), fallback: "kotsifi_rpg_idle") }
    private lazy var companionBackFlyTextures = (1...4).map { texture(named: String(format: "kotsifi_rpg_back_fly_%02d", $0), fallback: "kotsifi_rpg_fly_01") }

    // Broad map anchors, spread across the full 6800x4200 stage.
    private let contentPoints: [CGPoint] = [
        .init(x: 700, y: 600), .init(x: 1250, y: 720), .init(x: 1850, y: 600), .init(x: 2450, y: 820),
        .init(x: 3100, y: 620), .init(x: 3800, y: 820), .init(x: 4500, y: 620), .init(x: 5200, y: 840),
        .init(x: 6000, y: 700), .init(x: 900, y: 1450), .init(x: 1600, y: 1600), .init(x: 2350, y: 1450),
        .init(x: 3100, y: 1650), .init(x: 3900, y: 1420), .init(x: 4700, y: 1650), .init(x: 5550, y: 1450),
        .init(x: 6200, y: 1700), .init(x: 700, y: 2450), .init(x: 1450, y: 2650), .init(x: 2250, y: 2400),
        .init(x: 3050, y: 2700), .init(x: 3900, y: 2420), .init(x: 4750, y: 2700), .init(x: 5550, y: 2400),
        .init(x: 6250, y: 2650), .init(x: 900, y: 3500), .init(x: 1750, y: 3300), .init(x: 2600, y: 3600),
        .init(x: 3500, y: 3350), .init(x: 4450, y: 3600), .init(x: 5400, y: 3350), .init(x: 6200, y: 3600)
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
        guard !isTransitioning, gameState.pendingChallenge == nil, gameState.pendingEncounter == nil else { return }
        let magnitude = min(1, hypot(vector.dx, vector.dy))
        joystickMagnitude = magnitude
        if magnitude < 0.04 {
            joystickVector = .zero
        } else {
            joystickVector = CGVector(dx: vector.dx / magnitude, dy: vector.dy / magnitude)
            pathQueue.removeAll()
            tapRunActive = false
        }
    }

    func stopMovement() {
        joystickVector = .zero
        joystickMagnitude = 0
        pathQueue.removeAll()
        tapRunActive = false
        setMovementState(.idle)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isTransitioning,
              gameState.pendingChallenge == nil,
              gameState.pendingEncounter == nil,
              joystickMagnitude < 0.04,
              let touch = touches.first else { return }
        let tapped = touch.location(in: world)
        pathQueue = [CGPoint(
            x: min(max(tapped.x, 100), worldSize.width - 100),
            y: min(max(tapped.y, 100), worldSize.height - 100)
        )]
        tapRunActive = true
    }

    func talkToCompanion() {
        guard !isTransitioning else { return }
        let messages: [(String, String)] = [
            ("Η περιοχή είναι μεγάλη. Εξερεύνησέ την ολόκληρη και ψάξε στις άκρες του χάρτη.", "This area is large. Explore all of it and check the edges of the map."),
            ("Τα αντικείμενα βρίσκονται μόνο σε σημεία που μπορείς να φτάσεις.", "Items are placed only where you can actually reach them."),
            ("Τα δέντρα, οι θάμνοι, οι πέτρες και οι κορμοί είναι κανονικά εμπόδια. Πέρασε γύρω τους.", "Trees, bushes, rocks and logs are real obstacles. Walk around them.")
        ]
        let pair = messages[gameState.area.rawValue % messages.count]
        gameState.setMessage(greek: pair.0, english: pair.1)
        SpeechManager.shared.speak(text: gameState.message)
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
            if String(parts[2]) == "worried" {
                activeEncounterNode = node
                gameState.pendingEncounter = .animal(kind: kind)
            } else {
                interactWithAnimal(node)
            }
            return
        }

        switch name {
        case "unicorn:worried": activeEncounterNode = node; gameState.pendingEncounter = .unicorn
        case "unicorn:happy":
            node.texture = SKTexture(imageNamed: "unicorn_rpg_talking")
            gameState.setMessage(greek: "Σε ευχαριστώ! Συνέχισε την εξερεύνηση.", english: "Thank you! Keep exploring.")
            returnTexture(node, asset: "unicorn_rpg_happy")
        case "fox": activeEncounterNode = node; gameState.pendingEncounter = .fox
        case "area_exit":
            guard gameState.areaGoalComplete else {
                gameState.setMessage(greek: "Υπάρχουν ακόμη στόχοι εδώ. Συνέχισε την εξερεύνηση.", english: "There are still objectives here. Keep exploring.")
                AudioManager.shared.play(.wrong)
                return
            }
            beginAreaTransition(using: node)
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
            installLivingIdle(on: node, seed: kind.hashValue)
        case .treasure: openTreasure(node)
        case .unicorn:
            gameState.helpUnicorn()
            node.texture = SKTexture(imageNamed: "unicorn_rpg_happy")
            node.name = "unicorn:happy"
            showHeart(over: node, symbol: "✨")
            installLivingIdle(on: node, seed: 777)
        case .fox:
            gameState.meetFox()
            node.texture = texture(named: "fox_talking", fallback: "fox_friendly")
            installLivingIdle(on: node, seed: 991)
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

    private func beginAreaTransition(using exitNode: SKSpriteNode) {
        guard !isTransitioning else { return }
        isTransitioning = true
        joystickVector = .zero
        joystickMagnitude = 0
        pathQueue.removeAll()
        tapRunActive = false
        nearbyInteractionNode = nil
        gameState.nearbyAction = nil

        let dx = exitNode.position.x - player.position.x
        let dy = exitNode.position.y - player.position.y
        let distance = max(hypot(dx, dy), 1)
        let direction = CGVector(dx: dx / distance, dy: dy / distance)
        updateFacing(direction)
        setMovementState(.running)

        let walkTarget = CGPoint(
            x: exitNode.position.x + direction.dx * 100,
            y: exitNode.position.y + direction.dy * 100
        )
        let companionTarget = CGPoint(x: walkTarget.x - 90, y: walkTarget.y + 80)

        let fade = SKSpriteNode(color: .black, size: CGSize(width: max(size.width, 1200) * 4, height: max(size.height, 900) * 4))
        fade.position = .zero
        fade.alpha = 0
        fade.zPosition = 100_000
        cameraNode.addChild(fade)

        let travelDuration: TimeInterval = 1.35
        player.run(.move(to: walkTarget, duration: travelDuration))
        companion.run(.move(to: companionTarget, duration: travelDuration))
        cameraNode.run(.group([
            .move(to: CGPoint(x: (player.position.x + exitNode.position.x) / 2, y: (player.position.y + exitNode.position.y) / 2), duration: travelDuration),
            .scale(to: 0.86, duration: travelDuration)
        ]))

        let fadeIn = SKAction.sequence([.wait(forDuration: 0.78), .fadeAlpha(to: 1, duration: 0.48)])
        fade.run(fadeIn) { [weak self, weak fade, weak exitNode] in
            guard let self else { return }
            let finishing = self.gameState.area == .foxDen
            self.gameState.advanceArea()

            if finishing {
                exitNode?.texture = SKTexture(imageNamed: "rpg_chest_crystal_open")
                self.setMovementState(.idle)
                fade?.run(.sequence([.wait(forDuration: 0.25), .fadeOut(withDuration: 0.55), .removeFromParent()]))
                self.isTransitioning = false
                return
            }

            self.loadArea(self.gameState.area)
            self.isTransitioning = true
            fade?.alpha = 1
            fade?.run(.sequence([
                .wait(forDuration: 0.18),
                .fadeOut(withDuration: 0.70),
                .removeFromParent(),
                .run { [weak self] in
                    self?.isTransitioning = false
                    self?.setMovementState(.idle)
                    if let self { SpeechManager.shared.speak(text: self.gameState.message) }
                }
            ]))
        }
    }

    private func loadArea(_ area: RPGArea) {
        isTransitioning = true
        stopMovement()
        world.removeAllChildren()
        interactionNodes.removeAll()
        collectibleNodes.removeAll()
        obstacleRects.removeAll()
        reservedRects.removeAll()
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
    }

    private func backgroundAsset(for area: RPGArea) -> String {
        switch area {
        case .forest, .rescueClearing, .unicornGrove, .treasureClearing:
            return UIImage(named: "rpg_forest_ground_01") != nil ? "rpg_forest_ground_01" : area.groundAsset
        case .village: return "rpg_village_ground"
        case .riverCrossing: return UIImage(named: "rpg_rescue_clearing") != nil ? "rpg_rescue_clearing" : area.groundAsset
        case .puzzleClearing: return "rpg_puzzle_clearing"
        case .crystalCave: return "rpg_crystal_cave_ground"
        case .nightForest: return "rpg_night_forest_ground"
        case .foxDen: return UIImage(named: "rpg_fox_area_ground") != nil ? "rpg_fox_area_ground" : area.groundAsset
        }
    }

    private func addBackgroundCollisionZones(for area: RPGArea) {
        guard area != .crystalCave else { return }
        obstacleRects.append(contentsOf: [
            CGRect(x: 0, y: 0, width: 480, height: worldSize.height),
            CGRect(x: worldSize.width - 480, y: 0, width: 480, height: worldSize.height),
            CGRect(x: 0, y: worldSize.height - 420, width: worldSize.width, height: 420),
            CGRect(x: 2650, y: 1600, width: 1200, height: 950)
        ])
    }

    private func addEnvironment(for area: RPGArea) {
        let treeAssets = ["rpg_tree_large_01", "rpg_tree_large_02", "rpg_tree_large_03"]
        let treePositions: [CGPoint] = [
            .init(x: 700, y: 1050), .init(x: 1350, y: 1250), .init(x: 2100, y: 980), .init(x: 3050, y: 900),
            .init(x: 4050, y: 1100), .init(x: 5100, y: 900), .init(x: 6050, y: 1150), .init(x: 900, y: 3000),
            .init(x: 1750, y: 3500), .init(x: 2750, y: 3300), .init(x: 3900, y: 3500), .init(x: 5050, y: 3250),
            .init(x: 6100, y: 3450)
        ]
        for (i, p) in treePositions.enumerated() {
            addScenery(asset: treeAssets[i % treeAssets.count], at: p, size: CGSize(width: 380, height: 500))
        }

        let bushes: [CGPoint] = [
            .init(x: 1150, y: 1750), .init(x: 1900, y: 2050), .init(x: 2450, y: 1350), .init(x: 4400, y: 1550),
            .init(x: 5400, y: 2050), .init(x: 6000, y: 2450), .init(x: 1400, y: 3800), .init(x: 4650, y: 3850)
        ]
        for (i, p) in bushes.enumerated() {
            addScenery(asset: i.isMultiple(of: 2) ? "rpg_bush_tall_01" : "rpg_bush_tall_02", at: p, size: CGSize(width: 260, height: 225))
        }

        let rocks: [CGPoint] = [
            .init(x: 950, y: 750), .init(x: 2350, y: 2300), .init(x: 3400, y: 1200), .init(x: 4550, y: 2850), .init(x: 5750, y: 1450)
        ]
        for (i, p) in rocks.enumerated() {
            addScenery(asset: i.isMultiple(of: 2) ? "rpg_rock_large" : "rpg_rock_small", at: p, size: CGSize(width: 220, height: 190))
        }

        addScenery(asset: "rpg_fallen_tree", at: CGPoint(x: 1550, y: 2450), size: CGSize(width: 430, height: 220))
        addScenery(asset: "rpg_tree_stump", at: CGPoint(x: 5000, y: 2450), size: CGSize(width: 210, height: 190))

        if area == .village {
            addScenery(asset: "rpg_village_house_01", at: CGPoint(x: 1300, y: 2400), size: CGSize(width: 700, height: 620))
            addScenery(asset: "rpg_village_house_02", at: CGPoint(x: 5450, y: 1250), size: CGSize(width: 720, height: 630))
        }

        if area == .riverCrossing {
            obstacleRects.append(CGRect(x: 0, y: 1950, width: 2850, height: 520))
            obstacleRects.append(CGRect(x: 3950, y: 1950, width: 2850, height: 520))
            let bridge = SKSpriteNode(imageNamed: "rpg_bridge_wood")
            bridge.position = CGPoint(x: 3400, y: 2200)
            bridge.size = CGSize(width: 1200, height: 520)
            bridge.zPosition = -1200
            world.addChild(bridge)
            let pond = SKSpriteNode(imageNamed: "rpg_pond")
            pond.position = CGPoint(x: 950, y: 2100)
            pond.size = CGSize(width: 1000, height: 620)
            pond.zPosition = -1400
            world.addChild(pond)
        }

        if area == .crystalCave {
            addScenery(asset: "rpg_cave_entrance", at: CGPoint(x: 6100, y: 3400), size: CGSize(width: 650, height: 520))
        }
    }

    private func addScenery(asset: String, at position: CGPoint, size: CGSize) {
        let node = SKSpriteNode(imageNamed: asset)
        node.size = size
        node.position = position
        node.zPosition = depth(forY: position.y)
        world.addChild(node)

        let lower = asset.lowercased()
        let wf: CGFloat
        let hf: CGFloat
        let oy: CGFloat
        if lower.contains("fallen_tree") { wf = 0.96; hf = 0.78; oy = -0.03 }
        else if lower.contains("stump") { wf = 0.92; hf = 0.78; oy = -0.03 }
        else if lower.contains("tree") { wf = 0.72; hf = 0.66; oy = -0.12 }
        else if lower.contains("bush") { wf = 0.98; hf = 0.92; oy = 0 }
        else if lower.contains("rock") { wf = 0.94; hf = 0.90; oy = 0 }
        else if lower.contains("house") || lower.contains("cave") { wf = 0.90; hf = 0.72; oy = -0.08 }
        else { wf = 0.78; hf = 0.68; oy = -0.05 }

        let rect = CGRect(
            x: position.x - size.width * wf / 2,
            y: position.y + size.height * oy - size.height * hf / 2,
            width: size.width * wf,
            height: size.height * hf
        )
        obstacleRects.append(rect)
    }

    private func buildArea(_ area: RPGArea) {
        switch area {
        case .forest:
            addCollectibles(kind: "apple", asset: "apple_item", count: 14, start: 1, step: 2, size: 72)
            addCollectibles(kind: "wood", asset: "log", count: 10, start: 3, step: 3, size: 82)
            addCollectibles(kind: "water", asset: "water_item", count: 8, start: 5, step: 4, size: 70)
            addAnimal(kind: "rabbit", worried: "rabbit_rpg_worried", index: 20, size: 165)
            addPuzzle(.memory, index: 12)
        case .rescueClearing:
            addCollectibles(kind: "berries", asset: "berries_item", count: 14, start: 2, step: 2, size: 70)
            addCollectibles(kind: "carrot", asset: "carrot_item", count: 12, start: 4, step: 3, size: 70)
            addAnimal(kind: "hedgehog", worried: "hedgehog_rpg_worried", index: 18, size: 160)
            addAnimal(kind: "deer", worried: "deer_rpg_worried", index: 28, size: 180)
            addPuzzle(.shapes, index: 10)
            addTreasure(style: "wood", index: 24, id: 1)
        case .village:
            addCollectibles(kind: "wood", asset: "log", count: 14, start: 1, step: 2, size: 82)
            addCollectibles(kind: "berries", asset: "berries_item", count: 12, start: 7, step: 3, size: 68)
            addCollectibles(kind: "carrot", asset: "carrot_item", count: 12, start: 4, step: 3, size: 68)
            addAnimal(kind: "squirrel", worried: "squirrel_rpg_worried", index: 17, size: 160)
            addTreasure(style: "wood", index: 24, id: 1)
        case .riverCrossing:
            addCollectibles(kind: "water", asset: "water_item", count: 14, start: 1, step: 2, size: 70)
            addCollectibles(kind: "wood", asset: "log", count: 12, start: 6, step: 3, size: 82)
            addCollectibles(kind: "key", asset: "key_item", count: 4, start: 13, step: 7, size: 68)
            addAnimal(kind: "deer", worried: "deer_rpg_worried", index: 20, size: 180)
            addPuzzle(.numbers, index: 15)
        case .puzzleClearing:
            addCollectibles(kind: "crystal", asset: "crystal_item", count: 12, start: 1, step: 3, size: 74)
            addCollectibles(kind: "key", asset: "key_item", count: 6, start: 5, step: 6, size: 68)
            addPuzzle(.memory, index: 7); addPuzzle(.numbers, index: 15); addPuzzle(.shapes, index: 25)
            addTreasure(style: "wood", index: 20, id: 1); addTreasure(style: "magic", index: 29, id: 2)
        case .crystalCave:
            addCollectibles(kind: "crystal", asset: "crystal_item", count: 20, start: 0, step: 2, size: 76)
            addCollectibles(kind: "key", asset: "key_item", count: 7, start: 7, step: 5, size: 68)
            addAnimal(kind: "hedgehog", worried: "hedgehog_rpg_worried", index: 21, size: 160)
            addPuzzle(.words, index: 8); addPuzzle(.shapes, index: 24); addTreasure(style: "crystal", index: 29, id: 1)
        case .nightForest:
            addCollectibles(kind: "fragment", asset: "map_fragment", count: 14, start: 1, step: 2, size: 74)
            addCollectibles(kind: "feather", asset: "golden_feather", count: 10, start: 8, step: 3, size: 70)
            addAnimal(kind: "squirrel", worried: "squirrel_rpg_worried", index: 18, size: 160)
            addAnimal(kind: "owl", worried: "owl_rpg_neutral", index: 27, size: 160)
            addPuzzle(.memory, index: 15)
        case .unicornGrove:
            addCollectibles(kind: "crystal", asset: "crystal_item", count: 14, start: 0, step: 2, size: 76)
            addCollectibles(kind: "fragment", asset: "map_fragment", count: 8, start: 7, step: 4, size: 74)
            addPuzzle(.numbers, index: 8); addPuzzle(.words, index: 24); addTreasure(style: "magic", index: 29, id: 1)
            addNPC(asset: "unicorn_rpg_worried", name: "unicorn:worried", index: 20, size: 210, action: .unicorn)
        case .treasureClearing:
            addCollectibles(kind: "key", asset: "key_item", count: 10, start: 2, step: 3, size: 70)
            addCollectibles(kind: "crystal", asset: "crystal_item", count: 14, start: 1, step: 2, size: 76)
            addPuzzle(.shapes, index: 8); addPuzzle(.numbers, index: 24)
            addTreasure(style: "wood", index: 17, id: 1); addTreasure(style: "magic", index: 22, id: 2); addTreasure(style: "crystal", index: 29, id: 3)
        case .foxDen:
            addPuzzle(.words, index: 8); addTreasure(style: "crystal", index: 26, id: 1)
            addNPC(asset: "fox_friendly", name: "fox", index: 20, size: 190, action: .fox)
        }

        addExitForCurrentArea()
    }

    private func routePoint(_ index: Int, sideOffset: CGFloat = 0) -> CGPoint {
        let i = ((index % contentPoints.count) + contentPoints.count) % contentPoints.count
        var p = contentPoints[i]
        p.x += sideOffset
        return p
    }

    private func safePlacement(near desired: CGPoint, footprint: CGSize = CGSize(width: 120, height: 100)) -> CGPoint {
        let offsets: [CGPoint] = [
            .zero, .init(x: 160, y: 0), .init(x: -160, y: 0), .init(x: 0, y: 160), .init(x: 0, y: -160),
            .init(x: 240, y: 160), .init(x: -240, y: 160), .init(x: 240, y: -160), .init(x: -240, y: -160),
            .init(x: 340, y: 0), .init(x: -340, y: 0), .init(x: 0, y: 340), .init(x: 0, y: -340),
            .init(x: 480, y: 240), .init(x: -480, y: 240), .init(x: 480, y: -240), .init(x: -480, y: -240)
        ]
        for off in offsets {
            let p = CGPoint(x: min(max(desired.x + off.x, 180), worldSize.width - 180), y: min(max(desired.y + off.y, 180), worldSize.height - 180))
            let rect = CGRect(x: p.x - footprint.width / 2, y: p.y - footprint.height / 2, width: footprint.width, height: footprint.height)
            if !obstacleRects.contains(where: { $0.intersects(rect) }) && !reservedRects.contains(where: { $0.intersects(rect.insetBy(dx: -40, dy: -40)) }) {
                reservedRects.append(rect)
                return p
            }
        }

        // Deterministic wide-grid fallback. Never stack pickups on the same fallback point.
        for row in 0..<7 {
            for column in 0..<11 {
                let p = CGPoint(x: 750 + CGFloat(column) * 520, y: 650 + CGFloat(row) * 500)
                let rect = CGRect(x: p.x - footprint.width / 2, y: p.y - footprint.height / 2, width: footprint.width, height: footprint.height)
                if !obstacleRects.contains(where: { $0.intersects(rect) }) && !reservedRects.contains(where: { $0.intersects(rect.insetBy(dx: -55, dy: -55)) }) {
                    reservedRects.append(rect)
                    return p
                }
            }
        }
        return CGPoint(x: worldSize.width / 2, y: 600)
    }

    private func addCollectibles(kind: String, asset: String, count: Int, start: Int, step: Int, size: CGFloat) {
        for n in 0..<count {
            let index = (start + n * step) % contentPoints.count
            let desired = routePoint(index, sideOffset: n.isMultiple(of: 2) ? 70 : -70)
            let p = safePlacement(near: desired, footprint: CGSize(width: max(size, 100), height: max(size, 100)))
            let node = SKSpriteNode(imageNamed: asset)
            node.size = CGSize(width: size, height: size)
            node.position = p
            node.name = "collect:\(kind)"
            node.zPosition = depth(forY: p.y) + 3
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
        addNPC(asset: asset, name: "puzzle:\(challenge.rawValue)", index: index, size: 140, action: .puzzle)
    }

    private func addTreasure(style: String, index: Int, id: Int) {
        let asset = style == "magic" ? "rpg_chest_magic_closed" : (style == "crystal" ? "rpg_chest_crystal_closed" : "rpg_chest_wood_closed")
        addNPC(asset: asset, name: "treasure:\(style):\(id)", index: index, size: 145, action: .treasure)
    }

    private func addExitForCurrentArea() {
        let asset: String
        switch gameState.area {
        case .forest: asset = "rpg_wood_sign"
        case .rescueClearing: asset = "rpg_village_house_01"
        case .village: asset = "rpg_bridge_wood"
        case .riverCrossing: asset = "rpg_puzzle_clearing"
        case .puzzleClearing: asset = "rpg_crystal_cave_entrance"
        case .crystalCave: asset = "rpg_cave_entrance"
        case .nightForest: asset = "rpg_wood_sign"
        case .unicornGrove: asset = "rpg_treasure_clearing"
        case .treasureClearing: asset = "rpg_fox_den"
        case .foxDen: asset = "rpg_chest_crystal_closed"
        }
        addNPC(asset: asset, name: "area_exit", index: 31, size: gameState.area == .village ? 360 : 190, action: .exit)
    }

    private func addNPC(asset: String, name: String, index: Int, size: CGFloat, action: RPGNearbyAction) {
        let desired = routePoint(index, sideOffset: 110)
        let p = safePlacement(near: desired, footprint: CGSize(width: max(size * 0.9, 140), height: max(size * 0.75, 120)))
        let node = SKSpriteNode(imageNamed: asset)
        node.size = CGSize(width: size, height: size)
        node.position = p
        node.name = name
        node.zPosition = depth(forY: p.y) + 5
        node.userData = NSMutableDictionary()
        node.userData?["action"] = actionKey(action)
        world.addChild(node)
        interactionNodes.append(node)

        let w = size * (name.hasPrefix("npc:") ? 0.68 : 0.82)
        let h = size * (name.hasPrefix("npc:") ? 0.62 : 0.70)
        obstacleRects.append(CGRect(x: p.x - w / 2, y: p.y - h * 0.40, width: w, height: h))

        if name.hasPrefix("npc:") || name.hasPrefix("unicorn:") || name == "fox" {
            installLivingIdle(on: node, seed: index)
        }
    }

    private func installLivingIdle(on node: SKSpriteNode, seed: Int) {
        node.removeAction(forKey: "livingIdle")
        let phase = Double(abs(seed % 7)) * 0.05
        let up = SKAction.group([
            .moveBy(x: 0, y: 7, duration: 0.70 + phase),
            .rotate(byAngle: 0.018, duration: 0.70 + phase)
        ])
        let down = SKAction.group([
            .moveBy(x: 0, y: -7, duration: 0.70 + phase),
            .rotate(byAngle: -0.036, duration: 0.70 + phase)
        ])
        let center = SKAction.rotate(byAngle: 0.018, duration: 0.30)
        node.run(.repeatForever(.sequence([up, down, center])), withKey: "livingIdle")
    }

    private func setupPlayer(at position: CGPoint) {
        player.removeAllActions()
        player.removeFromParent()
        player.texture = idleTexture
        player.size = CGSize(width: 145, height: 175)
        player.position = position
        player.anchorPoint = CGPoint(x: 0.5, y: 0.18)
        player.zPosition = depth(forY: position.y) + 10
        player.xScale = 1
        player.zRotation = 0
        facingDirection = .front
        world.addChild(player)
    }

    private func setupCompanion() {
        companion.removeAllActions()
        companion.removeFromParent()
        companion.texture = companionIdleTexture
        companion.size = CGSize(width: 92, height: 108)
        companion.position = CGPoint(x: player.position.x - 100, y: player.position.y + 110)
        companion.zPosition = depth(forY: companion.position.y) + 14
        companion.xScale = 1
        companion.zRotation = 0
        world.addChild(companion)
    }

    private func safeSpawnPoint() -> CGPoint {
        let candidates: [CGPoint] = [
            .init(x: 3400, y: 3150), .init(x: 3150, y: 3000), .init(x: 3650, y: 3000), .init(x: 3000, y: 3350), .init(x: 3900, y: 3300),
            .init(x: 2500, y: 3050), .init(x: 4300, y: 3050), .init(x: 3400, y: 1100)
        ]
        return candidates.first(where: isWalkable) ?? CGPoint(x: 3400, y: 1100)
    }

    private func isWalkable(_ point: CGPoint) -> Bool {
        let margin: CGFloat = 85
        guard point.x >= margin, point.y >= margin,
              point.x <= worldSize.width - margin, point.y <= worldSize.height - margin else { return false }
        let feetRect = CGRect(x: point.x - playerCollisionRadius, y: point.y - playerCollisionRadius * 0.48, width: playerCollisionRadius * 2, height: playerCollisionRadius * 0.96)
        return !obstacleRects.contains { $0.intersects(feetRect) }
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

    private func updatePlayerMovement(delta: TimeInterval) {
        guard !isTransitioning, gameState.pendingChallenge == nil, gameState.pendingEncounter == nil else { return }
        var direction = CGVector.zero
        var speed: CGFloat = 0
        if joystickMagnitude >= 0.04 {
            direction = joystickVector
            speed = joystickMagnitude > 0.72 ? 360 : 245
        } else if let target = pathQueue.first {
            let dx = target.x - player.position.x, dy = target.y - player.position.y
            let d = hypot(dx, dy)
            if d < 18 {
                pathQueue.removeFirst()
                if pathQueue.isEmpty {
                    tapRunActive = false
                    setMovementState(.idle)
                }
                return
            }
            direction = CGVector(dx: dx / max(d, 1), dy: dy / max(d, 1))
            speed = tapRunActive ? 390 : 285
        } else {
            tapRunActive = false
            setMovementState(.idle)
            return
        }

        let step = speed * CGFloat(delta)
        let candidate = CGPoint(x: player.position.x + direction.dx * step, y: player.position.y + direction.dy * step)
        if isWalkable(candidate) { player.position = candidate }
        else {
            let cx = CGPoint(x: player.position.x + direction.dx * step, y: player.position.y)
            let cy = CGPoint(x: player.position.x, y: player.position.y + direction.dy * step)
            if isWalkable(cx) { player.position = cx }
            else if isWalkable(cy) { player.position = cy }
            else if joystickMagnitude < 0.04 {
                pathQueue.removeAll()
                tapRunActive = false
            }
        }
        updateFacing(direction)
        setMovementState(speed > 320 ? .running : .walking)
        player.zPosition = depth(forY: player.position.y) + 10
    }

    private func updateFacing(_ direction: CGVector) {
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
        guard movementState != .idle else { player.texture = facingDirection == .back ? backIdleTexture : idleTexture; return }
        guard animationTime >= interval else { return }
        animationTime = 0
        animationFrame = (animationFrame + 1) % 4
        player.texture = facingDirection == .back
            ? (movementState == .running ? backRunTextures[animationFrame] : backWalkTextures[animationFrame])
            : (movementState == .running ? runTextures[animationFrame] : walkTextures[animationFrame])
    }

    private func updateCompanion(delta: TimeInterval) {
        guard !isTransitioning else { return }
        let tx = player.position.x + (player.xScale < 0 ? 95 : -95)
        let ty = player.position.y + (facingDirection == .back ? -70 : 105)
        let follow = min(1, CGFloat(delta) * 5.2)
        companion.position.x += (tx - companion.position.x) * follow
        companion.position.y += (ty - companion.position.y) * follow
        companion.zPosition = depth(forY: companion.position.y) + 14
        companion.xScale = player.xScale
        companionAnimationTime += delta
        if movementState != .idle && companionAnimationTime > 0.12 {
            companionAnimationTime = 0
            companionFrame = (companionFrame + 1) % 4
            companion.texture = facingDirection == .back ? companionBackFlyTextures[companionFrame] : companionFlyTextures[companionFrame]
        } else if movementState == .idle {
            companion.texture = facingDirection == .back ? companionBackIdleTexture : companionIdleTexture
        }
    }

    private func updateCamera(delta: TimeInterval) {
        guard !isTransitioning else { return }
        let follow = min(1, CGFloat(delta) * 5.5)
        cameraNode.position.x += (player.position.x - cameraNode.position.x) * follow
        cameraNode.position.y += (player.position.y - cameraNode.position.y) * follow
        clampCameraToWorld()
    }

    private func updateNearbyInteraction() {
        guard !isTransitioning else { return }
        var closest: SKSpriteNode?
        var best: CGFloat = 230
        for node in interactionNodes where node.parent != nil {
            let d = hypot(node.position.x - player.position.x, node.position.y - player.position.y)
            if d < best { best = d; closest = node }
        }
        nearbyInteractionNode = closest
        guard let closest, let key = closest.userData?["action"] as? String else { gameState.nearbyAction = nil; return }
        gameState.nearbyAction = action(from: key)
    }

    private func collectNearbyItems() {
        guard !isTransitioning else { return }
        for node in collectibleNodes where node.parent != nil && node.name != nil {
            let d = hypot(node.position.x - player.position.x, node.position.y - player.position.y)
            guard d < 95, let name = node.name, name.hasPrefix("collect:") else { continue }
            let kind = String(name.dropFirst("collect:".count))
            node.name = nil
            gameState.collect(kind: kind)
            node.removeAllActions()
            node.run(.sequence([.group([.moveBy(x: 70, y: 120, duration: 0.28), .scale(to: 1.35, duration: 0.18), .fadeOut(withDuration: 0.28)]), .removeFromParent()]))
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
        node.removeAction(forKey: "livingIdle")
        interactionNodes.removeAll { $0 === node }
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
        UIImage(named: name) != nil ? SKTexture(imageNamed: name) : SKTexture(imageNamed: fallback)
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
