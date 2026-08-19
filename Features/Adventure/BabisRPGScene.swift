import SpriteKit
import UIKit

final class BabisRPGScene: SKScene, SKPhysicsContactDelegate {
    private enum Category {
        static let player: UInt32 = 1 << 0
        static let obstacle: UInt32 = 1 << 1
        static let collectible: UInt32 = 1 << 2
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
    private let worldSize = CGSize(width: 4200, height: 2800)

    private var joystickVector = CGVector.zero
    private var joystickMagnitude: CGFloat = 0
    private var lastUpdateTime: TimeInterval = 0
    private var animationTime: TimeInterval = 0
    private var companionAnimationTime: TimeInterval = 0
    private var animationFrame = 0
    private var companionFrame = 0
    private var movementState: MovementState = .idle
    private var facingAway = false
    private var interactionNodes: [SKSpriteNode] = []
    private weak var nearbyInteractionNode: SKSpriteNode?
    private weak var activeChallengeNode: SKSpriteNode?
    private weak var pinchGesture: UIPinchGestureRecognizer?
    private var isTransitioning = false

    private let minCameraScale: CGFloat = 0.35
    private let maxCameraScale: CGFloat = 1.65

    private lazy var idleTexture = texture(named: "babis_rpg_idle", fallback: "babis_rpg_master")
    private lazy var backIdleTexture = texture(named: "babis_rpg_back_idle", fallback: "babis_rpg_back_idle.", secondFallback: "babis_rpg_idle")
    private lazy var walkTextures: [SKTexture] = (1...4).map { texture(named: String(format: "babis_rpg_walk_%02d", $0), fallback: "babis_rpg_idle") }
    private lazy var runTextures: [SKTexture] = (1...4).map { texture(named: String(format: "babis_rpg_run_%02d", $0), fallback: "babis_rpg_idle") }
    private lazy var backWalkTextures: [SKTexture] = (1...4).map { texture(named: String(format: "babis_rpg_back_walk_%02d", $0), fallback: "babis_rpg_walk_01") }
    private lazy var backRunTextures: [SKTexture] = (1...4).map { texture(named: String(format: "babis_rpg_back_run_%02d", $0), fallback: "babis_rpg_run_01") }

    private lazy var companionIdleTexture = texture(named: "kotsifi_rpg_idle", fallback: "kotsifi_rpg_master")
    private lazy var companionBackIdleTexture = texture(named: "kotsifi_rpg_back_idle", fallback: "kotsifi_rpg_idle")
    private lazy var companionFlyTextures: [SKTexture] = (1...4).map { texture(named: String(format: "kotsifi_rpg_fly_%02d", $0), fallback: "kotsifi_rpg_idle") }
    private lazy var companionBackFlyTextures: [SKTexture] = (1...4).map { texture(named: String(format: "kotsifi_rpg_back_fly_%02d", $0), fallback: "kotsifi_rpg_fly_01") }

    private let routePoints: [CGPoint] = [
        .init(x: 420, y: 360), .init(x: 680, y: 520), .init(x: 930, y: 720), .init(x: 1220, y: 560),
        .init(x: 1480, y: 820), .init(x: 1770, y: 1040), .init(x: 2050, y: 820), .init(x: 2320, y: 1120),
        .init(x: 2600, y: 1360), .init(x: 2890, y: 1160), .init(x: 3170, y: 1450), .init(x: 3450, y: 1670),
        .init(x: 3700, y: 1940), .init(x: 3440, y: 2190), .init(x: 3130, y: 2350), .init(x: 2820, y: 2160),
        .init(x: 2500, y: 2390), .init(x: 2190, y: 2150), .init(x: 1870, y: 2380), .init(x: 1560, y: 2190),
        .init(x: 1280, y: 2420), .init(x: 980, y: 2180), .init(x: 700, y: 2390), .init(x: 520, y: 2050),
        .init(x: 780, y: 1780), .init(x: 1080, y: 1580), .init(x: 1380, y: 1760), .init(x: 1680, y: 1510),
        .init(x: 1980, y: 1710), .init(x: 2280, y: 1530), .init(x: 2580, y: 1780), .init(x: 2910, y: 1900)
    ]

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
        cameraNode.setScale(1.0)

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
        if let pinchGesture { view.removeGestureRecognizer(pinchGesture) }
        AudioManager.shared.stopMusic()
        SpeechManager.shared.stop()
    }

    func setMovementVector(_ vector: CGVector) {
        let magnitude = min(1, hypot(vector.dx, vector.dy))
        joystickMagnitude = magnitude
        if magnitude < 0.04 {
            joystickVector = .zero
        } else {
            joystickVector = CGVector(dx: vector.dx / magnitude, dy: vector.dy / magnitude)
        }
    }

    func stopMovement() {
        joystickVector = .zero
        joystickMagnitude = 0
        player.physicsBody?.velocity = .zero
        setMovementState(.idle)
    }

    func talkToCompanion() {
        guard !isTransitioning else { return }
        let greek: String
        let english: String
        switch gameState.area {
        case .forest:
            greek = "Ψάξε και τα μικρά μονοπάτια. Το κουνελάκι μπορεί να είναι πίσω από τους μεγάλους βράχους."
            english = "Check the smaller paths too. The rabbit may be behind the large rocks."
        case .rescueClearing:
            greek = "Άκου προσεκτικά! Το σκαντζοχοιράκι και το ελαφάκι είναι σε διαφορετικές πλευρές του ξέφωτου."
            english = "Listen carefully! The hedgehog and deer are on different sides of the clearing."
        case .village:
            greek = "Στο χωριό υπάρχουν κρυφές διαδρομές ανάμεσα στα σπίτια. Μην ξεχάσεις το σεντούκι."
            english = "There are hidden routes between the village houses. Do not forget the chest."
        case .riverCrossing:
            greek = "Μείνε πάνω στα μονοπάτια και στη γέφυρα. Το νερό δεν είναι δρόμος για τον Μπάμπη!"
            english = "Stay on the paths and bridge. The water is not a road for Babis!"
        case .puzzleClearing:
            greek = "Εδώ χρειάζεται μυαλό! Θα βρεις διαφορετικούς γρίφους με αριθμούς, σχήματα και μνήμη."
            english = "This place needs brain power! You will find number, shape and memory puzzles."
        case .crystalCave:
            greek = "Οι πιο φωτεινοί κρύσταλλοι δείχνουν τον δρόμο. Ψάξε βαθιά για τα κλειδιά."
            english = "The brightest crystals show the way. Search deep for the keys."
        case .nightForest:
            greek = "Ακολούθησε τα Χρυσά Φτερά. Είναι σαν μικρά φώτα μέσα στη νύχτα."
            english = "Follow the Golden Feathers. They are like little lights in the night."
        case .unicornGrove:
            greek = "Ο μονόκερος χρειάζεται τη μαγεία των κρυστάλλων. Λύσε πρώτα τους γρίφους του άλσους."
            english = "The unicorn needs crystal magic. Solve the grove's puzzles first."
        case .treasureClearing:
            greek = "Μην ανοίγεις μόνο ό,τι βλέπεις πρώτο. Υπάρχουν τρία διαφορετικά σεντούκια εδώ."
            english = "Do not open only the first thing you see. Three different chests are hidden here."
        case .foxDen:
            greek = "Η Αλεπού έχει κάτι να σου πει. Πλησίασέ την ήρεμα και άκουσέ την."
            english = "The Fox has something to tell you. Approach calmly and listen."
        }
        gameState.setMessage(greek: greek, english: english)
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
            openTreasure(node)
            return
        }

        if name.hasPrefix("npc:") {
            interactWithAnimal(node)
            return
        }

        switch name {
        case "unicorn:worried":
            gameState.helpUnicorn()
            node.texture = SKTexture(imageNamed: "unicorn_rpg_happy")
            node.name = "unicorn:happy"
            showHeart(over: node, symbol: "✨")
            SpeechManager.shared.speak(text: gameState.message)

        case "unicorn:happy":
            node.texture = SKTexture(imageNamed: "unicorn_rpg_talking")
            gameState.setMessage(
                greek: "Σε ευχαριστώ! Η μαγεία μου επέστρεψε. Ο μεγάλος θησαυρός βρίσκεται πιο πέρα!",
                english: "Thank you! My magic is back. The great treasure is farther ahead!"
            )
            SpeechManager.shared.speak(text: gameState.message)
            returnTexture(node, asset: "unicorn_rpg_happy")

        case "fox":
            gameState.meetFox()
            node.texture = texture(named: "fox_talking", fallback: "fox_friendly")
            SpeechManager.shared.speak(text: gameState.message)

        case "area_exit":
            guard gameState.areaGoalComplete else {
                AudioManager.shared.play(.wrong)
                gameState.setMessage(
                    greek: "Δεν τελειώσαμε ακόμη. Κοίτα τους στόχους επάνω και εξερεύνησε όλη την περιοχή.",
                    english: "We are not done yet. Check the objectives above and explore the whole area."
                )
                SpeechManager.shared.speak(text: gameState.message)
                return
            }

            isTransitioning = true
            let finishing = gameState.area == .foxDen
            gameState.advanceArea()
            SpeechManager.shared.speak(text: gameState.message)
            if finishing {
                node.texture = SKTexture(imageNamed: "rpg_chest_crystal_open")
                isTransitioning = false
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
                    guard let self else { return }
                    self.loadArea(self.gameState.area)
                }
            }

        default:
            break
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

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard !isTransitioning else { return }
        if gesture.state == .began || gesture.state == .changed {
            let proposed = cameraNode.xScale / gesture.scale
            cameraNode.setScale(min(maxCameraScale, max(minCameraScale, proposed)))
            gesture.scale = 1
        }
    }

    private func loadArea(_ area: RPGArea) {
        isTransitioning = true
        stopMovement()
        world.removeAllChildren()
        interactionNodes.removeAll()
        nearbyInteractionNode = nil
        activeChallengeNode = nil
        gameState.nearbyAction = nil

        let background = SKSpriteNode(imageNamed: area.groundAsset)
        background.size = worldSize
        background.position = CGPoint(x: worldSize.width / 2, y: worldSize.height / 2)
        background.zPosition = -2000
        world.addChild(background)

        addWorldBorder()
        addAreaCollisionZones(area)
        addCommonEnvironment(for: area)

        switch area {
        case .forest: buildForest()
        case .rescueClearing: buildRescueClearing()
        case .village: buildVillage()
        case .riverCrossing: buildRiverCrossing()
        case .puzzleClearing: buildPuzzleClearing()
        case .crystalCave: buildCrystalCave()
        case .nightForest: buildNightForest()
        case .unicornGrove: buildUnicornGrove()
        case .treasureClearing: buildTreasureClearing()
        case .foxDen: buildFoxDen()
        }

        setupPlayer(at: CGPoint(x: 360, y: 320))
        setupCompanion()
        cameraNode.position = player.position
        cameraNode.setScale(1.0)
        gameState.setMessageForCurrentArea()
        isTransitioning = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            guard let self, !self.isTransitioning else { return }
            SpeechManager.shared.speak(text: self.gameState.message)
        }
    }

    private func buildForest() {
        addCollectibles(kind: "apple", asset: "apple_item", count: 12, start: 1, step: 2, size: 74)
        addCollectibles(kind: "wood", asset: "log", count: 8, start: 4, step: 3, size: 86)
        addCollectibles(kind: "water", asset: "water_item", count: 6, start: 7, step: 4, size: 72)
        addAnimal(kind: "rabbit", worried: "rabbit_rpg_worried", at: CGPoint(x: 2950, y: 2240), size: 165)
        addPuzzle(.memory, at: CGPoint(x: 2160, y: 1430))
        addExit(at: CGPoint(x: 3880, y: 2450), asset: "rpg_chest_wood_closed")
    }

    private func buildRescueClearing() {
        addCollectibles(kind: "berries", asset: "berries_item", count: 12, start: 2, step: 2, size: 72)
        addCollectibles(kind: "carrot", asset: "carrot_item", count: 10, start: 5, step: 3, size: 72)
        addAnimal(kind: "hedgehog", worried: "hedgehog_rpg_worried", at: CGPoint(x: 980, y: 2240), size: 165)
        addAnimal(kind: "deer", worried: "deer_rpg_worried", at: CGPoint(x: 3160, y: 1830), size: 180)
        addPuzzle(.shapes, at: CGPoint(x: 2060, y: 1120))
        addTreasure(style: "wood", at: CGPoint(x: 3400, y: 2380), id: 1)
        addExit(at: CGPoint(x: 3900, y: 520), asset: "rpg_chest_wood_closed")
    }

    private func buildVillage() {
        addObstacle(asset: "rpg_village_house_01", at: CGPoint(x: 1050, y: 2050), size: CGSize(width: 620, height: 560), collisionScale: 0.64)
        addObstacle(asset: "rpg_village_house_02", at: CGPoint(x: 3010, y: 1910), size: CGSize(width: 650, height: 570), collisionScale: 0.64)
        addCollectibles(kind: "wood", asset: "log", count: 12, start: 1, step: 2, size: 84)
        addCollectibles(kind: "berries", asset: "berries_item", count: 10, start: 8, step: 3, size: 70)
        addCollectibles(kind: "carrot", asset: "carrot_item", count: 10, start: 4, step: 3, size: 70)
        addAnimal(kind: "squirrel", worried: "squirrel_rpg_worried", at: CGPoint(x: 2350, y: 2310), size: 165)
        addPuzzle(.words, at: CGPoint(x: 1650, y: 1180))
        addTreasure(style: "wood", at: CGPoint(x: 3500, y: 950), id: 1)
        addExit(at: CGPoint(x: 3900, y: 2450), asset: "rpg_chest_magic_closed")
    }

    private func buildRiverCrossing() {
        addCollectibles(kind: "water", asset: "water_item", count: 12, start: 1, step: 2, size: 72)
        addCollectibles(kind: "wood", asset: "log", count: 10, start: 6, step: 3, size: 84)
        addCollectibles(kind: "key", asset: "key_item", count: 3, start: 13, step: 7, size: 70)
        addAnimal(kind: "deer", worried: "deer_rpg_worried", at: CGPoint(x: 3300, y: 2160), size: 180)
        addPuzzle(.numbers, at: CGPoint(x: 2380, y: 1450))
        addExit(at: CGPoint(x: 3840, y: 2440), asset: "rpg_chest_magic_closed")
    }

    private func buildPuzzleClearing() {
        addCollectibles(kind: "crystal", asset: "crystal_item", count: 10, start: 1, step: 3, size: 75)
        addCollectibles(kind: "key", asset: "key_item", count: 5, start: 5, step: 6, size: 70)
        addPuzzle(.memory, at: CGPoint(x: 1120, y: 1980))
        addPuzzle(.numbers, at: CGPoint(x: 2150, y: 1460))
        addPuzzle(.shapes, at: CGPoint(x: 3150, y: 2070))
        addTreasure(style: "wood", at: CGPoint(x: 720, y: 2360), id: 1)
        addTreasure(style: "magic", at: CGPoint(x: 3470, y: 850), id: 2)
        addExit(at: CGPoint(x: 3850, y: 2420), asset: "rpg_chest_magic_closed")
    }

    private func buildCrystalCave() {
        addObstacle(asset: "rpg_crystal_cave_entrance", at: CGPoint(x: 2200, y: 2420), size: CGSize(width: 760, height: 520), collisionScale: 0.60)
        addCollectibles(kind: "crystal", asset: "crystal_item", count: 18, start: 0, step: 2, size: 78)
        addCollectibles(kind: "key", asset: "key_item", count: 6, start: 7, step: 5, size: 70)
        addAnimal(kind: "hedgehog", worried: "hedgehog_rpg_worried", at: CGPoint(x: 3240, y: 2200), size: 165)
        addPuzzle(.words, at: CGPoint(x: 1280, y: 1480))
        addPuzzle(.shapes, at: CGPoint(x: 2800, y: 1260))
        addTreasure(style: "crystal", at: CGPoint(x: 3500, y: 2350), id: 1)
        addExit(at: CGPoint(x: 3900, y: 520), asset: "rpg_chest_crystal_closed")
    }

    private func buildNightForest() {
        addCollectibles(kind: "fragment", asset: "map_fragment", count: 12, start: 1, step: 2, size: 76)
        addCollectibles(kind: "feather", asset: "golden_feather", count: 8, start: 8, step: 3, size: 72)
        addAnimal(kind: "squirrel", worried: "squirrel_rpg_worried", at: CGPoint(x: 1000, y: 2200), size: 165)
        addAnimal(kind: "owl", worried: "owl_rpg_neutral", at: CGPoint(x: 3190, y: 2100), size: 160)
        addPuzzle(.memory, at: CGPoint(x: 2230, y: 1450))
        addExit(at: CGPoint(x: 3900, y: 2450), asset: "rpg_chest_magic_closed")
    }

    private func buildUnicornGrove() {
        addCollectibles(kind: "crystal", asset: "crystal_item", count: 12, start: 0, step: 2, size: 78)
        addCollectibles(kind: "fragment", asset: "map_fragment", count: 7, start: 7, step: 4, size: 76)
        addPuzzle(.numbers, at: CGPoint(x: 1220, y: 1960))
        addPuzzle(.words, at: CGPoint(x: 2920, y: 1370))
        addTreasure(style: "magic", at: CGPoint(x: 3440, y: 2240), id: 1)
        addNPC(asset: "unicorn_rpg_worried", name: "unicorn:worried", at: CGPoint(x: 2200, y: 2220), size: 210, action: .unicorn)
        addExit(at: CGPoint(x: 3900, y: 520), asset: "rpg_chest_magic_closed")
    }

    private func buildTreasureClearing() {
        addCollectibles(kind: "key", asset: "key_item", count: 8, start: 2, step: 3, size: 72)
        addCollectibles(kind: "crystal", asset: "crystal_item", count: 12, start: 1, step: 2, size: 78)
        addPuzzle(.shapes, at: CGPoint(x: 1180, y: 1760))
        addPuzzle(.numbers, at: CGPoint(x: 2830, y: 1720))
        addTreasure(style: "wood", at: CGPoint(x: 760, y: 2350), id: 1)
        addTreasure(style: "magic", at: CGPoint(x: 2180, y: 2140), id: 2)
        addTreasure(style: "crystal", at: CGPoint(x: 3460, y: 2320), id: 3)
        addExit(at: CGPoint(x: 3900, y: 500), asset: "rpg_chest_crystal_closed")
    }

    private func buildFoxDen() {
        addPuzzle(.words, at: CGPoint(x: 1340, y: 1740))
        addTreasure(style: "crystal", at: CGPoint(x: 3200, y: 2110), id: 1)
        addNPC(asset: "fox_friendly", name: "fox", at: CGPoint(x: 2350, y: 2220), size: 190, action: .fox)
        addExit(at: CGPoint(x: 3860, y: 520), asset: "rpg_chest_crystal_closed")
    }

    private func addCommonEnvironment(for area: RPGArea) {
        let treeAssets = ["rpg_tree_large_01", "rpg_tree_large_02", "rpg_tree_large_03"]
        let treePositions: [CGPoint] = [
            .init(x: 610, y: 980), .init(x: 1030, y: 1300), .init(x: 1620, y: 1040),
            .init(x: 2700, y: 780), .init(x: 3260, y: 1080), .init(x: 3650, y: 1510),
            .init(x: 730, y: 1680), .init(x: 1780, y: 2020), .init(x: 2860, y: 2140)
        ]
        for (index, point) in treePositions.enumerated() {
            addObstacle(asset: treeAssets[index % treeAssets.count], at: point, size: CGSize(width: 310, height: 390), collisionScale: 0.52)
        }

        let bushes: [CGPoint] = [
            .init(x: 1220, y: 940), .init(x: 1500, y: 1900), .init(x: 2460, y: 920),
            .init(x: 3000, y: 1540), .init(x: 940, y: 2500), .init(x: 3370, y: 2480)
        ]
        for (index, point) in bushes.enumerated() {
            addObstacle(asset: index.isMultiple(of: 2) ? "rpg_bush_tall_01" : "rpg_bush_tall_02", at: point, size: CGSize(width: 210, height: 190), collisionScale: 0.58)
        }

        let rocks: [CGPoint] = [.init(x: 2050, y: 520), .init(x: 2480, y: 2050), .init(x: 3520, y: 760), .init(x: 520, y: 2250)]
        rocks.forEach { addObstacle(asset: "rpg_rock_large", at: $0, size: CGSize(width: 210, height: 190), collisionScale: 0.70) }

        addDecor(asset: "rpg_fallen_tree", at: CGPoint(x: 1510, y: 1180), size: CGSize(width: 310, height: 180), collidable: true)
        addDecor(asset: "rpg_tree_stump", at: CGPoint(x: 3040, y: 620), size: CGSize(width: 170, height: 150), collidable: true)
        addDecor(asset: "rpg_flowers_01", at: CGPoint(x: 1980, y: 2480), size: CGSize(width: 210, height: 130), collidable: false)
        addDecor(asset: "rpg_grass_patch_01", at: CGPoint(x: 3500, y: 1200), size: CGSize(width: 230, height: 140), collidable: false)
        addDecor(asset: "rpg_grass_patch_02", at: CGPoint(x: 560, y: 1450), size: CGSize(width: 230, height: 140), collidable: false)

        if area == .riverCrossing {
            addObstacle(asset: "rpg_pond", at: CGPoint(x: 2000, y: 2100), size: CGSize(width: 760, height: 500), collisionScale: 0.82)
        }
    }

    private func addWorldBorder() {
        let borderThickness: CGFloat = 120
        addInvisibleObstacle(at: CGPoint(x: worldSize.width / 2, y: 45), size: CGSize(width: worldSize.width, height: borderThickness))
        addInvisibleObstacle(at: CGPoint(x: worldSize.width / 2, y: worldSize.height - 45), size: CGSize(width: worldSize.width, height: borderThickness))
        addInvisibleObstacle(at: CGPoint(x: 45, y: worldSize.height / 2), size: CGSize(width: borderThickness, height: worldSize.height))
        addInvisibleObstacle(at: CGPoint(x: worldSize.width - 45, y: worldSize.height / 2), size: CGSize(width: borderThickness, height: worldSize.height))
    }

    private func addAreaCollisionZones(_ area: RPGArea) {
        let zones: [(CGPoint, CGSize)]
        switch area {
        case .forest, .unicornGrove:
            zones = [
                (.init(x: 450, y: 2580), .init(width: 700, height: 260)),
                (.init(x: 3700, y: 2600), .init(width: 650, height: 250)),
                (.init(x: 410, y: 1220), .init(width: 420, height: 620)),
                (.init(x: 3800, y: 1220), .init(width: 420, height: 620))
            ]
        case .rescueClearing, .puzzleClearing, .treasureClearing:
            zones = [
                (.init(x: 500, y: 2620), .init(width: 760, height: 230)),
                (.init(x: 3650, y: 2600), .init(width: 760, height: 230)),
                (.init(x: 420, y: 1250), .init(width: 340, height: 680)),
                (.init(x: 3820, y: 1280), .init(width: 340, height: 680))
            ]
        case .village:
            zones = [
                (.init(x: 1050, y: 2050), .init(width: 520, height: 430)),
                (.init(x: 3010, y: 1910), .init(width: 540, height: 440))
            ]
        case .riverCrossing:
            zones = [
                (.init(x: 650, y: 2100), .init(width: 900, height: 420)),
                (.init(x: 3550, y: 820), .init(width: 900, height: 420))
            ]
        case .crystalCave:
            zones = [
                (.init(x: 420, y: 1550), .init(width: 300, height: 1000)),
                (.init(x: 3820, y: 1550), .init(width: 300, height: 1000))
            ]
        case .nightForest:
            zones = [
                (.init(x: 500, y: 2550), .init(width: 850, height: 260)),
                (.init(x: 3670, y: 2500), .init(width: 800, height: 260))
            ]
        case .foxDen:
            zones = [
                (.init(x: 2100, y: 2520), .init(width: 1200, height: 300)),
                (.init(x: 520, y: 1440), .init(width: 420, height: 720))
            ]
        }
        zones.forEach { addInvisibleObstacle(at: $0.0, size: $0.1) }
    }

    private func setupPlayer(at position: CGPoint) {
        player.removeFromParent()
        player.texture = idleTexture
        player.size = CGSize(width: 150, height: 150)
        player.position = position
        player.anchorPoint = CGPoint(x: 0.5, y: 0.30)
        player.zPosition = depth(forY: position.y)

        let body = SKPhysicsBody(circleOfRadius: 38, center: CGPoint(x: 0, y: -18))
        body.isDynamic = true
        body.allowsRotation = false
        body.restitution = 0
        body.friction = 0
        body.linearDamping = 8
        body.categoryBitMask = Category.player
        body.collisionBitMask = Category.obstacle
        body.contactTestBitMask = Category.collectible
        player.physicsBody = body
        world.addChild(player)
    }

    private func setupCompanion() {
        companion.removeFromParent()
        companion.texture = companionIdleTexture
        companion.size = CGSize(width: 92, height: 92)
        companion.position = CGPoint(x: player.position.x - 95, y: player.position.y + 110)
        companion.zPosition = player.zPosition + 4
        world.addChild(companion)
    }

    private func addCollectibles(kind: String, asset: String, count: Int, start: Int, step: Int, size: CGFloat) {
        var used = Set<Int>()
        var index = start
        for _ in 0..<count {
            var safeIndex = abs(index) % routePoints.count
            while used.contains(safeIndex) { safeIndex = (safeIndex + 1) % routePoints.count }
            used.insert(safeIndex)
            let base = routePoints[safeIndex]
            let offsetX = CGFloat((safeIndex % 3) - 1) * 42
            let offsetY = CGFloat((safeIndex % 4) - 2) * 34
            addCollectible(asset: asset, kind: kind, at: CGPoint(x: base.x + offsetX, y: base.y + offsetY), size: size)
            index += step
        }
    }

    private func addCollectible(asset: String, kind: String, at position: CGPoint, size: CGFloat) {
        let node = SKSpriteNode(imageNamed: asset)
        node.name = "collect:\(kind)"
        node.size = CGSize(width: size, height: size)
        node.position = position
        node.zPosition = depth(forY: position.y) + 2
        node.physicsBody = SKPhysicsBody(circleOfRadius: max(20, size * 0.28))
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = Category.collectible
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.contactTestBitMask = Category.player
        world.addChild(node)
        node.run(.repeatForever(.sequence([
            .moveBy(x: 0, y: 8, duration: 0.75),
            .moveBy(x: 0, y: -8, duration: 0.75)
        ])))
    }

    private func addAnimal(kind: String, worried: String, at position: CGPoint, size: CGFloat) {
        addNPC(asset: worried, name: "npc:\(kind):worried", at: position, size: size, action: .animalRescue)
    }

    private func addNPC(asset: String, name: String, at position: CGPoint, size: CGFloat, action: RPGNearbyAction) {
        let node = SKSpriteNode(imageNamed: asset)
        node.name = name
        node.userData = NSMutableDictionary()
        node.userData?["action"] = actionKey(action)
        node.size = CGSize(width: size, height: size)
        node.position = position
        node.zPosition = depth(forY: position.y) + 3
        world.addChild(node)
        interactionNodes.append(node)
    }

    private func addPuzzle(_ challenge: RPGChallenge, at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "rpg_chest_magic_closed")
        node.name = "puzzle:\(challenge.rawValue):\(UUID().uuidString)"
        node.userData = NSMutableDictionary()
        node.userData?["action"] = actionKey(.puzzle)
        node.size = CGSize(width: 145, height: 125)
        node.position = position
        node.zPosition = depth(forY: position.y) + 3
        world.addChild(node)
        interactionNodes.append(node)
    }

    private func addTreasure(style: String, at position: CGPoint, id: Int) {
        let closed: String
        switch style {
        case "magic": closed = "rpg_chest_magic_closed"
        case "crystal": closed = "rpg_chest_crystal_closed"
        default: closed = "rpg_chest_wood_closed"
        }
        let node = SKSpriteNode(imageNamed: closed)
        node.name = "treasure:\(style):\(id)"
        node.userData = NSMutableDictionary()
        node.userData?["action"] = actionKey(.treasure)
        node.size = CGSize(width: 150, height: 126)
        node.position = position
        node.zPosition = depth(forY: position.y) + 3
        world.addChild(node)
        interactionNodes.append(node)
    }

    private func addExit(at position: CGPoint, asset: String) {
        let node = SKSpriteNode(imageNamed: asset)
        node.name = "area_exit"
        node.userData = NSMutableDictionary()
        node.userData?["action"] = actionKey(.exit)
        node.size = CGSize(width: 175, height: 145)
        node.position = position
        node.zPosition = depth(forY: position.y) + 4
        world.addChild(node)
        interactionNodes.append(node)

        let glow = SKShapeNode(circleOfRadius: 105)
        glow.strokeColor = UIColor.systemYellow.withAlphaComponent(0.65)
        glow.lineWidth = 6
        glow.fillColor = .clear
        glow.zPosition = -1
        node.addChild(glow)
        glow.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.25, duration: 0.8),
            .fadeAlpha(to: 0.9, duration: 0.8)
        ])))
    }

    private func addObstacle(asset: String, at position: CGPoint, size: CGSize, collisionScale: CGFloat) {
        let node = SKSpriteNode(imageNamed: asset)
        node.size = size
        node.position = position
        node.zPosition = depth(forY: position.y)
        let collisionSize = CGSize(width: size.width * collisionScale, height: size.height * collisionScale * 0.48)
        node.physicsBody = SKPhysicsBody(rectangleOf: collisionSize, center: CGPoint(x: 0, y: -size.height * 0.18))
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = Category.obstacle
        node.physicsBody?.collisionBitMask = Category.player
        world.addChild(node)
    }

    private func addDecor(asset: String, at position: CGPoint, size: CGSize, collidable: Bool) {
        if collidable {
            addObstacle(asset: asset, at: position, size: size, collisionScale: 0.65)
        } else {
            let node = SKSpriteNode(imageNamed: asset)
            node.size = size
            node.position = position
            node.zPosition = depth(forY: position.y) - 1
            world.addChild(node)
        }
    }

    private func addInvisibleObstacle(at position: CGPoint, size: CGSize) {
        let node = SKSpriteNode(color: .clear, size: size)
        node.position = position
        node.zPosition = -1500
        node.physicsBody = SKPhysicsBody(rectangleOf: size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = Category.obstacle
        node.physicsBody?.collisionBitMask = Category.player
        world.addChild(node)
    }

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
            let greek = animalTalkingGreek(kind)
            let english = "Thank you, Babis! Keep following the path and help the other forest friends too."
            gameState.setMessage(greek: greek, english: english)
            SpeechManager.shared.speak(text: gameState.message)
            returnTexture(node, asset: happyAsset(for: kind))
        }
    }

    private func openTreasure(_ node: SKSpriteNode) {
        guard let name = node.name else { return }
        let parts = name.split(separator: ":")
        let style = parts.count > 1 ? String(parts[1]) : "wood"
        let openAsset: String
        switch style {
        case "magic": openAsset = "rpg_chest_magic_open"
        case "crystal": openAsset = "rpg_chest_crystal_open"
        default: openAsset = "rpg_chest_wood_open"
        }
        node.texture = SKTexture(imageNamed: openAsset)
        node.name = "treasure:opened"
        interactionNodes.removeAll { $0 === node }
        nearbyInteractionNode = nil
        gameState.nearbyAction = nil
        gameState.openTreasure()
        showRewardBurst(at: node.position, asset: style == "crystal" ? "rpg_treasure_gems" : "rpg_treasure_coin_pile")
        SpeechManager.shared.speak(text: gameState.message)
    }

    private func showRewardBurst(at position: CGPoint, asset: String) {
        let reward = SKSpriteNode(imageNamed: asset)
        reward.size = CGSize(width: 150, height: 120)
        reward.position = CGPoint(x: position.x, y: position.y + 100)
        reward.zPosition = 20000
        world.addChild(reward)
        reward.setScale(0.3)
        reward.alpha = 0
        reward.run(.sequence([
            .group([.fadeIn(withDuration: 0.18), .scale(to: 1.15, duration: 0.28), .moveBy(x: 0, y: 35, duration: 0.28)]),
            .wait(forDuration: 0.65),
            .group([.fadeOut(withDuration: 0.30), .scale(to: 0.45, duration: 0.30), .moveBy(x: 150, y: 130, duration: 0.30)]),
            .removeFromParent()
        ]))
    }

    private func showHeart(over node: SKSpriteNode, symbol: String) {
        let label = SKLabelNode(text: symbol)
        label.fontSize = 52
        label.position = CGPoint(x: node.position.x, y: node.position.y + node.size.height * 0.65)
        label.zPosition = 22000
        world.addChild(label)
        label.run(.sequence([
            .group([.moveBy(x: 0, y: 55, duration: 0.75), .scale(to: 1.4, duration: 0.75)]),
            .fadeOut(withDuration: 0.35),
            .removeFromParent()
        ]))
    }

    private func returnTexture(_ node: SKSpriteNode, asset: String) {
        node.run(.sequence([
            .wait(forDuration: 1.5),
            .run { [weak node] in node?.texture = SKTexture(imageNamed: asset) }
        ]))
    }

    override func update(_ currentTime: TimeInterval) {
        let delta: TimeInterval
        if lastUpdateTime == 0 { delta = 1.0 / 60.0 } else { delta = min(1.0 / 20.0, currentTime - lastUpdateTime) }
        lastUpdateTime = currentTime

        updatePlayerMovement(delta: delta)
        updateAnimations(delta: delta)
        updateCompanion(delta: delta)
        updateCamera(delta: delta)
        updateNearbyInteraction()
    }

    private func updatePlayerMovement(delta: TimeInterval) {
        guard !isTransitioning, let body = player.physicsBody else { return }
        if joystickMagnitude < 0.04 {
            body.velocity = .zero
            setMovementState(.idle)
            return
        }

        let speed: CGFloat = joystickMagnitude > 0.72 ? 360 : 245
        body.velocity = CGVector(dx: joystickVector.dx * speed, dy: joystickVector.dy * speed)
        setMovementState(joystickMagnitude > 0.72 ? .running : .walking)

        if joystickVector.dy > 0.22 { facingAway = true }
        if joystickVector.dy < -0.22 { facingAway = false }
        if abs(joystickVector.dx) > 0.15 { player.xScale = joystickVector.dx < 0 ? -1 : 1 }
        player.zPosition = depth(forY: player.position.y)
    }

    private func updateAnimations(delta: TimeInterval) {
        animationTime += delta
        let interval: TimeInterval = movementState == .running ? 0.10 : 0.15
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
        let follow = min(1, CGFloat(delta) * 4.8)
        companion.position.x += (targetX - companion.position.x) * follow
        companion.position.y += (targetY - companion.position.y) * follow
        companion.zPosition = depth(forY: companion.position.y) + 6
        companion.xScale = player.xScale

        companionAnimationTime += delta
        if joystickMagnitude > 0.04 {
            if companionAnimationTime > 0.12 {
                companionAnimationTime = 0
                companionFrame = (companionFrame + 1) % 4
                companion.texture = facingAway ? companionBackFlyTextures[companionFrame] : companionFlyTextures[companionFrame]
            }
        } else {
            companion.texture = facingAway ? companionBackIdleTexture : companionIdleTexture
        }
    }

    private func updateCamera(delta: TimeInterval) {
        let follow = min(1, CGFloat(delta) * 5.0)
        cameraNode.position.x += (player.position.x - cameraNode.position.x) * follow
        cameraNode.position.y += (player.position.y - cameraNode.position.y) * follow
        cameraNode.position.x = min(worldSize.width - 120, max(120, cameraNode.position.x))
        cameraNode.position.y = min(worldSize.height - 120, max(120, cameraNode.position.y))
    }

    private func updateNearbyInteraction() {
        var closest: SKSpriteNode?
        var closestDistance: CGFloat = 190
        for node in interactionNodes where node.parent != nil {
            let distance = hypot(node.position.x - player.position.x, node.position.y - player.position.y)
            if distance < closestDistance {
                closestDistance = distance
                closest = node
            }
        }

        nearbyInteractionNode = closest
        guard let closest else {
            gameState.nearbyAction = nil
            return
        }

        if let key = closest.userData?["action"] as? String {
            gameState.nearbyAction = action(from: key)
        } else {
            gameState.nearbyAction = nil
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let first = contact.bodyA.node
        let second = contact.bodyB.node
        let collectible = collectibleNode(first) ?? collectibleNode(second)
        guard let node = collectible, let name = node.name, name.hasPrefix("collect:") else { return }
        let kind = String(name.dropFirst("collect:".count))
        node.name = nil
        node.physicsBody = nil
        gameState.collect(kind: kind)

        node.removeAllActions()
        node.run(.sequence([
            .group([
                .moveBy(x: 140, y: 170, duration: 0.35),
                .scale(to: 1.45, duration: 0.18),
                .fadeAlpha(to: 0.15, duration: 0.35)
            ]),
            .removeFromParent()
        ]))
    }

    private func collectibleNode(_ node: SKNode?) -> SKSpriteNode? {
        guard let sprite = node as? SKSpriteNode, sprite.name?.hasPrefix("collect:") == true else { return nil }
        return sprite
    }

    private func setMovementState(_ state: MovementState) {
        if movementState != state {
            movementState = state
            animationTime = 0
            animationFrame = 0
        }
    }

    private func depth(forY y: CGFloat) -> CGFloat {
        10000 - y
    }

    private func texture(named name: String, fallback: String, secondFallback: String? = nil) -> SKTexture {
        if UIImage(named: name) != nil { return SKTexture(imageNamed: name) }
        if UIImage(named: fallback) != nil { return SKTexture(imageNamed: fallback) }
        if let secondFallback, UIImage(named: secondFallback) != nil { return SKTexture(imageNamed: secondFallback) }
        return SKTexture(imageNamed: name)
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
        case "rabbit": return "Ευχαριστώ, Μπάμπη! Είδα ένα παράξενο σεντούκι πιο βαθιά στο δάσος."
        case "hedgehog": return "Σε ευχαριστώ! Πρόσεχε τους ψηλούς θάμνους — το μονοπάτι περνά γύρω τους."
        case "deer": return "Μπράβο! Το Κοτσύφι μπορεί να δει από ψηλά πού συνεχίζει ο δρόμος."
        case "squirrel": return "Ευχαριστώ! Έκρυψαν ένα κλειδί κοντά στους μεγάλους βράχους."
        case "owl": return "Άκουσε τα σημάδια του δάσους. Ο σωστός δρόμος δεν είναι πάντα ο πιο κοντός."
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
