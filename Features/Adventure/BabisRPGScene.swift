import SpriteKit
import UIKit

final class BabisRPGScene: SKScene, SKPhysicsContactDelegate {
    private enum Category {
        static let player: UInt32 = 1 << 0
        static let obstacle: UInt32 = 1 << 1
        static let collectible: UInt32 = 1 << 2
        static let interaction: UInt32 = 1 << 3
    }

    private enum MovementState {
        case idle
        case walking
        case running
    }

    private let gameState: RPGGameState
    private let player = SKSpriteNode()
    private let companion = SKSpriteNode()
    private let world = SKNode()
    private let cameraNode = SKCameraNode()
    private let worldSize = CGSize(width: 2400, height: 1600)

    private var moveTarget: CGPoint?
    private var joystickVector = CGVector.zero
    private var joystickMagnitude: CGFloat = 0
    private var lastUpdateTime: TimeInterval = 0
    private var animationTime: TimeInterval = 0
    private var companionAnimationTime: TimeInterval = 0
    private var animationFrame = 0
    private var companionFrame = 0
    private var movementState: MovementState = .idle
    private var facingAway = false
    private weak var nearbyInteractionNode: SKSpriteNode?
    private weak var pinchGesture: UIPinchGestureRecognizer?
    private var isTransitioning = false

    // Wider zoom range: the child can pull back enough to understand the map,
    // but never so far that the world becomes tiny or exposes outside the map.
    private let minCameraScale: CGFloat = 0.52
    private let maxCameraScale: CGFloat = 1.55

    private lazy var idleTexture = texture(named: "babis_rpg_idle", fallback: "babis_neutral")
    private lazy var backIdleTexture = texture(named: "babis_rpg_back_idle", fallback: "babis_rpg_idle")

    private lazy var walkTextures: [SKTexture] = (1...4).map {
        texture(named: String(format: "babis_rpg_walk_%02d", $0), fallback: String(format: "babis_run_%02d", $0))
    }
    private lazy var runTextures: [SKTexture] = (1...4).map {
        texture(named: String(format: "babis_rpg_run_%02d", $0), fallback: String(format: "babis_run_%02d", $0))
    }
    private lazy var backWalkTextures: [SKTexture] = (1...4).map {
        texture(named: String(format: "babis_rpg_back_walk_%02d", $0), fallback: String(format: "babis_rpg_walk_%02d", $0))
    }
    private lazy var backRunTextures: [SKTexture] = (1...4).map {
        texture(named: String(format: "babis_rpg_back_run_%02d", $0), fallback: String(format: "babis_rpg_run_%02d", $0))
    }

    private lazy var companionIdleTexture = texture(named: "kotsifi_rpg_idle", fallback: "kotsifi_idle")
    private lazy var companionBackIdleTexture = texture(named: "kotsifi_rpg_back_idle", fallback: "kotsifi_rpg_idle")
    private lazy var companionFlyTextures: [SKTexture] = (1...4).map {
        texture(named: String(format: "kotsifi_rpg_fly_%02d", $0), fallback: String(format: "kotsifi_fly_%02d", min($0, 3)))
    }
    private lazy var companionBackFlyTextures: [SKTexture] = (1...4).map {
        texture(named: String(format: "kotsifi_rpg_back_fly_%02d", $0), fallback: String(format: "kotsifi_rpg_fly_%02d", $0))
    }

    init(size: CGSize, gameState: RPGGameState) {
        self.gameState = gameState
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = .black
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        guard world.parent == nil else { return }

        view.isMultipleTouchEnabled = true
        addChild(world)
        camera = cameraNode
        addChild(cameraNode)
        cameraNode.setScale(1.02)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinch.cancelsTouchesInView = false
        view.addGestureRecognizer(pinch)
        pinchGesture = pinch

        physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: .zero, size: worldSize))
        physicsBody?.categoryBitMask = Category.obstacle
        physicsBody?.collisionBitMask = Category.player

        AudioManager.shared.playLoop(named: "rpg_adventure_theme", volume: 0.24)
        loadArea(gameState.area)
    }

    override func willMove(from view: SKView) {
        if let pinchGesture {
            view.removeGestureRecognizer(pinchGesture)
        }
        AudioManager.shared.stopMusic()
        SpeechManager.shared.stop()
    }

    // MARK: - Public controls

    func setMovementVector(_ vector: CGVector) {
        let magnitude = min(1, hypot(vector.dx, vector.dy))
        joystickMagnitude = magnitude

        if magnitude < 0.04 {
            joystickVector = .zero
            return
        }

        joystickVector = CGVector(dx: vector.dx / magnitude, dy: vector.dy / magnitude)
        moveTarget = nil
    }

    func stopMovement() {
        joystickVector = .zero
        joystickMagnitude = 0
        moveTarget = nil
        player.physicsBody?.velocity = .zero
        setMovementState(.idle)
    }

    func talkToCompanion() {
        guard !isTransitioning else { return }
        let greek = kotsifiGreekMessage
        let english = kotsifiEnglishMessage
        gameState.setMessage(greek: greek, english: english)
        SpeechManager.shared.speak(text: gameState.isGreek ? greek : english)
        AudioManager.shared.play(.storyNext)
    }

    func completeMemoryChallenge() {
        guard let chest = world.childNode(withName: "memory_chest") as? SKSpriteNode else { return }
        chest.texture = SKTexture(imageNamed: "chest_open")
        chest.physicsBody = nil
        chest.name = "memory_chest_open"

        let reward = SKSpriteNode(imageNamed: "crystal_item")
        reward.size = CGSize(width: 78, height: 78)
        reward.position = CGPoint(x: chest.position.x, y: chest.position.y + 95)
        reward.zPosition = depth(forY: reward.position.y) + 12
        world.addChild(reward)
        reward.run(.sequence([
            .group([.moveBy(x: 0, y: 34, duration: 0.35), .scale(to: 1.25, duration: 0.35)]),
            .wait(forDuration: 0.8),
            .group([.fadeOut(withDuration: 0.35), .scale(to: 0.3, duration: 0.35)]),
            .removeFromParent()
        ]))

        nearbyInteractionNode = nil
        gameState.nearbyAction = nil
    }

    func performInteraction() {
        guard !isTransitioning, let node = nearbyInteractionNode, let name = node.name else { return }
        stopMovement()

        switch name {
        case "memory_chest":
            if gameState.memoryPuzzlesSolved > 0 {
                completeMemoryChallenge()
            } else {
                gameState.setMessage(
                    greek: "Το σεντούκι έχει μαγική κλειδαριά. Βρες όλα τα ζευγάρια στο παιχνίδι μνήμης για να ανοίξει!",
                    english: "This chest has a magic lock. Match all the pairs in the memory game to open it!"
                )
                SpeechManager.shared.speak(text: gameState.message)
                gameState.requestMemoryChallenge()
            }

        case "lost_animal":
            guard gameState.rescuedAnimals == 0 else {
                gameState.setMessage(greek: "Το ζωάκι είναι ασφαλές και χαρούμενο τώρα!", english: "The little animal is safe and happy now!")
                SpeechManager.shared.speak(text: gameState.message)
                return
            }

            node.texture = SKTexture(imageNamed: "fox_friendly")
            node.physicsBody = nil
            node.name = "rescued_animal"
            gameState.rescueAnimal()
            nearbyInteractionNode = nil
            gameState.nearbyAction = nil
            SpeechManager.shared.speak(text: gameState.message)

            let heart = SKLabelNode(text: "💛")
            heart.fontSize = 44
            heart.position = CGPoint(x: node.position.x, y: node.position.y + 100)
            heart.zPosition = 2000
            world.addChild(heart)
            heart.run(.sequence([
                .group([.moveBy(x: 0, y: 45, duration: 0.7), .scale(to: 1.35, duration: 0.7)]),
                .fadeOut(withDuration: 0.35),
                .removeFromParent()
            ]))

        case "area_exit":
            if gameState.areaGoalComplete {
                node.texture = SKTexture(imageNamed: "chest_open")
                gameState.setMessage(
                    greek: "Το μεγάλο σεντούκι άνοιξε! Η επόμενη περιοχή σε περιμένει.",
                    english: "The great chest opened! The next area is waiting for you."
                )
                SpeechManager.shared.speak(text: gameState.message)
                isTransitioning = true
                gameState.nearbyAction = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    self.gameState.advanceArea()
                    self.loadArea(self.gameState.area)
                }
            } else {
                AudioManager.shared.play(.wrong)
                gameState.setMessage(
                    greek: "Το μεγάλο σεντούκι είναι ακόμη κλειδωμένο. Κοίτα τους στόχους επάνω και ολοκλήρωσέ τους όλους.",
                    english: "The great chest is still locked. Check the objectives above and complete every one."
                )
                SpeechManager.shared.speak(text: gameState.message)
            }

        case "final_fox":
            guard !gameState.questComplete else {
                gameState.setMessage(greek: "Η Αλεπού είναι πια φίλη σας.", english: "The Fox is your friend now.")
                SpeechManager.shared.speak(text: gameState.message)
                return
            }

            node.texture = SKTexture(imageNamed: "fox_friendly")
            gameState.completeQuest()
            SpeechManager.shared.speak(text: gameState.message)

            let feather = SKSpriteNode(imageNamed: "golden_feather")
            feather.size = CGSize(width: 70, height: 70)
            feather.position = CGPoint(x: node.position.x, y: node.position.y + 110)
            feather.zPosition = 20
            world.addChild(feather)
            feather.run(.repeatForever(.sequence([
                .moveBy(x: 0, y: 12, duration: 0.8),
                .moveBy(x: 0, y: -12, duration: 0.8)
            ])))

        default:
            break
        }
    }

    // MARK: - Zoom

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard !isTransitioning else { return }
        if gesture.state == .began || gesture.state == .changed {
            let proposed = cameraNode.xScale / gesture.scale
            let clamped = min(maxCameraScale, max(minCameraScale, proposed))
            cameraNode.setScale(clamped)
            gesture.scale = 1
        }
    }

    // MARK: - World loading

    private func loadArea(_ area: RPGArea) {
        isTransitioning = true
        stopMovement()
        world.removeAllChildren()
        nearbyInteractionNode = nil
        gameState.nearbyAction = nil

        let background = SKSpriteNode(imageNamed: area.groundAsset)
        background.size = worldSize
        background.position = CGPoint(x: worldSize.width / 2, y: worldSize.height / 2)
        background.zPosition = -1000
        world.addChild(background)

        switch area {
        case .forest: buildForest()
        case .village: buildVillage()
        case .crystalCave: buildCrystalCave()
        case .nightForest: buildNightForest()
        case .foxArea: buildFoxArea()
        }

        setupPlayer(at: CGPoint(x: 360, y: 330))
        setupCompanion()
        cameraNode.position = player.position
        gameState.setMessageForCurrentArea()
        isTransitioning = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { [weak self] in
            guard let self, !self.isTransitioning else { return }
            SpeechManager.shared.speak(text: self.gameState.message)
        }
    }

    private func buildForest() {
        addCommonForestObstacles()
        addForestNoWalkZones()

        // A longer first quest: resources are spread across several routes.
        let apples: [CGPoint] = [
            .init(x: 520, y: 1080), .init(x: 820, y: 840), .init(x: 1260, y: 1230),
            .init(x: 1640, y: 690), .init(x: 1980, y: 980), .init(x: 1830, y: 430)
        ]
        apples.forEach { addCollectible(asset: "apple_item", kind: "apple", at: $0, size: 70) }

        let logs: [CGPoint] = [
            .init(x: 690, y: 390), .init(x: 1130, y: 650), .init(x: 1730, y: 1310), .init(x: 2020, y: 610)
        ]
        logs.forEach { addCollectible(asset: "log", kind: "wood", at: $0, size: 84) }

        let waters: [CGPoint] = [
            .init(x: 1010, y: 420), .init(x: 1450, y: 1040), .init(x: 1910, y: 760)
        ]
        waters.forEach { addCollectible(asset: "water_item", kind: "water", at: $0, size: 72) }

        // Rescue encounter: uses an existing fox asset until dedicated woodland animals are added.
        addNPC(asset: gameState.rescuedAnimals > 0 ? "fox_friendly" : "fox_worried",
               name: gameState.rescuedAnimals > 0 ? "rescued_animal" : "lost_animal",
               at: CGPoint(x: 760, y: 1210), size: 132, interactive: gameState.rescuedAnimals == 0)

        // Interactive chest that launches the existing 12-card MemoryGame.
        addExit(asset: gameState.memoryPuzzlesSolved > 0 ? "chest_open" : "chest_closed",
                name: gameState.memoryPuzzlesSolved > 0 ? "memory_chest_open" : "memory_chest",
                at: CGPoint(x: 1510, y: 720), size: CGSize(width: 120, height: 104))

        // The large progression chest is intentionally far from the starting point.
        addExit(asset: "chest_closed", name: "area_exit", at: CGPoint(x: 2190, y: 1370), size: CGSize(width: 132, height: 114))
    }

    private func buildVillage() {
        addObstacle(asset: "tree_01", at: CGPoint(x: 430, y: 1190), size: CGSize(width: 180, height: 230))
        addObstacle(asset: "tree_02", at: CGPoint(x: 1920, y: 1160), size: CGSize(width: 180, height: 230))
        addObstacle(asset: "wood_sign", at: CGPoint(x: 1110, y: 780), size: CGSize(width: 125, height: 110))
        addObstacle(asset: "tree_03", at: CGPoint(x: 2050, y: 510), size: CGSize(width: 180, height: 230))
        addVillageNoWalkZones()

        [CGPoint(x: 590, y: 930), .init(x: 930, y: 1220), .init(x: 1510, y: 1020), .init(x: 1840, y: 720), .init(x: 1280, y: 520)]
            .forEach { addCollectible(asset: "berries_item", kind: "berries", at: $0, size: 72) }
        [CGPoint(x: 760, y: 580), .init(x: 1220, y: 430), .init(x: 1710, y: 920), .init(x: 1980, y: 430)]
            .forEach { addCollectible(asset: "carrot_item", kind: "carrot", at: $0, size: 72) }
        [CGPoint(x: 560, y: 380), .init(x: 1090, y: 930), .init(x: 1610, y: 560), .init(x: 2010, y: 1250)]
            .forEach { addCollectible(asset: "log", kind: "wood", at: $0, size: 84) }

        addExit(asset: "chest_closed", name: "area_exit", at: CGPoint(x: 2150, y: 1390), size: CGSize(width: 128, height: 110))
    }

    private func buildCrystalCave() {
        addObstacle(asset: "rock_01", at: CGPoint(x: 520, y: 1020), size: CGSize(width: 155, height: 126))
        addObstacle(asset: "rock_02", at: CGPoint(x: 1210, y: 930), size: CGSize(width: 155, height: 126))
        addObstacle(asset: "rock_01", at: CGPoint(x: 1870, y: 560), size: CGSize(width: 155, height: 126))
        addObstacle(asset: "rock_02", at: CGPoint(x: 760, y: 470), size: CGSize(width: 145, height: 120))
        addCaveNoWalkZones()

        [CGPoint(x: 660, y: 1260), .init(x: 1010, y: 760), .init(x: 1450, y: 1240), .init(x: 1730, y: 890), .init(x: 1990, y: 1040), .init(x: 1330, y: 480)]
            .forEach { addCollectible(asset: "crystal_item", kind: "crystal", at: $0, size: 76) }
        [CGPoint(x: 860, y: 360), .init(x: 1840, y: 1260), .init(x: 2100, y: 670)]
            .forEach { addCollectible(asset: "key_item", kind: "key", at: $0, size: 74) }

        addExit(asset: "chest_closed", name: "area_exit", at: CGPoint(x: 2160, y: 1390), size: CGSize(width: 132, height: 114))
    }

    private func buildNightForest() {
        addCommonForestObstacles()
        addForestNoWalkZones()

        [CGPoint(x: 580, y: 1110), .init(x: 930, y: 760), .init(x: 1380, y: 1220), .init(x: 1680, y: 650), .init(x: 2050, y: 970)]
            .forEach { addCollectible(asset: "map_fragment", kind: "fragment", at: $0, size: 80) }
        [CGPoint(x: 1120, y: 480), .init(x: 1880, y: 1260), .init(x: 2070, y: 620)]
            .forEach { addCollectible(asset: "golden_feather", kind: "feather", at: $0, size: 78) }

        addExit(asset: "chest_closed", name: "area_exit", at: CGPoint(x: 2160, y: 1380), size: CGSize(width: 132, height: 114))
    }

    private func buildFoxArea() {
        addObstacle(asset: "tree_01", at: CGPoint(x: 500, y: 1160), size: CGSize(width: 180, height: 230))
        addObstacle(asset: "tree_03", at: CGPoint(x: 1780, y: 1140), size: CGSize(width: 180, height: 230))
        addObstacle(asset: "rock_02", at: CGPoint(x: 1120, y: 700), size: CGSize(width: 150, height: 120))
        addObstacle(asset: "bush_01", at: CGPoint(x: 760, y: 480), size: CGSize(width: 150, height: 115))
        addNoWalkZone(center: CGPoint(x: 150, y: 900), size: CGSize(width: 250, height: 980))
        addNoWalkZone(center: CGPoint(x: 2250, y: 900), size: CGSize(width: 220, height: 980))

        addNPC(asset: "fox_worried", name: "final_fox", at: CGPoint(x: 1940, y: 1160), size: 145, interactive: true)
    }

    // MARK: - Collision map

    private func addCommonForestObstacles() {
        let trees: [(String, CGPoint, CGSize)] = [
            ("tree_01", .init(x: 390, y: 1170), .init(width: 190, height: 245)),
            ("tree_02", .init(x: 820, y: 1290), .init(width: 190, height: 245)),
            ("tree_03", .init(x: 1840, y: 1100), .init(width: 185, height: 240)),
            ("tree_01", .init(x: 2110, y: 520), .init(width: 190, height: 245)),
            ("tree_02", .init(x: 1430, y: 1460), .init(width: 180, height: 230)),
            ("tree_03", .init(x: 560, y: 1480), .init(width: 180, height: 230))
        ]
        trees.forEach { addObstacle(asset: $0.0, at: $0.1, size: $0.2) }

        addObstacle(asset: "rock_01", at: CGPoint(x: 1040, y: 700), size: CGSize(width: 140, height: 112))
        addObstacle(asset: "rock_02", at: CGPoint(x: 1510, y: 860), size: CGSize(width: 145, height: 116))
        addObstacle(asset: "bush_01", at: CGPoint(x: 570, y: 610), size: CGSize(width: 155, height: 118))
        addObstacle(asset: "bush_02", at: CGPoint(x: 1640, y: 430), size: CGSize(width: 155, height: 118))
    }

    /// These invisible shapes trace dense baked-in foliage. The open spaces between
    /// them become deliberate routes, so Babis follows paths instead of walking over bushes.
    private func addForestNoWalkZones() {
        let zones: [(CGPoint, CGSize)] = [
            (.init(x: 105, y: 800), .init(width: 170, height: 1350)),
            (.init(x: 2295, y: 800), .init(width: 170, height: 1350)),
            (.init(x: 1200, y: 1545), .init(width: 2100, height: 105)),
            (.init(x: 350, y: 790), .init(width: 260, height: 360)),
            (.init(x: 350, y: 1370), .init(width: 310, height: 260)),
            (.init(x: 760, y: 1500), .init(width: 360, height: 150)),
            (.init(x: 1090, y: 1030), .init(width: 260, height: 220)),
            (.init(x: 1510, y: 1180), .init(width: 300, height: 220)),
            (.init(x: 2040, y: 990), .init(width: 290, height: 330)),
            (.init(x: 1950, y: 360), .init(width: 360, height: 200)),
            (.init(x: 700, y: 610), .init(width: 220, height: 190)),
            (.init(x: 1390, y: 430), .init(width: 230, height: 180))
        ]
        zones.forEach { addNoWalkZone(center: $0.0, size: $0.1) }
    }

    private func addVillageNoWalkZones() {
        [
            (CGPoint(x: 140, y: 850), CGSize(width: 210, height: 1200)),
            (CGPoint(x: 2260, y: 850), CGSize(width: 210, height: 1200)),
            (CGPoint(x: 650, y: 1380), CGSize(width: 420, height: 250)),
            (CGPoint(x: 1790, y: 1390), CGSize(width: 430, height: 240)),
            (CGPoint(x: 1320, y: 820), CGSize(width: 250, height: 220))
        ].forEach { addNoWalkZone(center: $0.0, size: $0.1) }
    }

    private func addCaveNoWalkZones() {
        [
            (CGPoint(x: 130, y: 820), CGSize(width: 190, height: 1320)),
            (CGPoint(x: 2270, y: 820), CGSize(width: 190, height: 1320)),
            (CGPoint(x: 620, y: 1430), CGSize(width: 600, height: 240)),
            (CGPoint(x: 1760, y: 1430), CGSize(width: 650, height: 240)),
            (CGPoint(x: 1450, y: 760), CGSize(width: 260, height: 190))
        ].forEach { addNoWalkZone(center: $0.0, size: $0.1) }
    }

    private func addNoWalkZone(center: CGPoint, size: CGSize) {
        let node = SKNode()
        node.position = center
        node.name = "no_walk"
        node.physicsBody = SKPhysicsBody(rectangleOf: size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = Category.obstacle
        node.physicsBody?.collisionBitMask = Category.player
        node.physicsBody?.contactTestBitMask = 0
        world.addChild(node)
    }

    // MARK: - Characters

    private func setupPlayer(at position: CGPoint) {
        player.removeFromParent()
        player.name = "player"
        player.position = position
        player.anchorPoint = CGPoint(x: 0.5, y: 0.22)
        applyPlayerTexture(idleTexture)

        player.physicsBody = SKPhysicsBody(circleOfRadius: 34, center: CGPoint(x: 0, y: 18))
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 10
        player.physicsBody?.restitution = 0
        player.physicsBody?.categoryBitMask = Category.player
        player.physicsBody?.collisionBitMask = Category.obstacle | Category.interaction
        player.physicsBody?.contactTestBitMask = Category.collectible | Category.interaction
        world.addChild(player)
        updateDepthOrdering()
    }

    private func setupCompanion() {
        companion.removeFromParent()
        companion.name = "companion_kotsifi"
        companion.texture = companionIdleTexture
        companion.anchorPoint = CGPoint(x: 0.5, y: 0.2)
        companion.position = CGPoint(x: player.position.x - 105, y: player.position.y + 95)
        applyCompanionTexture(companionIdleTexture)
        world.addChild(companion)
        updateDepthOrdering()
    }

    // MARK: - World objects

    private func addObstacle(asset: String, at position: CGPoint, size: CGSize) {
        let node = SKSpriteNode(imageNamed: asset)
        node.size = size
        node.position = position
        node.zPosition = depth(forY: position.y)

        // Only the lower trunk/base blocks movement. Foliage can visually overlap Babis
        // while the character still cannot walk through the tree itself.
        node.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: size.width * 0.72, height: size.height * 0.36),
            center: CGPoint(x: 0, y: -size.height * 0.28)
        )
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = Category.obstacle
        node.physicsBody?.collisionBitMask = Category.player
        world.addChild(node)
    }

    private func addCollectible(asset: String, kind: String, at position: CGPoint, size: CGFloat) {
        let node = SKSpriteNode(imageNamed: asset)
        node.name = "collectible_\(kind)"
        node.size = CGSize(width: size, height: size)
        node.position = position
        node.zPosition = depth(forY: position.y) + 3
        node.physicsBody = SKPhysicsBody(circleOfRadius: size * 0.34)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = Category.collectible
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.contactTestBitMask = Category.player
        node.run(.repeatForever(.sequence([
            .scale(to: 1.08, duration: 0.7),
            .scale(to: 0.94, duration: 0.7)
        ])))
        world.addChild(node)
    }

    private func addNPC(asset: String, name: String, at position: CGPoint, size: CGFloat, interactive: Bool = false) {
        let node = SKSpriteNode(imageNamed: asset)
        node.name = name
        node.size = CGSize(width: size, height: size)
        node.position = position
        node.zPosition = depth(forY: position.y) + 2

        if interactive {
            node.physicsBody = SKPhysicsBody(circleOfRadius: size * 0.40)
            node.physicsBody?.isDynamic = false
            node.physicsBody?.categoryBitMask = Category.interaction
            node.physicsBody?.collisionBitMask = Category.player
            node.physicsBody?.contactTestBitMask = Category.player
        }
        world.addChild(node)
    }

    private func addExit(asset: String, name: String, at position: CGPoint, size: CGSize) {
        let node = SKSpriteNode(imageNamed: asset)
        node.name = name
        node.size = size
        node.position = position
        node.zPosition = depth(forY: position.y) + 2
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.92, height: size.height * 0.86))
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = Category.interaction
        node.physicsBody?.collisionBitMask = Category.player
        node.physicsBody?.contactTestBitMask = Category.player
        world.addChild(node)
    }

    // MARK: - Input and game loop

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              !isTransitioning,
              joystickMagnitude < 0.04,
              touch.view?.gestureRecognizers?.contains(where: { $0.state == .changed && $0.numberOfTouches > 1 }) != true else { return }
        moveTarget = touch.location(in: world)
    }

    override func update(_ currentTime: TimeInterval) {
        let dt = lastUpdateTime == 0 ? 0 : min(currentTime - lastUpdateTime, 1.0 / 20.0)
        lastUpdateTime = currentTime

        updateMovement(deltaTime: dt)
        updateCompanion(deltaTime: dt)
        updateCamera(deltaTime: dt)
        updateDepthOrdering()
    }

    private func updateMovement(deltaTime: TimeInterval) {
        guard !isTransitioning else {
            player.physicsBody?.velocity = .zero
            setMovementState(.idle)
            return
        }

        var direction: CGVector?
        var speed: CGFloat = 0
        var requestedState: MovementState = .idle

        if joystickMagnitude >= 0.04 {
            direction = joystickVector
            if joystickMagnitude > 0.72 {
                speed = 315
                requestedState = .running
            } else {
                speed = 205
                requestedState = .walking
            }
        } else if let target = moveTarget {
            let dx = target.x - player.position.x
            let dy = target.y - player.position.y
            let distance = hypot(dx, dy)
            if distance < 20 {
                moveTarget = nil
            } else {
                direction = CGVector(dx: dx / distance, dy: dy / distance)
                speed = distance > 220 ? 285 : 205
                requestedState = distance > 220 ? .running : .walking
            }
        }

        guard let direction else {
            player.physicsBody?.velocity = .zero
            setMovementState(.idle)
            return
        }

        player.physicsBody?.velocity = CGVector(dx: direction.dx * speed, dy: direction.dy * speed)

        facingAway = direction.dy > 0.42
        if !facingAway, abs(direction.dx) > 0.08 {
            player.xScale = direction.dx < 0 ? -1 : 1
        } else if facingAway {
            player.xScale = 1
        }

        setMovementState(requestedState)
        animationTime += deltaTime

        let interval: TimeInterval = requestedState == .running ? 0.085 : 0.135
        if animationTime >= interval {
            animationTime = 0
            animationFrame += 1
            let frames: [SKTexture]
            if facingAway {
                frames = requestedState == .running ? backRunTextures : backWalkTextures
            } else {
                frames = requestedState == .running ? runTextures : walkTextures
            }
            if !frames.isEmpty {
                applyPlayerTexture(frames[animationFrame % frames.count])
            }
        }
    }

    private func setMovementState(_ state: MovementState) {
        if movementState == state {
            if state == .idle {
                applyPlayerTexture(facingAway ? backIdleTexture : idleTexture)
            }
            return
        }

        movementState = state
        animationTime = 0
        animationFrame = 0

        if state == .idle {
            applyPlayerTexture(facingAway ? backIdleTexture : idleTexture)
        }
    }

    private func updateCompanion(deltaTime: TimeInterval) {
        guard companion.parent != nil else { return }

        let facingLeft = player.xScale < 0 && !facingAway
        let horizontalOffset: CGFloat = facingLeft ? 105 : -105
        let desired = CGPoint(x: player.position.x + horizontalOffset, y: player.position.y + 95)
        let followFactor = min(1, CGFloat(deltaTime) * 6.8)

        companion.position.x += (desired.x - companion.position.x) * followFactor
        companion.position.y += (desired.y - companion.position.y) * followFactor
        companion.xScale = facingLeft ? -1 : 1

        companionAnimationTime += deltaTime
        if companionAnimationTime >= 0.13 {
            companionAnimationTime = 0
            companionFrame = (companionFrame + 1) % max(1, companionFlyTextures.count)
            let frames = facingAway ? companionBackFlyTextures : companionFlyTextures
            if !frames.isEmpty {
                applyCompanionTexture(frames[companionFrame % frames.count])
            } else {
                applyCompanionTexture(facingAway ? companionBackIdleTexture : companionIdleTexture)
            }
        }
    }

    private func updateCamera(deltaTime: TimeInterval) {
        let cameraScale = cameraNode.xScale
        let halfW = min(worldSize.width / 2, size.width * cameraScale / 2)
        let halfH = min(worldSize.height / 2, size.height * cameraScale / 2)

        let desired = CGPoint(
            x: min(max(player.position.x, halfW), worldSize.width - halfW),
            y: min(max(player.position.y, halfH), worldSize.height - halfH)
        )

        let factor = min(1, CGFloat(deltaTime) * 8.5)
        cameraNode.position.x += (desired.x - cameraNode.position.x) * factor
        cameraNode.position.y += (desired.y - cameraNode.position.y) * factor
    }

    private func updateDepthOrdering() {
        player.zPosition = depth(forY: player.position.y) + 5
        companion.zPosition = depth(forY: companion.position.y) + 7
    }

    private func depth(forY y: CGFloat) -> CGFloat {
        500 - (y / 4)
    }

    // MARK: - Contacts and collection feedback

    func didBegin(_ contact: SKPhysicsContact) {
        let nodes = [contact.bodyA.node, contact.bodyB.node].compactMap { $0 }
        guard let other = nodes.first(where: { $0 !== player }) else { return }

        if let name = other.name, name.hasPrefix("collectible_") {
            collect(node: other, name: name)
            return
        }

        guard let sprite = other as? SKSpriteNode, let name = sprite.name else { return }
        switch name {
        case "area_exit":
            nearbyInteractionNode = sprite
            gameState.nearbyAction = .exit
        case "memory_chest":
            nearbyInteractionNode = sprite
            gameState.nearbyAction = .memoryChest
        case "lost_animal":
            nearbyInteractionNode = sprite
            gameState.nearbyAction = .animalRescue
            gameState.setMessage(
                greek: "Ακούς μια μικρή φωνή: «Μπορείς να με βοηθήσεις; Έχασα τον δρόμο μου!»",
                english: "You hear a tiny voice: ‘Can you help me? I lost my way!’"
            )
            SpeechManager.shared.speak(text: gameState.message)
        case "final_fox":
            nearbyInteractionNode = sprite
            gameState.nearbyAction = .fox
        default:
            break
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let nodes = [contact.bodyA.node, contact.bodyB.node].compactMap { $0 }
        guard let current = nearbyInteractionNode,
              nodes.contains(where: { $0 === current }) else { return }
        nearbyInteractionNode = nil
        gameState.nearbyAction = nil
    }

    private func collect(node: SKNode, name: String) {
        guard let sprite = node as? SKSpriteNode, sprite.action(forKey: "collecting") == nil else { return }

        let kind = String(name.dropFirst("collectible_".count))
        sprite.name = nil
        sprite.physicsBody = nil
        sprite.removeAllActions()
        sprite.zPosition = 2000

        let cameraScale = cameraNode.xScale
        let inventoryTarget = CGPoint(
            x: cameraNode.position.x + size.width * cameraScale * 0.41,
            y: cameraNode.position.y + size.height * cameraScale * 0.34
        )

        let sparkle = SKShapeNode(circleOfRadius: max(sprite.size.width, sprite.size.height) * 0.72)
        sparkle.strokeColor = .white
        sparkle.lineWidth = 4
        sparkle.alpha = 0.8
        sparkle.position = sprite.position
        sparkle.zPosition = 1999
        world.addChild(sparkle)
        sparkle.run(.sequence([
            .group([.scale(to: 1.8, duration: 0.28), .fadeOut(withDuration: 0.28)]),
            .removeFromParent()
        ]))

        let flight = SKAction.group([
            .move(to: inventoryTarget, duration: 0.48),
            .scale(to: 0.32, duration: 0.48),
            .sequence([.wait(forDuration: 0.28), .fadeOut(withDuration: 0.20)])
        ])
        flight.timingMode = .easeInEaseOut

        sprite.run(.sequence([
            flight,
            .run { [weak self, weak sprite] in
                guard let self else { return }
                sprite?.removeFromParent()
                self.gameState.collect(kind: kind)
                if self.gameState.areaGoalComplete && self.gameState.area != .foxArea {
                    SpeechManager.shared.speak(text: self.gameState.message)
                }
            }
        ]), withKey: "collecting")
    }

    // MARK: - Character presentation

    private func texture(named preferred: String, fallback: String) -> SKTexture {
        if UIImage(named: preferred) != nil {
            return SKTexture(imageNamed: preferred)
        }
        return SKTexture(imageNamed: fallback)
    }

    private func applyPlayerTexture(_ texture: SKTexture) {
        player.texture = texture
        player.size = aspectFitSize(for: texture, targetHeight: 150, maxWidth: 184)
    }

    private func applyCompanionTexture(_ texture: SKTexture) {
        companion.texture = texture
        companion.size = aspectFitSize(for: texture, targetHeight: 92, maxWidth: 122)
    }

    private func aspectFitSize(for texture: SKTexture, targetHeight: CGFloat, maxWidth: CGFloat) -> CGSize {
        let source = texture.size()
        guard source.width > 0, source.height > 0 else {
            return CGSize(width: targetHeight, height: targetHeight)
        }
        let width = min(maxWidth, targetHeight * (source.width / source.height))
        return CGSize(width: width, height: targetHeight)
    }

    // MARK: - Companion dialogue

    private var kotsifiGreekMessage: String {
        switch gameState.area {
        case .forest:
            if gameState.rescuedAnimals == 0 { return "Κοτσύφι: Άκου! Κάποιο ζωάκι ζητά βοήθεια. Ας το βρούμε πριν ψάξουμε το μεγάλο σεντούκι." }
            if gameState.memoryPuzzlesSolved == 0 { return "Κοτσύφι: Βλέπω ένα σεντούκι με μαγική κλειδαριά. Νομίζω πως ανοίγει με παιχνίδι μνήμης!" }
            return "Κοτσύφι: Είμαστε κοντά! Συνέχισε στα μονοπάτια και ολοκλήρωσε ό,τι λείπει από την αποστολή."
        case .village: return "Κοτσύφι: Οι κάτοικοι χρειάζονται πολλές προμήθειες. Ψάξε κοντά στα δέντρα και στα μονοπάτια."
        case .crystalCave: return "Κοτσύφι: Πρόσεχε τους βράχους. Χρειαζόμαστε πέντε κρυστάλλους και δύο κλειδιά."
        case .nightForest: return "Κοτσύφι: Τα τέσσερα κομμάτια του χάρτη και δύο Χρυσά Φτερά θα μας οδηγήσουν στην Αλεπού."
        case .foxArea: return "Κοτσύφι: Τη βρήκαμε. Πλησίασε την Αλεπού και άκου τι έχει να μας πει."
        }
    }

    private var kotsifiEnglishMessage: String {
        switch gameState.area {
        case .forest:
            if gameState.rescuedAnimals == 0 { return "Kotsifi: Listen! A little animal needs help. Let's find it before we search for the great chest." }
            if gameState.memoryPuzzlesSolved == 0 { return "Kotsifi: I see a chest with a magic lock. I think a memory game will open it!" }
            return "Kotsifi: We're close! Stay on the paths and finish whatever is left in the quest."
        case .village: return "Kotsifi: The villagers need lots of supplies. Search near the trees and paths."
        case .crystalCave: return "Kotsifi: Watch the rocks. We need five crystals and two keys."
        case .nightForest: return "Kotsifi: Four map pieces and two Golden Feathers will lead us to the Fox."
        case .foxArea: return "Kotsifi: We found her. Walk up to the Fox and hear what she has to say."
        }
    }
}
