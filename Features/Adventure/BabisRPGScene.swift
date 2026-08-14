import SpriteKit

final class BabisRPGScene: SKScene, SKPhysicsContactDelegate {
    private enum Category {
        static let player: UInt32 = 1 << 0
        static let obstacle: UInt32 = 1 << 1
        static let collectible: UInt32 = 1 << 2
        static let chest: UInt32 = 1 << 3
    }

    private let gameState: RPGGameState
    private let player = SKSpriteNode(imageNamed: "babis_neutral")
    private let world = SKNode()
    private let cameraNode = SKCameraNode()
    private var moveTarget: CGPoint?
    private var lastUpdateTime: TimeInterval = 0
    private var animationTime: TimeInterval = 0
    private var runFrame = 0
    private let runTextures = (1...4).map { SKTexture(imageNamed: String(format: "babis_run_%02d", $0)) }
    private let idleTexture = SKTexture(imageNamed: "babis_neutral")
    private var chestNode: SKSpriteNode?

    init(size: CGSize, gameState: RPGGameState) {
        self.gameState = gameState
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = .black
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func didMove(to view: SKView) {
        guard world.parent == nil else { return }
        addChild(world)
        buildWorld()
        setupPlayer()
        setupCamera()
        gameState.setMessage(greek: "Το Κοτσύφι χρειάζεται βοήθεια. Μάζεψε 3 μήλα, 2 ξύλα και 1 νερό.", english: "Kotsifi needs help. Collect 3 apples, 2 logs and 1 water.")
    }

    private func buildWorld() {
        let worldSize = CGSize(width: 1600, height: 1200)
        let background = SKSpriteNode(imageNamed: "rpg_forest_ground_01")
        background.size = worldSize
        background.position = CGPoint(x: worldSize.width / 2, y: worldSize.height / 2)
        background.zPosition = -20
        world.addChild(background)

        physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: .zero, size: worldSize))
        physicsBody?.categoryBitMask = Category.obstacle

        addObstacle(asset: "tree_01", at: CGPoint(x: 260, y: 850), size: CGSize(width: 150, height: 190))
        addObstacle(asset: "tree_02", at: CGPoint(x: 590, y: 930), size: CGSize(width: 155, height: 190))
        addObstacle(asset: "tree_03", at: CGPoint(x: 1240, y: 820), size: CGSize(width: 145, height: 185))
        addObstacle(asset: "tree_01", at: CGPoint(x: 1380, y: 380), size: CGSize(width: 150, height: 190))
        addObstacle(asset: "rock_01", at: CGPoint(x: 730, y: 520), size: CGSize(width: 110, height: 90))
        addObstacle(asset: "rock_02", at: CGPoint(x: 1030, y: 670), size: CGSize(width: 120, height: 95))
        addObstacle(asset: "bush_01", at: CGPoint(x: 380, y: 430), size: CGSize(width: 120, height: 95))
        addObstacle(asset: "bush_02", at: CGPoint(x: 1120, y: 300), size: CGSize(width: 120, height: 95))

        addCollectible(asset: "apple_item", kind: "apple", at: CGPoint(x: 420, y: 770), size: 64)
        addCollectible(asset: "apple_item", kind: "apple", at: CGPoint(x: 900, y: 920), size: 64)
        addCollectible(asset: "apple_item", kind: "apple", at: CGPoint(x: 1320, y: 610), size: 64)
        addCollectible(asset: "log", kind: "wood", at: CGPoint(x: 540, y: 300), size: 78)
        addCollectible(asset: "log", kind: "wood", at: CGPoint(x: 1170, y: 1010), size: 78)
        addCollectible(asset: "water_item", kind: "water", at: CGPoint(x: 910, y: 350), size: 66)

        let kotsifi = SKSpriteNode(imageNamed: "kotsifi_idle")
        kotsifi.name = "npc_kotsifi"
        kotsifi.size = CGSize(width: 92, height: 92)
        kotsifi.position = CGPoint(x: 250, y: 240)
        kotsifi.zPosition = 5
        world.addChild(kotsifi)

        let chest = SKSpriteNode(imageNamed: "chest_closed")
        chest.name = "chest"
        chest.size = CGSize(width: 110, height: 95)
        chest.position = CGPoint(x: 1450, y: 1040)
        chest.zPosition = 4
        chest.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 85, height: 70))
        chest.physicsBody?.isDynamic = false
        chest.physicsBody?.categoryBitMask = Category.chest
        chest.physicsBody?.collisionBitMask = Category.player
        chest.physicsBody?.contactTestBitMask = Category.player
        world.addChild(chest)
        chestNode = chest
    }

    private func setupPlayer() {
        player.name = "player"
        player.size = CGSize(width: 112, height: 112)
        player.position = CGPoint(x: 250, y: 360)
        player.zPosition = 10
        player.physicsBody = SKPhysicsBody(circleOfRadius: 38)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 8
        player.physicsBody?.categoryBitMask = Category.player
        player.physicsBody?.collisionBitMask = Category.obstacle | Category.chest
        player.physicsBody?.contactTestBitMask = Category.collectible | Category.chest
        world.addChild(player)
    }

    private func setupCamera() {
        camera = cameraNode
        addChild(cameraNode)
        cameraNode.position = player.position
    }

    private func addObstacle(asset: String, at position: CGPoint, size: CGSize) {
        let node = SKSpriteNode(imageNamed: asset)
        node.size = size
        node.position = position
        node.zPosition = 2
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.62, height: size.height * 0.42), center: CGPoint(x: 0, y: -size.height * 0.2))
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
        node.zPosition = 3
        node.physicsBody = SKPhysicsBody(circleOfRadius: size * 0.34)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = Category.collectible
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.contactTestBitMask = Category.player
        node.run(.repeatForever(.sequence([.scale(to: 1.08, duration: 0.7), .scale(to: 0.94, duration: 0.7)])))
        world.addChild(node)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: world)
        moveTarget = point
    }

    override func update(_ currentTime: TimeInterval) {
        let dt = lastUpdateTime == 0 ? 0 : min(currentTime - lastUpdateTime, 1.0 / 20.0)
        lastUpdateTime = currentTime
        updateMovement(deltaTime: dt)
        updateCamera()
    }

    private func updateMovement(deltaTime: TimeInterval) {
        guard let target = moveTarget else {
            player.physicsBody?.velocity = .zero
            player.texture = idleTexture
            return
        }
        let dx = target.x - player.position.x
        let dy = target.y - player.position.y
        let distance = hypot(dx, dy)
        if distance < 18 {
            moveTarget = nil
            player.physicsBody?.velocity = .zero
            player.texture = idleTexture
            return
        }

        let speed: CGFloat = 260
        player.physicsBody?.velocity = CGVector(dx: dx / distance * speed, dy: dy / distance * speed)
        player.xScale = dx < 0 ? -abs(player.xScale) : abs(player.xScale)
        animationTime += deltaTime
        if animationTime > 0.11 {
            animationTime = 0
            runFrame = (runFrame + 1) % runTextures.count
            player.texture = runTextures[runFrame]
        }
    }

    private func updateCamera() {
        let halfW = size.width / 2
        let halfH = size.height / 2
        let x = min(max(player.position.x, halfW), 1600 - halfW)
        let y = min(max(player.position.y, halfH), 1200 - halfH)
        cameraNode.position = CGPoint(x: x, y: y)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let nodes = [contact.bodyA.node, contact.bodyB.node].compactMap { $0 }
        guard let other = nodes.first(where: { $0 !== player }) else { return }

        if let name = other.name, name.hasPrefix("collectible_") {
            let kind = String(name.dropFirst("collectible_".count))
            other.removeFromParent()
            gameState.collect(kind: kind)
            return
        }

        if other.name == "chest" {
            if gameState.hasCompletedCollectionGoal {
                openChest()
            } else {
                gameState.setMessage(greek: "Το σεντούκι είναι κλειδωμένο. Βρες πρώτα όλα τα υλικά!", english: "The chest is locked. Find all the supplies first!")
            }
        }
    }

    private func openChest() {
        guard !gameState.questComplete else { return }
        chestNode?.texture = SKTexture(imageNamed: "chest_open")
        gameState.completeQuest()
        let feather = SKSpriteNode(imageNamed: "golden_feather")
        feather.size = CGSize(width: 70, height: 70)
        feather.position = CGPoint(x: 0, y: 70)
        feather.zPosition = 10
        chestNode?.addChild(feather)
        feather.run(.repeatForever(.sequence([.moveBy(x: 0, y: 10, duration: 0.8), .moveBy(x: 0, y: -10, duration: 0.8)])))
    }
}
