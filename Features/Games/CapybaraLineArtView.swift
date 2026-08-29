import SwiftUI

struct CapybaraLineArtView: View {
    let sceneIndex: Int
    var lineOpacity: Double = 1

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let stroke = StrokeStyle(lineWidth: max(1.4, min(w, h) * 0.008), lineCap: .round, lineJoin: .round)
            let ink = Color.black.opacity(lineOpacity)

            func strokePath(_ path: Path, width: CGFloat? = nil) {
                context.stroke(path, with: .color(ink), style: StrokeStyle(lineWidth: width ?? stroke.lineWidth, lineCap: .round, lineJoin: .round))
            }

            func capybara(center: CGPoint, scale: CGFloat, baby: Bool = false) {
                let s = scale * (baby ? 0.72 : 1)
                var body = Path()
                body.addEllipse(in: CGRect(x: center.x - 88*s, y: center.y - 48*s, width: 176*s, height: 96*s))
                strokePath(body)

                var head = Path()
                head.move(to: CGPoint(x: center.x + 58*s, y: center.y - 28*s))
                head.addCurve(to: CGPoint(x: center.x + 118*s, y: center.y - 8*s), control1: CGPoint(x: center.x + 80*s, y: center.y - 48*s), control2: CGPoint(x: center.x + 112*s, y: center.y - 34*s))
                head.addCurve(to: CGPoint(x: center.x + 102*s, y: center.y + 28*s), control1: CGPoint(x: center.x + 124*s, y: center.y + 4*s), control2: CGPoint(x: center.x + 118*s, y: center.y + 22*s))
                head.addCurve(to: CGPoint(x: center.x + 60*s, y: center.y + 22*s), control1: CGPoint(x: center.x + 86*s, y: center.y + 40*s), control2: CGPoint(x: center.x + 70*s, y: center.y + 32*s))
                strokePath(head)

                var ear1 = Path(); ear1.addEllipse(in: CGRect(x: center.x + 66*s, y: center.y - 45*s, width: 20*s, height: 20*s)); strokePath(ear1)
                var ear2 = Path(); ear2.addEllipse(in: CGRect(x: center.x + 88*s, y: center.y - 41*s, width: 16*s, height: 16*s)); strokePath(ear2)
                var eye = Path(); eye.addEllipse(in: CGRect(x: center.x + 93*s, y: center.y - 20*s, width: 5*s, height: 5*s)); context.fill(eye, with: .color(ink))
                var nose = Path(); nose.addEllipse(in: CGRect(x: center.x + 116*s, y: center.y - 7*s, width: 7*s, height: 5*s)); context.fill(nose, with: .color(ink))

                for dx in [-54.0, -20.0, 34.0, 62.0] {
                    var leg = Path()
                    leg.move(to: CGPoint(x: center.x + CGFloat(dx)*s, y: center.y + 30*s))
                    leg.addLine(to: CGPoint(x: center.x + CGFloat(dx-4)*s, y: center.y + 62*s))
                    leg.addLine(to: CGPoint(x: center.x + CGFloat(dx+8)*s, y: center.y + 62*s))
                    strokePath(leg)
                }

                var smile = Path()
                smile.move(to: CGPoint(x: center.x + 112*s, y: center.y + 7*s))
                smile.addQuadCurve(to: CGPoint(x: center.x + 98*s, y: center.y + 12*s), control: CGPoint(x: center.x + 106*s, y: center.y + 14*s))
                strokePath(smile, width: max(1, stroke.lineWidth * 0.75))

                for i in 0..<7 {
                    let x = center.x - 66*s + CGFloat(i) * 21*s
                    var fur = Path()
                    fur.move(to: CGPoint(x: x, y: center.y - 16*s))
                    fur.addLine(to: CGPoint(x: x + 8*s, y: center.y - 10*s))
                    strokePath(fur, width: max(0.8, stroke.lineWidth * 0.55))
                }
            }

            func tree(x: CGFloat, ground: CGFloat, scale: CGFloat) {
                var trunk = Path()
                trunk.move(to: CGPoint(x: x - 14*scale, y: ground))
                trunk.addCurve(to: CGPoint(x: x - 8*scale, y: ground - 120*scale), control1: CGPoint(x: x - 24*scale, y: ground - 55*scale), control2: CGPoint(x: x - 18*scale, y: ground - 95*scale))
                trunk.move(to: CGPoint(x: x + 16*scale, y: ground))
                trunk.addCurve(to: CGPoint(x: x + 8*scale, y: ground - 120*scale), control1: CGPoint(x: x + 26*scale, y: ground - 52*scale), control2: CGPoint(x: x + 18*scale, y: ground - 92*scale))
                strokePath(trunk)
                for i in 0..<6 {
                    let angle = Double(i) * .pi / 3
                    let cx = x + CGFloat(cos(angle)) * 34*scale
                    let cy = ground - 128*scale + CGFloat(sin(angle)) * 18*scale
                    var crown = Path(); crown.addEllipse(in: CGRect(x: cx - 34*scale, y: cy - 22*scale, width: 68*scale, height: 44*scale)); strokePath(crown)
                }
            }

            func flower(x: CGFloat, y: CGFloat, scale: CGFloat) {
                var stem = Path(); stem.move(to: CGPoint(x: x, y: y + 26*scale)); stem.addLine(to: CGPoint(x: x, y: y)); strokePath(stem, width: max(0.8, stroke.lineWidth*0.6))
                for i in 0..<5 {
                    let a = Double(i) * 2 * .pi / 5
                    let cx = x + CGFloat(cos(a))*8*scale
                    let cy = y + CGFloat(sin(a))*8*scale
                    var petal = Path(); petal.addEllipse(in: CGRect(x: cx-4*scale, y: cy-4*scale, width: 8*scale, height: 8*scale)); strokePath(petal, width: max(0.8, stroke.lineWidth*0.6))
                }
            }

            func water(y: CGFloat) {
                for row in 0..<3 {
                    var wave = Path()
                    let yy = y + CGFloat(row)*18
                    wave.move(to: CGPoint(x: w*0.08, y: yy))
                    var x = w*0.08
                    while x < w*0.92 {
                        wave.addQuadCurve(to: CGPoint(x: x + 42, y: yy), control: CGPoint(x: x + 21, y: yy - 8))
                        x += 42
                    }
                    strokePath(wave, width: max(0.8, stroke.lineWidth*0.65))
                }
            }

            let ground = h * 0.78
            var groundPath = Path(); groundPath.move(to: CGPoint(x: w*0.05, y: ground)); groundPath.addQuadCurve(to: CGPoint(x: w*0.95, y: ground), control: CGPoint(x: w*0.52, y: ground - 18)); strokePath(groundPath)

            switch sceneIndex {
            case 0:
                tree(x: w*0.18, ground: ground, scale: 1.0)
                tree(x: w*0.83, ground: ground, scale: 0.8)
                capybara(center: CGPoint(x: w*0.52, y: ground - h*0.17), scale: min(w/520, h/420))
                for i in 0..<6 { flower(x: w*(0.18 + Double(i)*0.12), y: ground - 8, scale: 0.8) }
            case 1:
                capybara(center: CGPoint(x: w*0.48, y: ground - h*0.18), scale: min(w/540, h/430))
                water(y: ground - 10)
                var mountain = Path(); mountain.move(to: CGPoint(x: w*0.08, y: h*0.42)); mountain.addLine(to: CGPoint(x: w*0.28, y: h*0.18)); mountain.addLine(to: CGPoint(x: w*0.44, y: h*0.42)); mountain.addLine(to: CGPoint(x: w*0.62, y: h*0.22)); mountain.addLine(to: CGPoint(x: w*0.86, y: h*0.42)); strokePath(mountain)
            case 2:
                capybara(center: CGPoint(x: w*0.50, y: ground - h*0.20), scale: min(w/620, h/500))
                capybara(center: CGPoint(x: w*0.30, y: ground - h*0.09), scale: min(w/820, h/620), baby: true)
                capybara(center: CGPoint(x: w*0.66, y: ground - h*0.09), scale: min(w/820, h/620), baby: true)
                capybara(center: CGPoint(x: w*0.48, y: ground - h*0.04), scale: min(w/940, h/700), baby: true)
            case 3:
                capybara(center: CGPoint(x: w*0.50, y: ground - h*0.17), scale: min(w/560, h/450))
                for i in 0..<8 { flower(x: w*(0.12 + Double(i)*0.105), y: ground - CGFloat((i%2)*16), scale: 0.9) }
                for i in 0..<4 {
                    let bx = w*(0.22 + Double(i)*0.17)
                    let by = h*(0.24 + Double(i%2)*0.08)
                    var butterfly = Path(); butterfly.addEllipse(in: CGRect(x: bx-12, y: by-5, width: 11, height: 14)); butterfly.addEllipse(in: CGRect(x: bx+1, y: by-5, width: 11, height: 14)); strokePath(butterfly)
                }
            case 4:
                tree(x: w*0.5, ground: ground, scale: 1.25)
                capybara(center: CGPoint(x: w*0.48, y: ground - h*0.10), scale: min(w/650, h/520))
            case 5:
                capybara(center: CGPoint(x: w*0.43, y: ground - h*0.13), scale: min(w/650, h/520))
                var cliff = Path(); cliff.move(to: CGPoint(x: w*0.72, y: h*0.12)); cliff.addLine(to: CGPoint(x: w*0.72, y: h*0.65)); cliff.addLine(to: CGPoint(x: w*0.90, y: h*0.65)); strokePath(cliff)
                for i in 0..<5 { var fall = Path(); fall.move(to: CGPoint(x: w*(0.74 + Double(i)*0.035), y: h*0.15)); fall.addCurve(to: CGPoint(x: w*(0.74 + Double(i)*0.035), y: h*0.63), control1: CGPoint(x: w*(0.72 + Double(i)*0.035), y: h*0.30), control2: CGPoint(x: w*(0.76 + Double(i)*0.035), y: h*0.48)); strokePath(fall, width: max(0.8, stroke.lineWidth*0.6)) }
                water(y: ground - 6)
            case 6:
                capybara(center: CGPoint(x: w*0.50, y: ground - h*0.17), scale: min(w/560, h/450))
                for i in 0..<3 {
                    let bx = w*(0.32 + Double(i)*0.18)
                    let by = h*(0.20 + Double(i%2)*0.05)
                    var bird = Path(); bird.addArc(center: CGPoint(x: bx, y: by), radius: 12, startAngle: .degrees(190), endAngle: .degrees(340), clockwise: false); bird.addArc(center: CGPoint(x: bx+20, y: by), radius: 12, startAngle: .degrees(200), endAngle: .degrees(350), clockwise: false); strokePath(bird)
                }
                for i in 0..<7 { flower(x: w*(0.13 + Double(i)*0.12), y: ground - CGFloat((i%3)*8), scale: 0.75) }
            case 7:
                tree(x: w*0.18, ground: ground, scale: 0.95)
                tree(x: w*0.83, ground: ground, scale: 0.95)
                capybara(center: CGPoint(x: w*0.50, y: ground - h*0.16), scale: min(w/570, h/460))
                for i in 0..<9 {
                    let sx = w*(0.12 + Double(i%5)*0.18)
                    let sy = h*(0.12 + Double(i/5)*0.10)
                    var star = Path(); star.move(to: CGPoint(x: sx, y: sy-7)); star.addLine(to: CGPoint(x: sx+2, y: sy-2)); star.addLine(to: CGPoint(x: sx+7, y: sy)); star.addLine(to: CGPoint(x: sx+2, y: sy+2)); star.addLine(to: CGPoint(x: sx, y: sy+7)); star.addLine(to: CGPoint(x: sx-2, y: sy+2)); star.addLine(to: CGPoint(x: sx-7, y: sy)); star.addLine(to: CGPoint(x: sx-2, y: sy-2)); star.closeSubpath(); strokePath(star, width: max(0.8, stroke.lineWidth*0.6))
                }
            case 8:
                capybara(center: CGPoint(x: w*0.50, y: ground - h*0.18), scale: min(w/600, h/470))
                water(y: ground - 8)
                for i in 0..<6 {
                    let lx = w*(0.14 + Double(i)*0.14)
                    var lily = Path(); lily.addEllipse(in: CGRect(x: lx-18, y: ground+42, width: 36, height: 12)); strokePath(lily, width: max(0.8, stroke.lineWidth*0.6)); flower(x: lx, y: ground+28, scale: 0.55)
                }
            default:
                capybara(center: CGPoint(x: w*0.50, y: ground - h*0.18), scale: min(w/600, h/470))
                water(y: ground - 5)
                for i in 0..<5 {
                    let sx = w*(0.16 + Double(i)*0.17)
                    var steam = Path(); steam.move(to: CGPoint(x: sx, y: h*0.22)); steam.addCurve(to: CGPoint(x: sx+3, y: h*0.42), control1: CGPoint(x: sx-10, y: h*0.28), control2: CGPoint(x: sx+12, y: h*0.34)); strokePath(steam, width: max(0.8, stroke.lineWidth*0.6))
                }
            }
        }
        .aspectRatio(4/3, contentMode: .fit)
        .background(Color.white)
    }
}

#Preview {
    VStack {
        CapybaraLineArtView(sceneIndex: 0)
        CapybaraLineArtView(sceneIndex: 2)
    }
    .padding()
}
