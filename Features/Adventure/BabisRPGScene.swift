import SpriteKit

final class BabisRPGScene: SKScene, SKPhysicsContactDelegate {
    private enum Category {
        static let player: UInt32 = 1 << 0
        static let obstacle: UInt32 = 1 << 1
        static let collectible: UInt32 = 1 << 2
        static let interaction: UInt32 = 1 << 3
    }

    private let gameState: RPGGameState
    private let player = SKSpriteNode(imageNamed: "babis_neutral")
    private let world = SKNode()
    private let cameraNode = SKCameraNode()
    private let worldSize = CGSize(width: 1600, height: 1200)

    private var moveTarget: CGPoint?
    private var lastUpdateTime: TimeInterval = 0
    private var animationTime: TimeInterval = 0
    private var runFrame = 0
    private let runTextures = (1...4).map { SKTexture(imageNamed: String(format: "babis_run_%02d", $0)) }
    private let idleTexture = SKTexture(imageNamed: "babis_neutral")
    private var interactionNode: SKSpriteNode?
    private var isTransitioning = false

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
        camera = cameraNode
        addChild(cameraNode)
        physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: .zero, size: worldSize))
        physicsBody?.categoryBitMask = Category.obstacle
        loadArea(gameState.area)
    }

    private func loadArea(_ area: RPGArea) {
        isTransitioning = true
        moveTarget = nil
        player.physicsBody?.velocity = .zero
        world.removeAllChildren()
        interactionNode = nil

        let background = SKSpriteNode(imageNamed: area.groundAsset)
        background.size = worldSize
        background.position = CGPoint(x: worldSize.width / 2, y: worldSize.height / 2)
        background.zPosition = -20
        world.addChild(background)

        switch area {
        case .forest: buildForest()
        case .village: buildVillage()
        case .crystalCave: buildCrystalCave()
        case .nightForest: buildNightForest()
        case .foxArea: buildFoxArea()
        }

        setupPlayer(at: CGPoint(x: 220, y: 260))
        cameraNode.position = player.position
        gameState.setMessageForCurrentArea()
        isTransitioning = false
    }

    private func buildForest() {
        addCommonForestObstacles()
        addCollectible(asset: "apple_item", kind: "apple", at: CGPoint(x: 420, y: 770), size: 64)
        addCollectible(asset: "apple_item", kind: "apple", at: CGPoint(x: 900, y: 920), size: 64)
        addCollectible(asset: "apple_item", kind: "apple", at: CGPoint(x: 1320, y: 610), size: 64)
        addCollectible(asset: "log", kind: "wood", at: CGPoint(x: 540, y: 300), size: 78)
        addCollectible(asset: "log", kind: "wood", at: CGPoint(x: 1170, y: 1010), size: 78)
        addCollectible(asset: "water_item", kind: "water", at: CGPoint(x: 910, y: 350), size: 66)
        addNPC(asset: "kotsifi_idle", name: "npc_kotsifi", at: CGPoint(x: 300, y: 210), size: 90)
        addExit(asset: "chest_closed", name: "area_exit", at: CGPoint(x: 1450, y: 1040), size: CGSize(width: 110, height: 95))
    }

    private func buildVillage() {
        addObstacle(asset: "tree_01", at: CGPoint(x: 310, y: 900), size: CGSize(width: 140, height: 180))
        addObstacle(asset: "tree_02", at: CGPoint(x: 1270, y: 880), size: CGSize(width: 140, height: 180))
        addObstacle(asset: "wood_sign", at: CGPoint(x: 760, y: 580), size: CGSize(width: 110, height: 95))
        addCollectible(asset: "berries_item", kind: "berries", at: CGPoint(x: 460, y: 690), size: 66)
        addCollectible(asset: "berries_item", kind: "berries", at: CGPoint(x: 1080, y: 780), size: 66)
        addCollectible(asset: "carrot_item", kind: "carrot", at: CGPoint(x: 860, y: 330), size: 66)
        addCollectible(asset: "log", kind: "wood", at: CGPoint(x: 1320, y: 430), size: 76)
        addNPC(asset: "kotsifi_happy", name: "npc_kotsifi", at: CGPoint(x: 310, y: 260), size: 90)
        addExit(asset: "chest_closed", name: "area_exit", at: CGPoint(x: 1430, y: 1030), size: CGSize(width: 108, height: 92))
    }

    private func buildCrystalCave() {
        addObstacle(asset: "rock_01", at: CGPoint(x: 380, y: 760), size: CGSize(width: 130, height: 105))
        addObstacle(asset: "rock_02", at: CGPoint(x: 850, y: 680), size: CGSize(width: 130, height: 105))
        addObstacle(asset: "rock_01", at: CGPoint(x: 1260, y: 410), size: CGSize(width: 130, height: 105))
        addCollectible(asset: "crystal_item", kind: "crystal", at: CGPoint(x: 470, y: 930), size: 68)
        addCollectible(asset: "crystal_item", kind: "crystal", at: CGPoint(x: 980, y: 920), size: 68)
        addCollectible(asset: "crystal_item", kind: "crystal", at: CGPoint(x: 1260, y: 760), size: 68)
        addCollectible(asset: "key_item", kind: "key", at: CGPoint(x: 850, y: 330), size: 66)
        addExit(asset: "chest_closed", name: "area_exit", at: CGPoint(x: 1440, y: 1030), size: CGSize(width: 112, height: 96))
    }

    private func buildNightForest() {
        addCommonForestObstacles()
        addCollectible(asset: "map_fragment", kind: "fragment", at: CGPoint(x: 510, y: 860), size: 72)
        addCollectible(asset: "map_fragment", kind: "fragment", at: CGPoint(x: 1120, y: 460), size: 72)
        addCollectible(asset: "golden_feather", kind: "feather", at: CGPoint(x: 1230, y: 930), size: 70)
        addNPC(asset: "kotsifi_fly_01", name: "npc_kotsifi", at: CGPoint(x: 320, y: 220), size: 90)
        addExit(asset: "chest_closed", name: "area_exit", at: CGPoint(x: 1440, y: 1020), size: CGSize(width: 112, height: 96))
    }

    private func buildFoxArea() {
        addObstacle(asset: "tree_01", at: CGPoint(x: 350, y: 860), size: CGSize(width: 145, height: 185))
        addObstacle(asset: "tree_03", at: CGPoint(x: 1180, y: 850), size: CGSize(width: 145, height: 185))
        addObstacle(asset: "rock_02", at: CGPoint(x: 780, y: 520), size: CGSize(width: 120, height: 95))
        addNPC(asset: "fox_worried", name: "final_fox", at: CGPoint(x: 1320, y: 850), size: 130, interactive: true)
        addNPC(asset: "kotsifi_idle", name: "npc_kotsifi", at: CGPoint(x: 430, y: 320), size: 90)
    }

    private func addCommonForestObstacles() {
        addObstacle(asset: "tree_01", at: CGPoint(x: 260, y: 850), size: CGSize(width: 150, height: 190))
        addObstacle(asset: "tree_02", at: CGPoint(x: 590, y: 930), size: CGSize(width: 155, height: 190))
        addObstacle(asset: "tree_03", at: CGPoint(x: 1240, y: 820), size: CGSize(width: 145, height: 185))
        addObstacle(asset: "tree_01", at: CGPoint(x: 1380, y: 380), size: CGSize(width: 150, height: 190))
        addObstacle(asset: "rock_01", at: CGPoint(x: 730, y: 520), size: CGSize(width: 110, height: 90))
        addObstacle(asset: "rock_02", at: CGPoint(x: 1030, y: 670), size: CGSize(width: 120, height: 95))
        addObstacle(asset: "bush_01", at: CGPoint(x: 380, y: 430), size: CGSize(width: 120, height: 95))
        addObstacle(asset: "bush_02", at: CGPoint(x: 1120, y: 300), size: CGSize(width: 120, height: 95))
    }

    private func setupPlayer(at position: CGPoint) {
        player.removeFromParent()
        player.name = "player"
        player.texture = idleTexture
        player.size = CGSize(width: 112, height: 112)
        player.position = position
        player.zPosition = 10
        player.physicsBody = SKPhysicsBody(circleOfRadius: 38)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 8
        player.physicsBody?.categoryBitMask = Category.player
        player.physicsBody?.collisionBitMask = Category.obstacle | Category.interaction
        player.physicsBody?.contactTestBitMask = Category.collectible | Category.interaction
        world.addChild(player)
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

    private func addNPC(asset: String, name: String, at position: CGPoint, size: CGFloat, interactive: Bool = false) {
        let node = SKSpriteNode(imageNamed: asset)
        node.name = name
        node.size = CGSize(width: size, height: size)
        node.position = position
        node.zPosition = 5
        if interactive {
            node.physicsBody = SKPhysicsBody(circleOfRadius: size * 0.32)
            node.physicsBody?.isDynamic = false
            node.physicsBody?.categoryBitMask = Category.interaction
            node.physicsBody?.collisionBitMask = Category.player
            node.physicsBody?.contactTestBitMask = Category.player
            interactionNode = node
        }
        world.addChild(node)
    }

    private func addExit(asset: String, name: String, at position: CGPoint, size: CGSize) {
        let node = SKSpriteNode(imageNamed: asset)
        node.name = name
        node.size = size
        node.position = position
        node.zPosition = 4
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.75, height: size.height * 0.7))
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = Category.interaction
        node.physicsBody?.collisionBitMask = Category.player
        node.physicsBody?.contactTestBitMask = Category.player
        world.addChild(node)
        interactionNode = node
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !isTransitioning else { return }
        moveTarget = touch.location(in: world)
    }

    override func update(_ currentTime: TimeInterval) {
        let dt = lastUpdateTime == 0 ? 0 : min(currentTime - lastUpdateTime, 1.0 / 20.0)
        lastUpdateTime = currentTime
        updateMovement(deltaTime: dt)
        updateCamera()
    }

    private func updateMovement(deltaTime: TimeInterval) {
        guard let target = moveTarget, !isTransitioning else {
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
        cameraNode.position = CGPoint(
            x: min(max(player.position.x, halfW), worldSize.width - halfW),
            y: min(max(player.position.y, halfH), worldSize.height - halfH)
        )
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

        if other.name == "area_exit" {
            guard !isTransitioning else { return }
            if gameState.areaGoalComplete {
                other.texture = SKTexture(imageNamed: "chest_open")
                isTransitioning = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    self.gameState.advanceArea()
                    self.loadArea(self.gameState.area)
                }
            } else {
                gameState.setMessage(greek: "Η έξοδος είναι κλειδωμένη. Ολοκλήρωσε πρώτα τον στόχο της περιοχής.", english: "The exit is locked. Complete the area objective first.")
            }
            return
        }

        if other.name == "final_fox" {
            guard !gameState.questComplete else { return }
            other.texture = SKTexture(imageNamed: "fox_friendly")
            gameState.completeQuest()
            let feather = SKSpriteNode(imageNamed: "golden_feather")
            feather.size = CGSize(width: 70, height: 70)
            feather.position = CGPoint(x: 0, y: 95)
            feather.zPosition = 10
            other.addChild(feather)
            feather.run(.repeatForever(.sequence([.moveBy(x: 0, y: 10, duration: 0.8), .moveBy(x: 0, y: -10, duration: 0.8)])))
        }
    }
}
