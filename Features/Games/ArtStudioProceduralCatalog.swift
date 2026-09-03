import SwiftUI

struct ArtStudioDrawingTitle {
    let gr: String
    let en: String
}

enum ArtStudioProceduralCatalog {
    static let detailedCount = 100
    static let simpleCount = 100

    private static let detailedSubjects: [(gr: String, en: String)] = [
        ("Capybara", "Capybara"), ("Μονόκερος", "Unicorn"), ("Πριγκίπισσα", "Princess"),
        ("Κάστρο", "Castle"), ("Δράκος", "Dragon"), ("Γοργόνα", "Mermaid"),
        ("Δεινόσαυρος", "Dinosaur"), ("Αλεπού", "Fox"), ("Κουνελάκι", "Bunny"), ("Πειρατής", "Pirate")
    ]

    private static let detailedSettings: [(gr: String, en: String)] = [
        ("στο δάσος", "in the forest"), ("δίπλα στο ποτάμι", "by the river"),
        ("στον κήπο του κάστρου", "in the castle garden"), ("στα βουνά", "in the mountains"),
        ("στην παραλία", "at the beach"), ("στα σύννεφα", "in the clouds"),
        ("στο μαγικό χωριό", "in the magic village"), ("κάτω από το φεγγάρι", "under the moon"),
        ("στο λιβάδι με λουλούδια", "in the flower meadow"), ("στον καταρράκτη", "at the waterfall")
    ]

    private static let simpleSubjects: [(gr: String, en: String)] = [
        ("Καρδιά", "Heart"), ("Αστέρι", "Star"), ("Φεγγάρι", "Moon"), ("Ήλιος", "Sun"),
        ("Σύννεφο", "Cloud"), ("Ουράνιο τόξο", "Rainbow"), ("Λουλούδι", "Flower"),
        ("Πεταλούδα", "Butterfly"), ("Κορώνα", "Crown"), ("Διαμάντι", "Diamond"),
        ("Απλός μονόκερος", "Simple unicorn"), ("Γατούλα", "Cat"), ("Σκυλάκι", "Dog"),
        ("Ψαράκι", "Fish"), ("Μήλο", "Apple"), ("Cupcake", "Cupcake"),
        ("Πύραυλος", "Rocket"), ("Αυτοκινητάκι", "Car"), ("Δέντρο", "Tree"), ("Σπιτάκι", "House")
    ]

    static var detailedTitles: [ArtStudioDrawingTitle] {
        (0..<detailedCount).map { index in
            let subject = detailedSubjects[index / 10]
            let setting = detailedSettings[index % 10]
            return ArtStudioDrawingTitle(gr: "\(subject.gr) \(setting.gr)", en: "\(subject.en) \(setting.en)")
        }
    }

    static var simpleTitles: [ArtStudioDrawingTitle] {
        (0..<simpleCount).map { index in
            let subject = simpleSubjects[index / 5]
            let variant = index % 5 + 1
            return ArtStudioDrawingTitle(gr: "\(subject.gr) · σχέδιο \(variant)", en: "\(subject.en) · design \(variant)")
        }
    }
}

struct ArtStudioProceduralPageView: View {
    let index: Int

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size).insetBy(dx: 10, dy: 10)
            context.fill(Path(rect), with: .color(.white))

            if index < 100 {
                drawDetailed(index: index, context: &context, rect: rect)
            } else {
                drawSimple(index: index - 100, context: &context, rect: rect)
            }
        }
        .background(Color.white)
        .aspectRatio(15.0 / 11.0, contentMode: .fit)
    }

    private func drawDetailed(index: Int, context: inout GraphicsContext, rect: CGRect) {
        let subject = index / 10
        let setting = index % 10
        drawEnvironment(setting, context: &context, rect: rect, seed: index)

        let center = CGPoint(x: rect.midX, y: rect.midY + rect.height * 0.08)
        let scale = min(rect.width, rect.height) / 320
        switch subject {
        case 0: drawCapybara(context: &context, center: center, scale: scale)
        case 1: drawUnicorn(context: &context, center: center, scale: scale)
        case 2: drawPrincess(context: &context, center: center, scale: scale)
        case 3: drawCastle(context: &context, center: center, scale: scale)
        case 4: drawDragon(context: &context, center: center, scale: scale)
        case 5: drawMermaid(context: &context, center: center, scale: scale)
        case 6: drawDinosaur(context: &context, center: center, scale: scale)
        case 7: drawFox(context: &context, center: center, scale: scale)
        case 8: drawBunny(context: &context, center: center, scale: scale)
        default: drawPirate(context: &context, center: center, scale: scale)
        }

        drawGroundDetails(context: &context, rect: rect, seed: index)
    }

    private func drawSimple(index: Int, context: inout GraphicsContext, rect: CGRect) {
        let motif = index / 5
        let variant = index % 5
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let s = min(rect.width, rect.height) * (0.22 + CGFloat(variant) * 0.012)
        let stroke = StrokeStyle(lineWidth: 3.2, lineCap: .round, lineJoin: .round)

        switch motif {
        case 0: strokePath(heartPath(center: c, size: s * 1.4), context: &context, stroke: stroke)
        case 1: strokePath(starPath(center: c, radius: s, points: 5 + variant % 2), context: &context, stroke: stroke)
        case 2: drawMoon(context: &context, center: c, size: s)
        case 3: drawSun(context: &context, center: c, size: s)
        case 4: drawCloud(context: &context, center: c, size: s)
        case 5: drawRainbow(context: &context, center: c, size: s)
        case 6: drawFlower(context: &context, center: c, size: s, petals: 5 + variant)
        case 7: drawButterfly(context: &context, center: c, size: s)
        case 8: drawCrown(context: &context, center: c, size: s)
        case 9: strokePath(diamondPath(center: c, size: s), context: &context, stroke: stroke)
        case 10: drawSimpleUnicorn(context: &context, center: c, size: s)
        case 11: drawSimpleCat(context: &context, center: c, size: s)
        case 12: drawSimpleDog(context: &context, center: c, size: s)
        case 13: drawFish(context: &context, center: c, size: s)
        case 14: drawApple(context: &context, center: c, size: s)
        case 15: drawCupcake(context: &context, center: c, size: s)
        case 16: drawRocket(context: &context, center: c, size: s)
        case 17: drawCar(context: &context, center: c, size: s)
        case 18: drawTree(context: &context, center: c, size: s)
        default: drawHouse(context: &context, center: c, size: s)
        }

        if variant > 0 {
            for i in 0..<variant {
                let x = rect.minX + 36 + CGFloat(i) * 34
                let y = rect.maxY - 28
                strokePath(starPath(center: CGPoint(x: x, y: y), radius: 8, points: 5), context: &context, stroke: StrokeStyle(lineWidth: 1.8))
            }
        }
    }

    // MARK: - Environments

    private func drawEnvironment(_ kind: Int, context: inout GraphicsContext, rect: CGRect, seed: Int) {
        let thin = StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round)
        switch kind {
        case 0:
            drawTree(context: &context, center: CGPoint(x: rect.minX + rect.width * 0.17, y: rect.midY), size: rect.height * 0.29)
            drawTree(context: &context, center: CGPoint(x: rect.maxX - rect.width * 0.17, y: rect.midY), size: rect.height * 0.27)
        case 1:
            var river = Path(); river.move(to: CGPoint(x: rect.minX, y: rect.maxY - 55)); river.addCurve(to: CGPoint(x: rect.maxX, y: rect.maxY - 62), control1: CGPoint(x: rect.midX - 70, y: rect.maxY - 92), control2: CGPoint(x: rect.midX + 60, y: rect.maxY - 25)); strokePath(river, context: &context, stroke: thin)
        case 2:
            drawCastle(context: &context, center: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.23), scale: min(rect.width, rect.height) / 650)
        case 3:
            var mountains = Path(); mountains.move(to: CGPoint(x: rect.minX, y: rect.midY)); mountains.addLine(to: CGPoint(x: rect.minX + rect.width * 0.22, y: rect.minY + 45)); mountains.addLine(to: CGPoint(x: rect.minX + rect.width * 0.43, y: rect.midY)); mountains.addLine(to: CGPoint(x: rect.minX + rect.width * 0.68, y: rect.minY + 58)); mountains.addLine(to: CGPoint(x: rect.maxX, y: rect.midY)); strokePath(mountains, context: &context, stroke: thin)
        case 4:
            drawSun(context: &context, center: CGPoint(x: rect.maxX - 45, y: rect.minY + 42), size: 20)
            for i in 0..<5 { let x = rect.minX + CGFloat(i) * rect.width / 4; var wave = Path(); wave.move(to: CGPoint(x:x, y:rect.maxY-45)); wave.addQuadCurve(to: CGPoint(x:x+rect.width/5, y:rect.maxY-45), control: CGPoint(x:x+rect.width/10, y:rect.maxY-58)); strokePath(wave, context:&context, stroke:thin) }
        case 5:
            drawCloud(context: &context, center: CGPoint(x: rect.minX + 70, y: rect.minY + 55), size: 36)
            drawCloud(context: &context, center: CGPoint(x: rect.maxX - 70, y: rect.minY + 72), size: 30)
        case 6:
            drawHouse(context: &context, center: CGPoint(x: rect.minX + 68, y: rect.midY - 20), size: 42)
            drawHouse(context: &context, center: CGPoint(x: rect.maxX - 65, y: rect.midY - 15), size: 38)
        case 7:
            drawMoon(context: &context, center: CGPoint(x: rect.maxX - 50, y: rect.minY + 48), size: 28)
            for i in 0..<6 { strokePath(starPath(center: CGPoint(x: rect.minX + 35 + CGFloat(i) * 45, y: rect.minY + 34 + CGFloat((i+seed)%2)*24), radius: 6, points: 5), context: &context, stroke: StrokeStyle(lineWidth: 1.5)) }
        case 8:
            for i in 0..<7 { drawFlower(context: &context, center: CGPoint(x: rect.minX + 30 + CGFloat(i) * (rect.width-60)/6, y: rect.maxY - 38), size: 12, petals: 5) }
        default:
            var fall = Path(); fall.move(to: CGPoint(x: rect.maxX - 85, y: rect.minY + 18)); fall.addCurve(to: CGPoint(x: rect.maxX - 65, y: rect.maxY - 58), control1: CGPoint(x: rect.maxX - 115, y: rect.midY - 45), control2: CGPoint(x: rect.maxX - 28, y: rect.midY + 45)); strokePath(fall, context: &context, stroke: StrokeStyle(lineWidth: 4))
        }
    }

    private func drawGroundDetails(context: inout GraphicsContext, rect: CGRect, seed: Int) {
        for i in 0..<6 {
            let x = rect.minX + 28 + CGFloat(i) * (rect.width - 56) / 5
            let y = rect.maxY - 24 - CGFloat((i + seed) % 3) * 4
            var grass = Path(); grass.move(to: CGPoint(x:x, y:y)); grass.addLine(to: CGPoint(x:x-5, y:y-12)); grass.move(to: CGPoint(x:x, y:y)); grass.addLine(to: CGPoint(x:x+4, y:y-14)); grass.move(to: CGPoint(x:x, y:y)); grass.addLine(to: CGPoint(x:x+10, y:y-8)); strokePath(grass, context: &context, stroke: StrokeStyle(lineWidth: 1.7, lineCap: .round))
        }
    }

    // MARK: - Detailed subjects

    private func drawCapybara(context: inout GraphicsContext, center: CGPoint, scale: CGFloat) {
        let s = scale
        var body = Path(ellipseIn: CGRect(x:center.x-62*s,y:center.y-35*s,width:124*s,height:78*s)); strokePath(body, context:&context)
        var head = Path(ellipseIn: CGRect(x:center.x-78*s,y:center.y-48*s,width:70*s,height:62*s)); strokePath(head, context:&context)
        strokePath(Path(ellipseIn:CGRect(x:center.x-56*s,y:center.y-52*s,width:15*s,height:15*s)), context:&context)
        strokePath(Path(ellipseIn:CGRect(x:center.x-72*s,y:center.y-20*s,width:7*s,height:7*s)), context:&context)
        for dx in [-38, 22] as [CGFloat] { var leg=Path(); leg.move(to:CGPoint(x:center.x+dx*s,y:center.y+28*s)); leg.addLine(to:CGPoint(x:center.x+dx*s,y:center.y+50*s)); leg.addLine(to:CGPoint(x:center.x+(dx+18)*s,y:center.y+50*s)); strokePath(leg,context:&context) }
    }

    private func drawUnicorn(context: inout GraphicsContext, center: CGPoint, scale: CGFloat) {
        let s=scale; strokePath(Path(ellipseIn:CGRect(x:center.x-58*s,y:center.y-20*s,width:116*s,height:64*s)),context:&context)
        strokePath(Path(ellipseIn:CGRect(x:center.x-65*s,y:center.y-58*s,width:52*s,height:52*s)),context:&context)
        var horn=Path(); horn.move(to:CGPoint(x:center.x-45*s,y:center.y-55*s)); horn.addLine(to:CGPoint(x:center.x-28*s,y:center.y-92*s)); horn.addLine(to:CGPoint(x:center.x-18*s,y:center.y-53*s)); strokePath(horn,context:&context)
        for dx in [-35, 24] as [CGFloat] { var leg=Path(); leg.move(to:CGPoint(x:center.x+dx*s,y:center.y+28*s)); leg.addLine(to:CGPoint(x:center.x+dx*s,y:center.y+60*s)); strokePath(leg,context:&context) }
        var tail=Path(); tail.move(to:CGPoint(x:center.x+56*s,y:center.y-4*s)); tail.addCurve(to:CGPoint(x:center.x+86*s,y:center.y+25*s),control1:CGPoint(x:center.x+90*s,y:center.y-30*s),control2:CGPoint(x:center.x+98*s,y:center.y+12*s)); strokePath(tail,context:&context)
    }

    private func drawPrincess(context: inout GraphicsContext, center: CGPoint, scale: CGFloat) {
        let s=scale; strokePath(Path(ellipseIn:CGRect(x:center.x-20*s,y:center.y-64*s,width:40*s,height:40*s)),context:&context)
        var dress=Path(); dress.move(to:CGPoint(x:center.x-18*s,y:center.y-20*s)); dress.addLine(to:CGPoint(x:center.x-62*s,y:center.y+58*s)); dress.addQuadCurve(to:CGPoint(x:center.x+62*s,y:center.y+58*s),control:CGPoint(x:center.x,y:center.y+78*s)); dress.addLine(to:CGPoint(x:center.x+18*s,y:center.y-20*s)); dress.closeSubpath(); strokePath(dress,context:&context)
        drawCrown(context:&context,center:CGPoint(x:center.x,y:center.y-70*s),size:18*s)
        for side in [-1,1] as [CGFloat] { var arm=Path(); arm.move(to:CGPoint(x:center.x+side*16*s,y:center.y-14*s)); arm.addLine(to:CGPoint(x:center.x+side*42*s,y:center.y+8*s)); strokePath(arm,context:&context) }
    }

    private func drawCastle(context: inout GraphicsContext, center: CGPoint, scale: CGFloat) {
        let s=scale; let base=CGRect(x:center.x-62*s,y:center.y-25*s,width:124*s,height:82*s); strokePath(Path(base),context:&context)
        for dx in [-48,0,48] as [CGFloat] { let tower=CGRect(x:center.x+(dx-16)*s,y:center.y-52*s,width:32*s,height:109*s); strokePath(Path(tower),context:&context); var roof=Path(); roof.move(to:CGPoint(x:center.x+(dx-22)*s,y:center.y-52*s)); roof.addLine(to:CGPoint(x:center.x+dx*s,y:center.y-82*s)); roof.addLine(to:CGPoint(x:center.x+(dx+22)*s,y:center.y-52*s)); roof.closeSubpath(); strokePath(roof,context:&context) }
        var door=Path(roundedRect:CGRect(x:center.x-14*s,y:center.y+27*s,width:28*s,height:30*s),cornerRadius:14*s); strokePath(door,context:&context)
    }

    private func drawDragon(context: inout GraphicsContext, center: CGPoint, scale: CGFloat) {
        let s=scale; strokePath(Path(ellipseIn:CGRect(x:center.x-50*s,y:center.y-22*s,width:100*s,height:62*s)),context:&context); strokePath(Path(ellipseIn:CGRect(x:center.x-69*s,y:center.y-48*s,width:45*s,height:42*s)),context:&context)
        var wing=Path(); wing.move(to:CGPoint(x:center.x-5*s,y:center.y-18*s)); wing.addLine(to:CGPoint(x:center.x+18*s,y:center.y-72*s)); wing.addLine(to:CGPoint(x:center.x+45*s,y:center.y-30*s)); wing.closeSubpath(); strokePath(wing,context:&context)
        var tail=Path(); tail.move(to:CGPoint(x:center.x+45*s,y:center.y+10*s)); tail.addCurve(to:CGPoint(x:center.x+92*s,y:center.y+28*s),control1:CGPoint(x:center.x+75*s,y:center.y-2*s),control2:CGPoint(x:center.x+85*s,y:center.y+6*s)); strokePath(tail,context:&context)
    }

    private func drawMermaid(context: inout GraphicsContext, center: CGPoint, scale: CGFloat) {
        let s=scale; strokePath(Path(ellipseIn:CGRect(x:center.x-18*s,y:center.y-65*s,width:36*s,height:36*s)),context:&context)
        var torso=Path(); torso.move(to:CGPoint(x:center.x-16*s,y:center.y-26*s)); torso.addLine(to:CGPoint(x:center.x+16*s,y:center.y-26*s)); torso.addLine(to:CGPoint(x:center.x+12*s,y:center.y+12*s)); torso.addLine(to:CGPoint(x:center.x-12*s,y:center.y+12*s)); torso.closeSubpath(); strokePath(torso,context:&context)
        var tail=Path(); tail.move(to:CGPoint(x:center.x-12*s,y:center.y+12*s)); tail.addCurve(to:CGPoint(x:center.x+12*s,y:center.y+62*s),control1:CGPoint(x:center.x-28*s,y:center.y+36*s),control2:CGPoint(x:center.x+22*s,y:center.y+42*s)); tail.addCurve(to:CGPoint(x:center.x,y:center.y+12*s),control1:CGPoint(x:center.x-2*s,y:center.y+54*s),control2:CGPoint(x:center.x+14*s,y:center.y+28*s)); strokePath(tail,context:&context)
        var fin=Path(); fin.move(to:CGPoint(x:center.x+12*s,y:center.y+62*s)); fin.addLine(to:CGPoint(x:center.x+42*s,y:center.y+77*s)); fin.addLine(to:CGPoint(x:center.x+22*s,y:center.y+48*s)); strokePath(fin,context:&context)
    }

    private func drawDinosaur(context: inout GraphicsContext, center: CGPoint, scale: CGFloat) {
        let s=scale; strokePath(Path(ellipseIn:CGRect(x:center.x-54*s,y:center.y-20*s,width:108*s,height:65*s)),context:&context); strokePath(Path(ellipseIn:CGRect(x:center.x-68*s,y:center.y-54*s,width:49*s,height:44*s)),context:&context)
        var tail=Path(); tail.move(to:CGPoint(x:center.x+48*s,y:center.y+4*s)); tail.addLine(to:CGPoint(x:center.x+96*s,y:center.y-12*s)); tail.addQuadCurve(to:CGPoint(x:center.x+48*s,y:center.y+24*s),control:CGPoint(x:center.x+82*s,y:center.y+18*s)); strokePath(tail,context:&context)
        for i in 0..<5 { let x=center.x-20*s+CGFloat(i)*15*s; var spike=Path(); spike.move(to:CGPoint(x:x,y:center.y-22*s)); spike.addLine(to:CGPoint(x:x+7*s,y:center.y-38*s)); spike.addLine(to:CGPoint(x:x+14*s,y:center.y-21*s)); strokePath(spike,context:&context) }
    }

    private func drawFox(context: inout GraphicsContext, center: CGPoint, scale: CGFloat) {
        let s=scale; strokePath(Path(ellipseIn:CGRect(x:center.x-48*s,y:center.y-15*s,width:96*s,height:60*s)),context:&context)
        var head=Path(); head.move(to:CGPoint(x:center.x-52*s,y:center.y-14*s)); head.addLine(to:CGPoint(x:center.x-72*s,y:center.y-52*s)); head.addLine(to:CGPoint(x:center.x-43*s,y:center.y-42*s)); head.addLine(to:CGPoint(x:center.x-22*s,y:center.y-52*s)); head.addLine(to:CGPoint(x:center.x-18*s,y:center.y-10*s)); head.closeSubpath(); strokePath(head,context:&context)
        var tail=Path(); tail.addCurve(to:CGPoint(x:center.x+82*s,y:center.y+27*s),control1:CGPoint(x:center.x+77*s,y:center.y-42*s),control2:CGPoint(x:center.x+105*s,y:center.y+12*s)); tail.addCurve(to:CGPoint(x:center.x+42*s,y:center.y+32*s),control1:CGPoint(x:center.x+68*s,y:center.y+48*s),control2:CGPoint(x:center.x+51*s,y:center.y+42*s)); strokePath(tail,context:&context)
    }

    private func drawBunny(context: inout GraphicsContext, center: CGPoint, scale: CGFloat) {
        let s=scale; strokePath(Path(ellipseIn:CGRect(x:center.x-42*s,y:center.y-12*s,width:84*s,height:62*s)),context:&context); strokePath(Path(ellipseIn:CGRect(x:center.x-34*s,y:center.y-48*s,width:58*s,height:48*s)),context:&context)
        strokePath(Path(ellipseIn:CGRect(x:center.x-30*s,y:center.y-91*s,width:18*s,height:52*s)),context:&context); strokePath(Path(ellipseIn:CGRect(x:center.x+1*s,y:center.y-92*s,width:18*s,height:53*s)),context:&context)
    }

    private func drawPirate(context: inout GraphicsContext, center: CGPoint, scale: CGFloat) {
        let s=scale; strokePath(Path(ellipseIn:CGRect(x:center.x-24*s,y:center.y-64*s,width:48*s,height:48*s)),context:&context)
        var hat=Path(); hat.move(to:CGPoint(x:center.x-38*s,y:center.y-58*s)); hat.addQuadCurve(to:CGPoint(x:center.x+38*s,y:center.y-58*s),control:CGPoint(x:center.x,y:center.y-92*s)); hat.addLine(to:CGPoint(x:center.x+24*s,y:center.y-47*s)); hat.addLine(to:CGPoint(x:center.x-25*s,y:center.y-47*s)); hat.closeSubpath(); strokePath(hat,context:&context)
        var body=Path(roundedRect:CGRect(x:center.x-28*s,y:center.y-16*s,width:56*s,height:72*s),cornerRadius:12*s); strokePath(body,context:&context)
        var sword=Path(); sword.move(to:CGPoint(x:center.x+28*s,y:center.y+5*s)); sword.addLine(to:CGPoint(x:center.x+66*s,y:center.y-28*s)); strokePath(sword,context:&context)
    }

    // MARK: - Simple motifs

    private func drawMoon(context: inout GraphicsContext, center: CGPoint, size: CGFloat) { strokePath(Path(ellipseIn:CGRect(x:center.x-size,y:center.y-size,width:size*2,height:size*2)),context:&context); strokePath(Path(ellipseIn:CGRect(x:center.x-size*0.25,y:center.y-size*0.85,width:size*1.45,height:size*1.7)),context:&context) }
    private func drawSun(context: inout GraphicsContext, center: CGPoint, size: CGFloat) { strokePath(Path(ellipseIn:CGRect(x:center.x-size*0.55,y:center.y-size*0.55,width:size*1.1,height:size*1.1)),context:&context); for i in 0..<12 { let a=CGFloat(i)*.pi/6; var p=Path(); p.move(to:CGPoint(x:center.x+cos(a)*size*0.7,y:center.y+sin(a)*size*0.7)); p.addLine(to:CGPoint(x:center.x+cos(a)*size*1.1,y:center.y+sin(a)*size*1.1)); strokePath(p,context:&context) } }
    private func drawCloud(context: inout GraphicsContext, center: CGPoint, size: CGFloat) { var p=Path(); p.addRoundedRect(in:CGRect(x:center.x-size,y:center.y-size*0.2,width:size*2,height:size*0.7),cornerSize:CGSize(width:size*0.3,height:size*0.3)); p.addEllipse(in:CGRect(x:center.x-size*0.65,y:center.y-size*0.65,width:size*0.8,height:size*0.8)); p.addEllipse(in:CGRect(x:center.x-size*0.1,y:center.y-size*0.85,width:size,height:size)); strokePath(p,context:&context) }
    private func drawRainbow(context: inout GraphicsContext, center: CGPoint, size: CGFloat) { for i in 0..<4 { var p=Path(); p.addArc(center:center,radius:size-CGFloat(i)*12,startAngle:.degrees(180),endAngle:.degrees(360),clockwise:false); strokePath(p,context:&context) } }
    private func drawFlower(context: inout GraphicsContext, center: CGPoint, size: CGFloat, petals: Int) { strokePath(Path(ellipseIn:CGRect(x:center.x-size*0.22,y:center.y-size*0.22,width:size*0.44,height:size*0.44)),context:&context); for i in 0..<petals { let a=CGFloat(i)*2*.pi/CGFloat(petals); let pc=CGPoint(x:center.x+cos(a)*size*0.52,y:center.y+sin(a)*size*0.52); strokePath(Path(ellipseIn:CGRect(x:pc.x-size*0.25,y:pc.y-size*0.36,width:size*0.5,height:size*0.72)),context:&context) }; var stem=Path(); stem.move(to:CGPoint(x:center.x,y:center.y+size*0.6)); stem.addLine(to:CGPoint(x:center.x,y:center.y+size*1.35)); strokePath(stem,context:&context) }
    private func drawButterfly(context: inout GraphicsContext, center: CGPoint, size: CGFloat) { strokePath(Path(ellipseIn:CGRect(x:center.x-size*0.1,y:center.y-size*0.55,width:size*0.2,height:size*1.1)),context:&context); for side in [-1,1] as [CGFloat] { strokePath(Path(ellipseIn:CGRect(x:center.x+side*size*0.12-(side<0 ? size*0.75:0),y:center.y-size*0.55,width:size*0.75,height:size*0.6)),context:&context); strokePath(Path(ellipseIn:CGRect(x:center.x+side*size*0.12-(side<0 ? size*0.58:0),y:center.y+size*0.02,width:size*0.58,height:size*0.46)),context:&context) } }
    private func drawCrown(context: inout GraphicsContext, center: CGPoint, size: CGFloat) { var p=Path(); p.move(to:CGPoint(x:center.x-size,y:center.y+size*0.45)); p.addLine(to:CGPoint(x:center.x-size*0.85,y:center.y-size*0.55)); p.addLine(to:CGPoint(x:center.x-size*0.28,y:center.y)); p.addLine(to:CGPoint(x:center.x,y:center.y-size*0.75)); p.addLine(to:CGPoint(x:center.x+size*0.3,y:center.y)); p.addLine(to:CGPoint(x:center.x+size*0.85,y:center.y-size*0.55)); p.addLine(to:CGPoint(x:center.x+size,y:center.y+size*0.45)); p.closeSubpath(); strokePath(p,context:&context) }
    private func drawSimpleUnicorn(context: inout GraphicsContext, center: CGPoint, size: CGFloat) { strokePath(Path(ellipseIn:CGRect(x:center.x-size*0.55,y:center.y-size*0.4,width:size*1.1,height:size*0.9)),context:&context); var horn=Path(); horn.move(to:CGPoint(x:center.x-size*0.1,y:center.y-size*0.38)); horn.addLine(to:CGPoint(x:center.x+size*0.15,y:center.y-size*1.15)); horn.addLine(to:CGPoint(x:center.x+size*0.32,y:center.y-size*0.35)); strokePath(horn,context:&context); drawFlower(context:&context,center:CGPoint(x:center.x-size*0.45,y:center.y-size*0.25),size:size*0.18,petals:5) }
    private func drawSimpleCat(context: inout GraphicsContext, center: CGPoint, size: CGFloat) { var p=Path(); p.move(to:CGPoint(x:center.x-size*0.7,y:center.y-size*0.2)); p.addLine(to:CGPoint(x:center.x-size*0.55,y:center.y-size)); p.addLine(to:CGPoint(x:center.x-size*0.15,y:center.y-size*0.55)); p.addLine(to:CGPoint(x:center.x+size*0.2,y:center.y-size)); p.addLine(to:CGPoint(x:center.x+size*0.65,y:center.y-size*0.2)); p.addQuadCurve(to:CGPoint(x:center.x,y:center.y+size*0.75),control:CGPoint(x:center.x+size*0.8,y:center.y+size*0.6)); p.addQuadCurve(to:CGPoint(x:center.x-size*0.7,y:center.y-size*0.2),control:CGPoint(x:center.x-size*0.8,y:center.y+size*0.55)); strokePath(p,context:&context) }
    private func drawSimpleDog(context: inout GraphicsContext, center: CGPoint, size: CGFloat) { strokePath(Path(ellipseIn:CGRect(x:center.x-size*0.6,y:center.y-size*0.55,width:size*1.2,height:size*1.1)),context:&context); strokePath(Path(ellipseIn:CGRect(x:center.x-size*0.95,y:center.y-size*0.5,width:size*0.5,height:size*0.8)),context:&context); strokePath(Path(ellipseIn:CGRect(x:center.x+size*0.45,y:center.y-size*0.5,width:size*0.5,height:size*0.8)),context:&context) }
    private func drawFish(context: inout GraphicsContext, center: CGPoint, size: CGFloat) { strokePath(Path(ellipseIn:CGRect(x:center.x-size*0.7,y:center.y-size*0.42,width:size*1.35,height:size*0.84)),context:&context); var tail=Path(); tail.move(to:CGPoint(x:center.x+size*0.6,y:center.y)); tail.addLine(to:CGPoint(x:center.x+size*1.15,y:center.y-size*0.55)); tail.addLine(to:CGPoint(x:center.x+size*1.15,y:center.y+size*0.55)); tail.closeSubpath(); strokePath(tail,context:&context) }
    private func drawApple(context: inout GraphicsContext, center: CGPoint, size: CGFloat) { var p=Path(); p.addCurve(to:CGPoint(x:center.x,y:center.y+size),control1:CGPoint(x:center.x-size*1.05,y:center.y-size*0.65),control2:CGPoint(x:center.x-size*0.95,y:center.y+size*0.85)); p.addCurve(to:CGPoint(x:center.x,y:center.y-size*0.55),control1:CGPoint(x:center.x+size*0.95,y:center.y+size*0.85),control2:CGPoint(x:center.x+size*1.05,y:center.y-size*0.65)); p.closeSubpath(); strokePath(p,context:&context); var stem=Path(); stem.move(to:CGPoint(x:center.x,y:center.y-size*0.55)); stem.addLine(to:CGPoint(x:center.x+size*0.12,y:center.y-size*1.0)); strokePath(stem,context:&context) }
    private func drawCupcake(context: inout GraphicsContext, center: CGPoint, size: CGFloat) { var cup=Path(); cup.move(to:CGPoint(x:center.x-size*0.65,y:center.y)); cup.addLine(to:CGPoint(x:center.x-size*0.45,y:center.y+size)); cup.addLine(to:CGPoint(x:center.x+size*0.45,y:center.y+size)); cup.addLine(to:CGPoint(x:center.x+size*0.65,y:center.y)); cup.closeSubpath(); strokePath(cup,context:&context); var top=Path(); top.addCurve(to:CGPoint(x:center.x+size*0.65,y:center.y),control1:CGPoint(x:center.x-size*0.5,y:center.y-size),control2:CGPoint(x:center.x+size*0.5,y:center.y-size)); strokePath(top,context:&context) }
    private func drawRocket(context: inout GraphicsContext, center: CGPoint, size: CGFloat) { var p=Path(); p.move(to:CGPoint(x:center.x,y:center.y-size)); p.addCurve(to:CGPoint(x:center.x-size*0.45,y:center.y+size*0.45),control1:CGPoint(x:center.x-size*0.75,y:center.y-size*0.15),control2:CGPoint(x:center.x-size*0.55,y:center.y+size*0.25)); p.addLine(to:CGPoint(x:center.x+size*0.45,y:center.y+size*0.45)); p.addCurve(to:CGPoint(x:center.x,y:center.y-size),control1:CGPoint(x:center.x+size*0.55,y:center.y+size*0.25),control2:CGPoint(x:center.x+size*0.75,y:center.y-size*0.15)); strokePath(p,context:&context); strokePath(Path(ellipseIn:CGRect(x:center.x-size*0.2,y:center.y-size*0.3,width:size*0.4,height:size*0.4)),context:&context) }
    private func drawCar(context: inout GraphicsContext, center: CGPoint, size: CGFloat) { var p=Path(roundedRect:CGRect(x:center.x-size,y:center.y-size*0.15,width:size*2,height:size*0.65),cornerRadius:size*0.18); strokePath(p,context:&context); var roof=Path(); roof.move(to:CGPoint(x:center.x-size*0.5,y:center.y-size*0.15)); roof.addLine(to:CGPoint(x:center.x-size*0.15,y:center.y-size*0.65)); roof.addLine(to:CGPoint(x:center.x+size*0.45,y:center.y-size*0.65)); roof.addLine(to:CGPoint(x:center.x+size*0.72,y:center.y-size*0.15)); strokePath(roof,context:&context); for dx in [-0.55,0.55] as [CGFloat] { strokePath(Path(ellipseIn:CGRect(x:center.x+dx*size-size*0.18,y:center.y+size*0.28,width:size*0.36,height:size*0.36)),context:&context) } }
    private func drawTree(context: inout GraphicsContext, center: CGPoint, size: CGFloat) { var trunk=Path(); trunk.move(to:CGPoint(x:center.x-size*0.18,y:center.y+size)); trunk.addLine(to:CGPoint(x:center.x-size*0.1,y:center.y+size*0.1)); trunk.addLine(to:CGPoint(x:center.x+size*0.12,y:center.y+size*0.1)); trunk.addLine(to:CGPoint(x:center.x+size*0.18,y:center.y+size)); strokePath(trunk,context:&context); strokePath(Path(ellipseIn:CGRect(x:center.x-size*0.75,y:center.y-size*0.72,width:size*1.5,height:size)),context:&context) }
    private func drawHouse(context: inout GraphicsContext, center: CGPoint, size: CGFloat) { strokePath(Path(CGRect(x:center.x-size*0.65,y:center.y-size*0.1,width:size*1.3,height:size*1.0)),context:&context); var roof=Path(); roof.move(to:CGPoint(x:center.x-size*0.85,y:center.y-size*0.1)); roof.addLine(to:CGPoint(x:center.x,y:center.y-size*0.85)); roof.addLine(to:CGPoint(x:center.x+size*0.85,y:center.y-size*0.1)); strokePath(roof,context:&context); strokePath(Path(CGRect(x:center.x-size*0.15,y:center.y+size*0.38,width:size*0.3,height:size*0.52)),context:&context) }

    // MARK: - Paths

    private func strokePath(_ path: Path, context: inout GraphicsContext, stroke: StrokeStyle = StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round)) {
        context.stroke(path, with: .color(.black), style: stroke)
    }

    private func heartPath(center: CGPoint, size: CGFloat) -> Path {
        var p=Path(); p.move(to:CGPoint(x:center.x,y:center.y+size*0.55)); p.addCurve(to:CGPoint(x:center.x-size*0.72,y:center.y-size*0.15),control1:CGPoint(x:center.x-size*0.12,y:center.y+size*0.18),control2:CGPoint(x:center.x-size*0.72,y:center.y+size*0.35)); p.addCurve(to:CGPoint(x:center.x,y:center.y-size*0.42),control1:CGPoint(x:center.x-size*0.82,y:center.y-size*0.72),control2:CGPoint(x:center.x-size*0.24,y:center.y-size*0.75)); p.addCurve(to:CGPoint(x:center.x+size*0.72,y:center.y-size*0.15),control1:CGPoint(x:center.x+size*0.24,y:center.y-size*0.75),control2:CGPoint(x:center.x+size*0.82,y:center.y-size*0.72)); p.addCurve(to:CGPoint(x:center.x,y:center.y+size*0.55),control1:CGPoint(x:center.x+size*0.72,y:center.y+size*0.35),control2:CGPoint(x:center.x+size*0.12,y:center.y+size*0.18)); return p
    }

    private func starPath(center: CGPoint, radius: CGFloat, points: Int) -> Path {
        var p=Path(); let count=points*2
        for i in 0..<count { let r=i.isMultiple(of:2) ? radius : radius*0.44; let a=-CGFloat.pi/2+CGFloat(i)*CGFloat.pi/CGFloat(points); let point=CGPoint(x:center.x+cos(a)*r,y:center.y+sin(a)*r); if i==0 { p.move(to:point) } else { p.addLine(to:point) } }; p.closeSubpath(); return p
    }

    private func diamondPath(center: CGPoint, size: CGFloat) -> Path {
        var p=Path(); p.move(to:CGPoint(x:center.x,y:center.y-size)); p.addLine(to:CGPoint(x:center.x+size*0.82,y:center.y-size*0.25)); p.addLine(to:CGPoint(x:center.x,y:center.y+size)); p.addLine(to:CGPoint(x:center.x-size*0.82,y:center.y-size*0.25)); p.closeSubpath(); return p
    }
}
