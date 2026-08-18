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

    /// The gameplay world is deliberately larger than the visible landscape viewport.
    /// SpriteKit's camera follows Babis through this space rather than moving a flat screen-sized image.
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
    private weak var nearbyInteractionNode: SKSpriteNode?
    private var isTransitioning = false

    private lazy var idleTexture = texture(named: "babis_rpg_idle", fallback: "babis_neutral")
    private lazy var walkTextures: [SKTexture] = (1...4).map {
        texture(named: String(format: "babis_rpg_walk_%02d", $0), fallback: String(format: "babis_run_%02d", $0))
    }
    private lazy var runTextures: [SKTexture] = (1...4).map {
        texture(named: String(format: "babis_rpg_run_%02d", $0), fallback: String(format: "babis_run_%02d", $0))
    }
    private lazy var companionIdleTexture = texture(named: "kotsifi_rpg_idle", fallback: "kotsifi_idle")
    private lazy var companionFlyTextures: [SKTexture] = (1...4).map {
        texture(named: String(format: "kotsifi_rpg_fly_%02d", $0), fallback: String(format: "kotsifi_fly_%02d", min($0, 3)))
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
        cameraNode.setScale(1.06)

        physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: .zero, size: worldSize))
        physicsBody?.categoryBitMask = Category.obstacle
        loadArea(gameState.area)
    }

    // MARK: - Public controls

    /// Receives a normalized vector from the SwiftUI virtual joystick.
    /// The SpriteKit scene owns movement/physics; SwiftUI only owns the HUD/control surface.
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
        gameState.setMessage(greek: kotsifiGreekMessage, english: kotsifiEnglishMessage)
        AudioManager.shared.play(.storyNext)
    }

    func performInteraction() {
        guard !isTransitioning, let node = nearbyInteractionNode, let name = node.name else { return }
        stopMovement()

        switch name {
        case "area_exit":
            if gameState.areaGoalComplete {
                node.texture = SKTexture(imageNamed: "chest_open")
                gameState.setMessage(
                    greek: "Το σεντούκι άνοιξε! Περνάς στην επόμενη περιοχή.",
                    english: "The chest opened! Moving to the next area."
                )
                isTransitioning = true
                gameState.nearbyAction = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    self.gameState.advanceArea()
                    self.loadArea(self.gameState.area)
                }
            } else {
                AudioManager.shared.play(.wrong)
                gameState.setMessage(
                    greek: "Το σεντούκι είναι κλειδωμένο. Ολοκλήρωσε πρώτα την αποστολή της περιοχής.",
                    english: "The chest is locked. Complete the area quest first."
                )
            }

        case "final_fox":
            guard !gameState.questComplete else {
                gameState.setMessage(greek: "Η Αλεπού είναι πια φίλη σας.", english: "The Fox is your friend now.")
                return
            }

            node.texture = SKTexture(imageNamed: "fox_friendly")
            gameState.completeQuest()

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
        background.zPosition = -100
        world.addChild(background)

        switch area {
        case .forest: buildForest()
        case .village: buildVillage()
        case .crystalCave: buildCrystalCave()
        case .nightForest: buildNightForest()
        case .foxArea: buildFoxArea()
        }

        setupPlayer(at: CGPoint(x: 330, y: 320))
        setupCompanion()
        cameraNode.position = player.position
        gameState.setMessageForCurrentArea()
        isTransitioning = false
    }

    private func buildForest() {
        addCommonForestObstacles()

        addCollectible(asset: "apple_item", kind: "apple", at: CGPoint(x: 520, y: 1060), size: 72)
        addCollectible(asset: "apple_item", kind: "apple", at: CGPoint(x: 1260, y: 1230), size: 72)
        addCollectible(asset: "apple_item", kind: "apple", at: CGPoint(x: 1940, y: 810), size: 72)
        addCollectible(asset: "log", kind: "wood", at: CGPoint(x: 760, y: 380), size: 86)
        addCollectible(asset: "log", kind: "wood", at: CGPoint(x: 1720, y: 1310), size: 86)
        addCollectible(asset: "water_item", kind: "water", at: CGPoint(x: 1370, y: 460), size: 74)

        addExit(
            asset: "chest_closed",
            name: "area_exit",
            at: CGPoint(x: 2160, y: 1390),
            size: CGSize(width: 124, height: 108)
        )
    }

    private func buildVillage() {
        addObstacle(asset: "tree_01", at: CGPoint(x: 430, y: 1190), size: CGSize(width: 170, height: 220))
        addObstacle(asset: "tree_02", at: CGPoint(x: 1920, y: 1160), size: CGSize(width: 170, height: 220))
        addObstacle(asset: "wood_sign", at: CGPoint(x: 1110, y: 780), size: CGSize(width: 125, height: 110))
        addObstacle(asset: "tree_03", at: CGPoint(x: 2050, y: 510), size: CGSize(width: 170, height: 220))

        addCollectible(asset: "berries_item", kind: "berries", at: CGPoint(x: 690, y: 930), size: 74)
        addCollectible(asset: "berries_item", kind: "berries", at: CGPoint(x: 1580, y: 1030), size: 74)
        addCollectible(asset: "carrot_item", kind: "carrot", at: CGPoint(x: 1220, y: 430), size: 74)
        addCollectible(asset: "log", kind: "wood", at: CGPoint(x: 1860, y: 600), size: 86)

        addExit(
            asset: "chest_closed",
            name: "area_exit",
            at: CGPoint(x: 2150, y: 1390),
            size: CGSize(width: 124, height: 108)
        )
    }

    private func buildCrystalCave() {
        addObstacle(asset: "rock_01", at: CGPoint(x: 520, y: 1020), size: CGSize(width: 150, height: 122))
        addObstacle(asset: "rock_02", at: CGPoint(x: 1210, y: 930), size: CGSize(width: 150, height: 122))
        addObstacle(asset: "rock_01", at: CGPoint(x: 1870, y: 560), size: CGSize(width: 150, height: 122))
        addObstacle(asset: "rock_02", at: CGPoint(x: 760, y: 470), size: CGSize(width: 140, height: 116))

        addCollectible(asset: "crystal_item", kind: "crystal", at: CGPoint(x: 660, y: 1260), size: 78)
        addCollectible(asset: "crystal_item", kind: "crystal", at: CGPoint(x: 1450, y: 1240), size: 78)
        addCollectible(asset: "crystal_item", kind: "crystal", at: CGPoint(x: 1900, y: 1040), size: 78)
        addCollectible(asset: "key_item", kind: "key", at: CGPoint(x: 1220, y: 390), size: 76)

        addExit(
            asset: "chest_closed",
            name: "area_exit",
            at: CGPoint(x: 2160, y: 1390),
            size: CGSize(width: 128, height: 110)
        )
    }

    private func buildNightForest() {
        addCommonForestObstacles()

        addCollectible(asset: "map_fragment", kind: "fragment", at: CGPoint(x: 720, y: 1150), size: 82)
        addCollectible(asset: "map_fragment", kind: "fragment", at: CGPoint(x: 1660, y: 650), size: 82)
        addCollectible(asset: "golden_feather", kind: "feather", at: CGPoint(x: 1840, y: 1260), size: 80)

        addExit(
            asset: "chest_closed",
            name: "area_exit",
            at: CGPoint(x: 2160, y: 1380),
            size: CGSize(width: 128, height: 110)
        )
    }

    private func buildFoxArea() {
        addObstacle(asset: "tree_01", at: CGPoint(x: 500, y: 1160), size: CGSize(width: 175, height: 225))
        addObstacle(asset: "tree_03", at: CGPoint(x: 1780, y: 1140), size: CGSize(width: 175, height: 225))
        addObstacle(asset: "rock_02", at: CGPoint(x: 1120, y: 700), size: CGSize(width: 145, height: 115))
        addObstacle(asset: "bush_01", at: CGPoint(x: 760, y: 480), size: CGSize(width: 145, height: 110))

        addNPC(
            asset: "fox_worried",
            name: "final_fox",
            at: CGPoint(x: 1940, y: 1160),
            size: 145,
            interactive: true
        )
    }

    private func addCommonForestObstacles() {
        addObstacle(asset: "tree_01", at: CGPoint(x: 390, y: 1170), size: CGSize(width: 175, height: 225))
        addObstacle(asset: "tree_02", at: CGPoint(x: 820, y: 1290), size: CGSize(width: 178, height: 225))
        addObstacle(asset: "tree_03", at: CGPoint(x: 1840, y: 1100), size: CGSize(width: 170, height: 220))
        addObstacle(asset: "tree_01", at: CGPoint(x: 2110, y: 520), size: CGSize(width: 175, height: 225))
        addObstacle(asset: "rock_01", at: CGPoint(x: 1040, y: 700), size: CGSize(width: 135, height: 108))
        addObstacle(asset: "rock_02", at: CGPoint(x: 1510, y: 860), size: CGSize(width: 140, height: 112))
        addObstacle(asset: "bush_01", at: CGPoint(x: 570, y: 610), size: CGSize(width: 145, height: 110))
        addObstacle(asset: "bush_02", at: CGPoint(x: 1640, y: 430), size: CGSize(width: 145, height: 110))
    }

    // MARK: - Characters

    private func setupPlayer(at position: CGPoint) {
        player.removeFromParent()
        player.name = "player"
        player.position = position
        player.zPosition = 12
        player.anchorPoint = CGPoint(x: 0.5, y: 0.22)
        applyPlayerTexture(idleTexture)

        player.physicsBody = SKPhysicsBody(circleOfRadius: 38, center: CGPoint(x: 0, y: 22))
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 9
        player.physicsBody?.restitution = 0
        player.physicsBody?.categoryBitMask = Category.player
        player.physicsBody?.collisionBitMask = Category.obstacle | Category.interaction
        player.physicsBody?.contactTestBitMask = Category.collectible | Category.interaction
        world.addChild(player)
    }

    private func setupCompanion() {
        companion.removeFromParent()
        companion.name = "companion_kotsifi"
        companion.texture = companionIdleTexture
        companion.anchorPoint = CGPoint(x: 0.5, y: 0.2)
        companion.zPosition = 13
        companion.position = CGPoint(x: player.position.x - 105, y: player.position.y + 95)
        applyCompanionTexture(companionIdleTexture)
        world.addChild(companion)
    }

    // MARK: - World objects

    private func addObstacle(asset: String, at position: CGPoint, size: CGSize) {
        let node = SKSpriteNode(imageNamed: asset)
        node.size = size
        node.position = position
        node.zPosition = 2
        node.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: size.width * 0.62, height: size.height * 0.42),
            center: CGPoint(x: 0, y: -size.height * 0.2)
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
        node.zPosition = 6
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
        node.zPosition = 8

        if interactive {
            node.physicsBody = SKPhysicsBody(circleOfRadius: size * 0.42)
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
        node.zPosition = 7
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.9, height: size.height * 0.85))
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = Category.interaction
        node.physicsBody?.collisionBitMask = Category.player
        node.physicsBody?.contactTestBitMask = Category.player
        world.addChild(node)
    }

    // MARK: - Input and game loop

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !isTransitioning, joystickMagnitude < 0.04 else { return }
        moveTarget = touch.location(in: world)
    }

    override func update(_ currentTime: TimeInterval) {
        let dt = lastUpdateTime == 0 ? 0 : min(currentTime - lastUpdateTime, 1.0 / 20.0)
        lastUpdateTime = currentTime

        updateMovement(deltaTime: dt)
        updateCompanion(deltaTime: dt)
        updateCamera(deltaTime: dt)
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

        if abs(direction.dx) > 0.08 {
            player.xScale = direction.dx < 0 ? -1 : 1
        }

        setMovementState(requestedState)
        animationTime += deltaTime

        let interval: TimeInterval = requestedState == .running ? 0.085 : 0.135
        if animationTime >= interval {
            animationTime = 0
            animationFrame += 1
            let frames = requestedState == .running ? runTextures : walkTextures
            if !frames.isEmpty {
                applyPlayerTexture(frames[animationFrame % frames.count])
            }
        }
    }

    private func setMovementState(_ state: MovementState) {
        guard movementState != state else {
            if state == .idle, player.texture !== idleTexture {
                applyPlayerTexture(idleTexture)
            }
            return
        }

        movementState = state
        animationTime = 0
        animationFrame = 0

        if state == .idle {
            applyPlayerTexture(idleTexture)
        }
    }

    private func updateCompanion(deltaTime: TimeInterval) {
        guard companion.parent != nil else { return }

        let facingLeft = player.xScale < 0
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
            if !companionFlyTextures.isEmpty {
                applyCompanionTexture(companionFlyTextures[companionFrame])
            }
        }
    }

    private func updateCamera(deltaTime: TimeInterval) {
        let cameraScale = cameraNode.xScale
        let halfW = size.width * cameraScale / 2
        let halfH = size.height * cameraScale / 2

        let desired = CGPoint(
            x: min(max(player.position.x, halfW), worldSize.width - halfW),
            y: min(max(player.position.y, halfH), worldSize.height - halfH)
        )

        let factor = min(1, CGFloat(deltaTime) * 8.5)
        cameraNode.position.x += (desired.x - cameraNode.position.x) * factor
        cameraNode.position.y += (desired.y - cameraNode.position.y) * factor
    }

    // MARK: - Contacts

    func didBegin(_ contact: SKPhysicsContact) {
        let nodes = [contact.bodyA.node, contact.bodyB.node].compactMap { $0 }
        guard let other = nodes.first(where: { $0 !== player }) else { return }

        if let name = other.name, name.hasPrefix("collectible_") {
            let kind = String(name.dropFirst("collectible_".count))
            other.removeFromParent()
            gameState.collect(kind: kind)
            return
        }

        guard let sprite = other as? SKSpriteNode, let name = sprite.name else { return }
        switch name {
        case "area_exit":
            nearbyInteractionNode = sprite
            gameState.nearbyAction = .exit
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

    // MARK: - Character presentation

    private func texture(named preferred: String, fallback: String) -> SKTexture {
        if UIImage(named: preferred) != nil {
            return SKTexture(imageNamed: preferred)
        }
        return SKTexture(imageNamed: fallback)
    }

    private func applyPlayerTexture(_ texture: SKTexture) {
        player.texture = texture
        player.size = aspectFitSize(for: texture, targetHeight: 150, maxWidth: 178)
    }

    private func applyCompanionTexture(_ texture: SKTexture) {
        companion.texture = texture
        companion.size = aspectFitSize(for: texture, targetHeight: 92, maxWidth: 120)
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
        case .forest: return "Κοτσύφι: Μπάμπη, ξεκίνα από τα μήλα και το νερό. Το σεντούκι βρίσκεται βαθιά στο δάσος!"
        case .village: return "Κοτσύφι: Οι κάτοικοι χρειάζονται προμήθειες. Ψάξε κοντά στα δέντρα και στα μονοπάτια."
        case .crystalCave: return "Κοτσύφι: Πρόσεχε τους βράχους. Το κλειδί κρύβεται χαμηλά στη σπηλιά."
        case .nightForest: return "Κοτσύφι: Τα κομμάτια του χάρτη θα μας οδηγήσουν στην Αλεπού. Μην ξεχάσεις το Χρυσό Φτερό!"
        case .foxArea: return "Κοτσύφι: Τη βρήκαμε. Πλησίασε την Αλεπού και μίλησέ της."
        }
    }

    private var kotsifiEnglishMessage: String {
        switch gameState.area {
        case .forest: return "Kotsifi: Babis, start with the apples and water. The chest is deep in the forest!"
        case .village: return "Kotsifi: The villagers need supplies. Search near the trees and paths."
        case .crystalCave: return "Kotsifi: Watch the rocks. The key is hidden in the lower cave."
        case .nightForest: return "Kotsifi: The map pieces will lead us to the Fox. Don't forget the Golden Feather!"
        case .foxArea: return "Kotsifi: We found her. Walk up to the Fox and talk to her."
        }
    }
}