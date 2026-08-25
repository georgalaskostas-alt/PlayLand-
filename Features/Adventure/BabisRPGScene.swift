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
    private let worldSize = CGSize(width: 8600, height: 5600)
    private let playerRadius: CGFloat = 46
    private let minCameraScale: CGFloat = 0.38
    private let maxCameraScale: CGFloat = 3.10

    private var obstacles: [CGRect] = []
    private var reserved: [CGRect] = []
    private var interactions: [SKSpriteNode] = []
    private var collectibles: [SKSpriteNode] = []
    private weak var nearby: SKSpriteNode?
    private weak var activeChallenge: SKSpriteNode?
    private weak var activeEncounter: SKSpriteNode?
    private weak var pinch: UIPinchGestureRecognizer?
    private var joystick = CGVector.zero
    private var joystickMagnitude: CGFloat = 0
    private var tapTarget: CGPoint?
    private var movement: MovementState = .idle
    private var facing: FacingDirection = .front
    private var lastTime: TimeInterval = 0
    private var animTime: TimeInterval = 0
    private var animFrame = 0
    private var companionTime: TimeInterval = 0
    private var companionFrame = 0
    private var transitioning = false

    private lazy var idle = tex("babis_rpg_idle", "babis_rpg_master")
    private lazy var backIdle = tex("babis_rpg_back_idle", "babis_rpg_idle")
    private lazy var walk = (1...4).map { tex(String(format: "babis_rpg_walk_%02d", $0), "babis_rpg_idle") }
    private lazy var run = (1...4).map { tex(String(format: "babis_rpg_run_%02d", $0), "babis_rpg_idle") }
    private lazy var backWalk = (1...4).map { tex(String(format: "babis_rpg_back_walk_%02d", $0), "babis_rpg_back_idle") }
    private lazy var backRun = (1...4).map { tex(String(format: "babis_rpg_back_run_%02d", $0), "babis_rpg_back_idle") }
    private lazy var birdIdle = tex("kotsifi_rpg_idle", "kotsifi_rpg_master")
    private lazy var birdBack = tex("kotsifi_rpg_back_idle", "kotsifi_rpg_idle")
    private lazy var birdFly = (1...4).map { tex(String(format: "kotsifi_rpg_fly_%02d", $0), "kotsifi_rpg_idle") }
    private lazy var birdBackFly = (1...4).map { tex(String(format: "kotsifi_rpg_back_fly_%02d", $0), "kotsifi_rpg_idle") }

    init(size: CGSize, gameState: RPGGameState) { self.gameState = gameState; super.init(size: size); scaleMode = .resizeFill; backgroundColor = .black }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func didMove(to view: SKView) {
        guard world.parent == nil else { return }; view.isMultipleTouchEnabled = true
        addChild(world); addChild(cameraNode); camera = cameraNode
        let g = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:))); g.cancelsTouchesInView = false; view.addGestureRecognizer(g); pinch = g
        AudioManager.shared.playLoop(named: "rpg_adventure_theme", volume: 0.24); loadArea(gameState.area)
    }
    override func willMove(from view: SKView) { if let pinch { view.removeGestureRecognizer(pinch) }; AudioManager.shared.stopMusic(); SpeechManager.shared.stop() }

    func setMovementVector(_ vector: CGVector) { guard canMove else { return }; let m = min(1, hypot(vector.dx, vector.dy)); joystickMagnitude = m; if m < 0.04 { joystick = .zero } else { joystick = CGVector(dx: vector.dx / m, dy: vector.dy / m); tapTarget = nil } }
    func stopMovement() { joystick = .zero; joystickMagnitude = 0; tapTarget = nil; setMovement(.idle) }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { guard canMove, joystickMagnitude < 0.04, let touch = touches.first else { return }; let p = touch.location(in: world); let target = CGPoint(x: min(max(p.x, 110), worldSize.width - 110), y: min(max(p.y, 110), worldSize.height - 110)); tapTarget = nearestWalkable(to: target) }
    private var canMove: Bool { !transitioning && gameState.pendingChallenge == nil && gameState.pendingEncounter == nil }

    func talkToCompanion() {
        let messages = [("Εξερεύνησε ελεύθερα. Μπορείς να πας παντού εκτός από πάνω στα φυσικά εμπόδια.", "Explore freely. You can go anywhere except through natural obstacles."),("Ψάξε όλη την περιοχή. Οι φίλοι και τα αντικείμενα βρίσκονται πάντα σε προσβάσιμα σημεία.", "Search the whole area. Friends and items are always placed in reachable spots."),("Στην άκρη κάθε περιοχής υπάρχει το πέρασμα για το επόμενο μεγάλο μέρος της περιπέτειας.", "At the edge of each area is the passage to the next part of the adventure.")]
        let m = messages[gameState.area.rawValue % messages.count]; gameState.setMessage(greek: m.0, english: m.1); SpeechManager.shared.speak(text: gameState.message)
    }

    func performInteraction() {
        guard let node = nearby, let name = node.name else { return }; stopMovement()
        if name.hasPrefix("puzzle:"), let raw = name.split(separator: ":").dropFirst().first, let challenge = RPGChallenge(rawValue: String(raw)) { activeChallenge = node; gameState.requestChallenge(challenge); return }
        if name.hasPrefix("treasure:") { activeEncounter = node; gameState.pendingEncounter = .treasure(style: String(name.split(separator: ":")[1])); return }
        if name.hasPrefix("npc:") { let p = name.split(separator: ":"); guard p.count >= 3 else { return }; let kind = String(p[1]); if p[2] == "worried" { activeEncounter = node; gameState.pendingEncounter = .animal(kind: kind) } else { talkAnimal(node, kind: kind) }; return }
        if name == "unicorn:worried" { activeEncounter = node; gameState.pendingEncounter = .unicorn; return }
        if name == "fox" { activeEncounter = node; gameState.pendingEncounter = .fox; return }
        if name == "area_exit" { guard gameState.areaGoalComplete else { gameState.setMessage(greek: "Ολοκλήρωσε πρώτα τους στόχους της περιοχής.", english: "Complete this area's objectives first."); AudioManager.shared.play(.wrong); return }; transitionThrough(node) }
    }

    func confirmPendingEncounter() { guard let node = activeEncounter, let e = gameState.pendingEncounter else { return }; gameState.pendingEncounter = nil; switch e { case .animal(let kind): gameState.rescueAnimal(kind: kind); node.name = "npc:\(kind):happy"; node.userData?["action"] = "animalTalk"; pulse(node); heart(node); case .treasure: openTreasure(node); case .unicorn: gameState.helpUnicorn(); node.texture = tex("unicorn_rpg_happy", "unicorn_rpg_neutral"); node.name = "unicorn:happy"; pulse(node); heart(node); case .fox: gameState.meetFox(); node.texture = tex("fox_talking", "fox_friendly"); pulse(node) }; activeEncounter = nil; SpeechManager.shared.speak(text: gameState.message) }
    func cancelPendingEncounter() { gameState.pendingEncounter = nil; activeEncounter = nil }
    func completeActiveChallenge() { guard let node = activeChallenge else { return }; node.texture = tex("rpg_chest_magic_open", "rpg_chest_magic_closed"); node.name = "solved"; interactions.removeAll { $0 === node }; activeChallenge = nil; nearby = nil; gameState.nearbyAction = nil; reward(at: node.position) }

    @objc private func handlePinch(_ g: UIPinchGestureRecognizer) { guard !transitioning else { return }; if g.state == .began || g.state == .changed { cameraNode.setScale(min(maxCameraScale, max(minCameraScale, cameraNode.xScale / g.scale))); g.scale = 1; clampCamera() } }

    private func loadArea(_ area: RPGArea) { transitioning = true; stopMovement(); world.removeAllChildren(); interactions.removeAll(); collectibles.removeAll(); obstacles.removeAll(); reserved.removeAll(); nearby = nil; activeChallenge = nil; activeEncounter = nil; gameState.nearbyAction = nil; gameState.pendingChallenge = nil; gameState.pendingEncounter = nil; let bg = SKSpriteNode(imageNamed: background(for: area)); bg.size = worldSize; bg.position = CGPoint(x: worldSize.width/2, y: worldSize.height/2); bg.zPosition = -5000; world.addChild(bg); buildEnvironment(area); buildGameplay(area); addAmbientCreatures(area); addExit(area); let spawn = safePoint(near: CGPoint(x: 900, y: 900), footprint: CGSize(width: 150, height: 130), reserve: false); setupPlayer(spawn); setupCompanion(); cameraNode.setScale(1.05); cameraNode.position = spawn; clampCamera(); gameState.setMessageForCurrentArea(); transitioning = false }

    private func background(for area: RPGArea) -> String { switch area { case .forest: return "rpg_forest_ground_01"; case .rescueClearing: return "rpg_rescue_clearing"; case .village: return "rpg_village_ground"; case .riverCrossing: return "rpg_rescue_clearing"; case .puzzleClearing: return "rpg_puzzle_clearing"; case .crystalCave: return "rpg_crystal_cave_ground"; case .nightForest: return "rpg_night_forest_ground"; case .unicornGrove: return "rpg_forest_ground_01"; case .treasureClearing: return "rpg_treasure_clearing"; case .foxDen: return "rpg_fox_area_ground" } }

    private func buildEnvironment(_ area: RPGArea) {
        let trees = [(650,1450),(1250,2500),(700,3900),(1900,4750),(3050,4950),(4300,4700),(5650,5000),(7000,4650),(7900,3800),(7700,2300),(8050,1050),(5900,900),(4300,1200),(2700,1050)]; for (i,v) in trees.enumerated() { scenery(i % 2 == 0 ? "rpg_tree_large_01" : "rpg_tree_large_02", CGPoint(x:v.0,y:v.1), CGSize(width:390,height:520), 0.72, 0.62) }
        let bushes = [(1600,1600),(2300,2100),(3400,1800),(5000,1750),(6400,1550),(7150,2900),(6100,3600),(4700,3850),(3300,3600),(2000,3450)]; for (i,v) in bushes.enumerated() { scenery(i % 2 == 0 ? "rpg_bush_tall_01" : "rpg_bush_tall_02", CGPoint(x:v.0,y:v.1), CGSize(width:270,height:230), 0.96, 0.88) }
        let rocks = [(1150,850),(2850,2850),(4050,2450),(5350,2850),(6750,2350),(7450,900)]; for (i,v) in rocks.enumerated() { scenery(i % 2 == 0 ? "rpg_rock_large" : "rpg_rock_small", CGPoint(x:v.0,y:v.1), CGSize(width:230,height:190), 0.92, 0.86) }
        scenery("rpg_fallen_tree", CGPoint(x:1900,y:2850), CGSize(width:470,height:230), 0.96, 0.76); scenery("rpg_tree_stump", CGPoint(x:5550,y:2300), CGSize(width:220,height:195), 0.92, 0.78)
        if area == .village { scenery("rpg_village_house_01", CGPoint(x:1850,y:4300), CGSize(width:720,height:640), 0.90, 0.72); scenery("rpg_village_house_02", CGPoint(x:6700,y:4200), CGSize(width:720,height:640), 0.90, 0.72) }
        if area == .riverCrossing { obstacles += [CGRect(x:0,y:2600,width:3500,height:620), CGRect(x:5100,y:2600,width:3500,height:620)]; let bridge=SKSpriteNode(imageNamed:"rpg_bridge_wood");bridge.position=CGPoint(x:4300,y:2910);bridge.size=CGSize(width:1700,height:620);bridge.zPosition = -1000;world.addChild(bridge) }
        if area == .crystalCave { scenery("rpg_cave_entrance", CGPoint(x:7350,y:4450), CGSize(width:720,height:580), 0.88, 0.70) }
    }
    private func scenery(_ asset:String,_ p:CGPoint,_ s:CGSize,_ wf:CGFloat,_ hf:CGFloat) { let n=SKSpriteNode(imageNamed:asset);n.position=p;n.size=s;n.zPosition=depth(p.y);world.addChild(n); obstacles.append(CGRect(x:p.x-s.width*wf/2,y:p.y-s.height*hf/2,width:s.width*wf,height:s.height*hf)) }

    private func buildGameplay(_ a:RPGArea) { switch a {
        case .forest: pickups("apple","apple_item",14); pickups("wood","log",10); pickups("water","water_item",8); rescue("rabbit", "rabbit_rpg_worried", 0); puzzle(.memory,1)
        case .rescueClearing: pickups("berries","berries_item",14); pickups("carrot","carrot_item",12); rescue("hedgehog","hedgehog_rpg_neutral",0); rescue("deer","deer_rpg_neutral",1); puzzle(.shapes,2); treasure("wood",3)
        case .village: pickups("wood","log",14); pickups("berries","berries_item",12); pickups("carrot","carrot_item",12); rescue("squirrel","squirrel_rpg_neutral",0); treasure("wood",2)
        case .riverCrossing: pickups("water","water_item",14); pickups("wood","log",12); pickups("key","key_item",4); rescue("otter","otter_rpg_neutral",0); puzzle(.numbers,2)
        case .puzzleClearing: pickups("crystal","crystal_item",12); pickups("key","key_item",6); puzzle(.memory,0); puzzle(.numbers,2); puzzle(.shapes,4); treasure("wood",6); treasure("magic",8)
        case .crystalCave: pickups("crystal","crystal_item",20); pickups("key","key_item",7); rescue("baby_dragon","baby_dragon_rpg_neutral",0); puzzle(.words,2); puzzle(.shapes,4); treasure("crystal",7)
        case .nightForest: pickups("fragment","map_fragment",14); pickups("feather","golden_feather",10); rescue("raccoon","raccoon_rpg_neutral",0); rescue("owl","owl_rpg_neutral",2); puzzle(.memory,4)
        case .unicornGrove: pickups("crystal","crystal_item",14); pickups("fragment","map_fragment",8); puzzle(.numbers,1); puzzle(.words,3); treasure("magic",5); npc("unicorn_rpg_worried","unicorn:worried",7,230,.unicorn)
        case .treasureClearing: pickups("key","key_item",10); pickups("crystal","crystal_item",14); puzzle(.shapes,1); puzzle(.numbers,3); treasure("wood",5); treasure("magic",7); treasure("crystal",9)
        case .foxDen: puzzle(.words,2); treasure("crystal",5); npc("fox_friendly","fox",8,210,.fox) } }

    private let anchors:[CGPoint] = stride(from: 0, to: 30, by: 1).map { i in let col=i%6,row=i/6; return CGPoint(x:1500+CGFloat(col)*1150,y:1150+CGFloat(row)*900) }
    private func anchor(_ i:Int)->CGPoint { anchors[(i + gameState.area.rawValue*3) % anchors.count] }
    private func pickups(_ kind:String,_ asset:String,_ count:Int) { for i in 0..<count { let base=anchor((i*2+kind.count)%anchors.count); let p=safePoint(near:CGPoint(x:base.x+CGFloat((i%3)-1)*180,y:base.y+CGFloat((i%4)-2)*130),footprint:CGSize(width:110,height:100)); let n=SKSpriteNode(imageNamed:asset);n.position=p;n.size=CGSize(width:72,height:72);n.name="collect:\(kind)";n.zPosition=depth(p.y)+4;world.addChild(n);collectibles.append(n); n.run(.repeatForever(.sequence([.moveBy(x:0,y:8,duration:0.7),.moveBy(x:0,y:-8,duration:0.7)]))) } }
    private func rescue(_ kind:String,_ asset:String,_ index:Int){ npc(asset,"npc:\(kind):worried",index,175,.animalRescue) }
    private func puzzle(_ c:RPGChallenge,_ index:Int){ npc(c == .memory ? "rpg_chest_wood_closed" : (c == .words ? "rpg_chest_crystal_closed":"rpg_chest_magic_closed"),"puzzle:\(c.rawValue)",index,150,.puzzle) }
    private func treasure(_ style:String,_ index:Int){ npc(style == "crystal" ? "rpg_chest_crystal_closed" : (style == "magic" ? "rpg_chest_magic_closed":"rpg_chest_wood_closed"),"treasure:\(style)",index,155,.treasure) }
    private func addAmbientCreatures(_ area:RPGArea) { for (i,id) in RPGCreatureCatalog.population(for: area).enumerated() { guard id != "rabbit", let c=RPGCreatureCatalog.creature(id) else { continue }; let size:CGFloat = c.collisionScale > 0.78 ? 205 : (c.collisionScale < 0.55 ? 105 : 155); npc(c.asset,"npc:\(id):happy",12+i,size,.animalTalk) } }
    private func addExit(_ area:RPGArea) { let asset:String; switch area { case .forest,.nightForest:asset="rpg_wood_sign";case .rescueClearing:asset="rpg_village_house_01";case .village:asset="rpg_bridge_wood";case .riverCrossing:asset="rpg_puzzle_clearing";case .puzzleClearing:asset="rpg_crystal_cave_entrance";case .crystalCave:asset="rpg_cave_entrance";case .unicornGrove:asset="rpg_treasure_clearing";case .treasureClearing:asset="rpg_fox_den";case .foxDen:asset="rpg_chest_crystal_closed" }; npc(asset,"area_exit",29,area == .rescueClearing ? 330:210,.exit) }
    private func npc(_ asset:String,_ name:String,_ index:Int,_ size:CGFloat,_ action:RPGNearbyAction?) { let p=safePoint(near:anchor(index),footprint:CGSize(width:max(130,size*0.85),height:max(110,size*0.70))); let n=SKSpriteNode(imageNamed:asset);n.position=p;n.size=CGSize(width:size,height:size);n.name=name;n.zPosition=depth(p.y)+6;n.userData=NSMutableDictionary();if let action{n.userData?["action"]=actionKey(action)};world.addChild(n); if action != nil { interactions.append(n) }; let w=size*0.78,h=size*0.62;obstacles.append(CGRect(x:p.x-w/2,y:p.y-h*0.42,width:w,height:h));pulse(n) }

    private func safePoint(near desired:CGPoint, footprint:CGSize, reserve shouldReserve:Bool=true)->CGPoint { let offsets:[CGPoint]=[.zero,.init(x:220,y:0),.init(x:-220,y:0),.init(x:0,y:220),.init(x:0,y:-220),.init(x:330,y:220),.init(x:-330,y:220),.init(x:330,y:-220),.init(x:-330,y:-220),.init(x:520,y:0),.init(x:-520,y:0)]; for o in offsets { let p=CGPoint(x:min(max(desired.x+o.x,220),worldSize.width-220),y:min(max(desired.y+o.y,220),worldSize.height-220));let r=CGRect(x:p.x-footprint.width/2,y:p.y-footprint.height/2,width:footprint.width,height:footprint.height);if !obstacles.contains(where:{$0.intersects(r)}) && !reserved.contains(where:{$0.intersects(r.insetBy(dx:-70,dy:-70))}) { if shouldReserve{reserved.append(r)};return p } }; for row in 0..<8 { for col in 0..<12 { let p=CGPoint(x:700+CGFloat(col)*650,y:650+CGFloat(row)*600);let r=CGRect(x:p.x-footprint.width/2,y:p.y-footprint.height/2,width:footprint.width,height:footprint.height);if !obstacles.contains(where:{$0.intersects(r)}) && !reserved.contains(where:{$0.intersects(r.insetBy(dx:-60,dy:-60))}) {if shouldReserve{reserved.append(r)};return p} } }; return CGPoint(x:900,y:900) }
    private func setupPlayer(_ p:CGPoint){player.removeFromParent();player.texture=idle;player.size=CGSize(width:145,height:175);player.anchorPoint=CGPoint(x:0.5,y:0.18);player.position=p;player.zPosition=depth(p.y)+12;player.xScale=1;world.addChild(player)}
    private func setupCompanion(){companion.removeFromParent();companion.texture=birdIdle;companion.size=CGSize(width:92,height:108);companion.position=CGPoint(x:player.position.x-100,y:player.position.y+110);companion.zPosition=depth(companion.position.y)+15;world.addChild(companion)}
    override func update(_ currentTime:TimeInterval){let dt=lastTime==0 ? 1.0/60.0:min(0.05,currentTime-lastTime);lastTime=currentTime;movePlayer(dt);animate(dt);followBird(dt);followCamera(dt);updateNearby();collectItems()}
    private func movePlayer(_ dt:TimeInterval){guard canMove else{return};var d=CGVector.zero;var speed:CGFloat=0;if joystickMagnitude>=0.04{d=joystick;speed=joystickMagnitude>0.72 ? 370:250}else if let t=tapTarget{let dx=t.x-player.position.x,dy=t.y-player.position.y,dist=hypot(dx,dy);if dist<20{tapTarget=nil;setMovement(.idle);return};d=CGVector(dx:dx/max(dist,1),dy:dy/max(dist,1));speed=405}else{setMovement(.idle);return};let step=speed*CGFloat(dt);let p=CGPoint(x:player.position.x+d.dx*step,y:player.position.y+d.dy*step);if walkable(p){player.position=p}else{let px=CGPoint(x:p.x,y:player.position.y),py=CGPoint(x:player.position.x,y:p.y);if walkable(px){player.position=px}else if walkable(py){player.position=py}else if joystickMagnitude<0.04{tapTarget=nil}};face(d);setMovement(speed>320 ? .running:.walking);player.zPosition=depth(player.position.y)+12}
    private func walkable(_ p:CGPoint)->Bool{guard p.x>90,p.y>90,p.x<worldSize.width-90,p.y<worldSize.height-90 else{return false};let r=CGRect(x:p.x-playerRadius,y:p.y-playerRadius*0.48,width:playerRadius*2,height:playerRadius*0.96);return !obstacles.contains{$0.intersects(r)}}
    private func nearestWalkable(to p:CGPoint)->CGPoint?{if walkable(p){return p};for radius in stride(from:80,through:720,by:80){for i in 0..<16{let a = CGFloat(i) / 16 * 2 * .pi;let q=CGPoint(x:p.x+cos(a)*CGFloat(radius),y:p.y+sin(a)*CGFloat(radius));if walkable(q){return q}}};return nil}
    private func face(_ d:CGVector){if abs(d.dy)>=abs(d.dx)*0.55{facing=d.dy>0 ? .back:.front;player.xScale=1}else{facing=d.dx<0 ? .left:.right;player.xScale=d.dx<0 ? -1:1}}
    private func animate(_ dt:TimeInterval){animTime+=dt;guard movement != .idle else{player.texture=facing == .back ? backIdle:idle;return};let interval=movement == .running ? 0.10:0.15;guard animTime>=interval else{return};animTime=0;animFrame=(animFrame+1)%4;player.texture=facing == .back ? (movement == .running ? backRun[animFrame]:backWalk[animFrame]):(movement == .running ? run[animFrame]:walk[animFrame])}
    private func followBird(_ dt:TimeInterval){guard !transitioning else{return};let tx=player.position.x+(player.xScale<0 ? 95:-95),ty=player.position.y+(facing == .back ? -70:105),f=min(1,CGFloat(dt)*5.2);companion.position.x+=(tx-companion.position.x)*f;companion.position.y+=(ty-companion.position.y)*f;companion.zPosition=depth(companion.position.y)+15;companion.xScale=player.xScale;companionTime+=dt;if movement != .idle && companionTime>0.12{companionTime=0;companionFrame=(companionFrame+1)%4;companion.texture=facing == .back ? birdBackFly[companionFrame]:birdFly[companionFrame]}else if movement == .idle{companion.texture=facing == .back ? birdBack:birdIdle}}
    private func followCamera(_ dt:TimeInterval){guard !transitioning else{return};let f=min(1,CGFloat(dt)*5.5);cameraNode.position.x+=(player.position.x-cameraNode.position.x)*f;cameraNode.position.y+=(player.position.y-cameraNode.position.y)*f;clampCamera()}
    private func clampCamera(){let hw=min(worldSize.width/2,size.width*cameraNode.xScale/2),hh=min(worldSize.height/2,size.height*cameraNode.yScale/2);cameraNode.position.x=min(worldSize.width-hw,max(hw,cameraNode.position.x));cameraNode.position.y=min(worldSize.height-hh,max(hh,cameraNode.position.y))}
    private func updateNearby(){var best:CGFloat=245;var found:SKSpriteNode?;for n in interactions where n.parent != nil{let d=hypot(n.position.x-player.position.x,n.position.y-player.position.y);if d<best{best=d;found=n}};nearby=found;if let n=found,let k=n.userData?["action"] as? String{gameState.nearbyAction=action(k)}else{gameState.nearbyAction=nil}}
    private func collectItems(){for n in collectibles where n.parent != nil{let d=hypot(n.position.x-player.position.x,n.position.y-player.position.y);if d<100,let name=n.name,name.hasPrefix("collect:"){n.name=nil;gameState.collect(kind:String(name.dropFirst(8)));n.removeAllActions();n.run(.sequence([.group([.moveBy(x:60,y:100,duration:0.25),.fadeOut(withDuration:0.25)]),.removeFromParent()]))}};collectibles.removeAll{$0.parent==nil}}
    private func transitionThrough(_ exit:SKSpriteNode){guard !transitioning else{return};transitioning=true;stopMovement();let dx=exit.position.x-player.position.x,dy=exit.position.y-player.position.y,dist=max(hypot(dx,dy),1),d=CGVector(dx:dx/dist,dy:dy/dist);face(d);setMovement(.running);let target=CGPoint(x:exit.position.x+d.dx*150,y:exit.position.y+d.dy*150);let fade=SKSpriteNode(color:.black,size:CGSize(width:max(size.width,1200)*4,height:max(size.height,900)*4));fade.alpha=0;fade.zPosition=100000;cameraNode.addChild(fade);player.run(.move(to:target,duration:1.6));companion.run(.move(to:CGPoint(x:target.x-90,y:target.y+80),duration:1.6));cameraNode.run(.group([.move(to:exit.position,duration:1.6),.scale(to:0.78,duration:1.6)]));fade.run(.sequence([.wait(forDuration:0.9),.fadeIn(withDuration:0.55)])){[weak self,weak fade] in guard let self else{return};let finish=self.gameState.area == .foxDen;self.gameState.advanceArea();if finish{fade?.run(.sequence([.wait(forDuration:0.25),.fadeOut(withDuration:0.6),.removeFromParent()]));self.transitioning=false;self.setMovement(.idle)}else{self.loadArea(self.gameState.area);self.transitioning=true;fade?.alpha=1;fade?.run(.sequence([.wait(forDuration:0.2),.fadeOut(withDuration:0.75),.removeFromParent(),.run{[weak self] in self?.transitioning=false;self?.setMovement(.idle)}]))}}}
    private func openTreasure(_ n:SKSpriteNode){let style=n.name?.split(separator:":").dropFirst().first.map(String.init) ?? "wood";n.texture=tex(style == "crystal" ? "rpg_chest_crystal_open":(style == "magic" ? "rpg_chest_magic_open":"rpg_chest_wood_open"),"rpg_chest_wood_closed");n.name="opened";interactions.removeAll{$0===n};gameState.openTreasure();reward(at:n.position)}
    private func talkAnimal(_ n:SKSpriteNode,kind:String){gameState.setMessage(greek:"Ο φίλος σου σε χαιρετά! Συνέχισε την εξερεύνηση και ανακάλυψε ποιος χρειάζεται βοήθεια.",english:"Your new friend says hello! Keep exploring and discover who needs your help.");SpeechManager.shared.speak(text:gameState.message);pulse(n);heart(n)}
    private func pulse(_ n:SKSpriteNode){n.removeAction(forKey:"idle");n.run(.repeatForever(.sequence([.group([.moveBy(x:0,y:7,duration:0.75),.rotate(byAngle:0.015,duration:0.75)]),.group([.moveBy(x:0,y:-7,duration:0.75),.rotate(byAngle:-0.015,duration:0.75)])])),withKey:"idle")}
    private func heart(_ n:SKSpriteNode){let l=SKLabelNode(text:"💛");l.fontSize=48;l.position=CGPoint(x:n.position.x,y:n.position.y+n.size.height*0.65);l.zPosition=22000;world.addChild(l);l.run(.sequence([.moveBy(x:0,y:60,duration:0.7),.fadeOut(withDuration:0.3),.removeFromParent()]))}
    private func reward(at p:CGPoint){let n=SKSpriteNode(imageNamed:"rpg_treasure_gems");n.size=CGSize(width:150,height:120);n.position=CGPoint(x:p.x,y:p.y+100);n.zPosition=22000;world.addChild(n);n.run(.sequence([.group([.moveBy(x:0,y:45,duration:0.4),.scale(to:1.2,duration:0.4)]),.wait(forDuration:0.5),.fadeOut(withDuration:0.25),.removeFromParent()]))}
    private func setMovement(_ m:MovementState){if movement != m{movement=m;animTime=0;animFrame=0}}
    private func depth(_ y:CGFloat)->CGFloat{10000-y}
    private func tex(_ name:String,_ fallback:String)->SKTexture{UIImage(named:name) != nil ? SKTexture(imageNamed:name):SKTexture(imageNamed:fallback)}
    private func actionKey(_ a:RPGNearbyAction)->String{switch a{case .kotsifi:return"kotsifi";case .exit:return"exit";case .fox:return"fox";case .puzzle:return"puzzle";case .animalRescue:return"animalRescue";case .animalTalk:return"animalTalk";case .treasure:return"treasure";case .unicorn:return"unicorn"}}
    private func action(_ k:String)->RPGNearbyAction?{switch k{case"kotsifi":return.kotsifi;case"exit":return.exit;case"fox":return.fox;case"puzzle":return.puzzle;case"animalRescue":return.animalRescue;case"animalTalk":return.animalTalk;case"treasure":return.treasure;case"unicorn":return.unicorn;default:return nil}}
}
