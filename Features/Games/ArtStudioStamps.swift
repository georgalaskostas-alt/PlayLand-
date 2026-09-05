import SwiftUI
import PencilKit
import UIKit

/// Reusable shapes/stamps for the Art Studio free-draw canvas.
enum ArtStudioStamp: String, CaseIterable, Identifiable {
    case circle
    case square
    case triangle
    case star
    case heart
    case sun
    case cloud
    case tree
    case flower
    case waves
    case house
    case mountain
    case rainbow
    case moon
    case butterfly
    case fish

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .circle: return "circle"
        case .square: return "square"
        case .triangle: return "triangle"
        case .star: return "star"
        case .heart: return "heart"
        case .sun: return "sun.max"
        case .cloud: return "cloud"
        case .tree: return "tree"
        case .flower: return "camera.macro"
        case .waves: return "water.waves"
        case .house: return "house"
        case .mountain: return "mountain.2"
        case .rainbow: return "rainbow"
        case .moon: return "moon"
        case .butterfly: return "ladybug"
        case .fish: return "fish"
        }
    }

    func name(isGreek: Bool) -> String {
        if isGreek {
            switch self {
            case .circle: return "Κύκλος"
            case .square: return "Τετράγωνο"
            case .triangle: return "Τρίγωνο"
            case .star: return "Αστέρι"
            case .heart: return "Καρδιά"
            case .sun: return "Ήλιος"
            case .cloud: return "Σύννεφο"
            case .tree: return "Δέντρο"
            case .flower: return "Λουλούδι"
            case .waves: return "Θάλασσα"
            case .house: return "Σπίτι"
            case .mountain: return "Βουνό"
            case .rainbow: return "Ουράνιο τόξο"
            case .moon: return "Φεγγάρι"
            case .butterfly: return "Πεταλούδα"
            case .fish: return "Ψάρι"
            }
        }

        switch self {
        case .circle: return "Circle"
        case .square: return "Square"
        case .triangle: return "Triangle"
        case .star: return "Star"
        case .heart: return "Heart"
        case .sun: return "Sun"
        case .cloud: return "Cloud"
        case .tree: return "Tree"
        case .flower: return "Flower"
        case .waves: return "Sea"
        case .house: return "House"
        case .mountain: return "Mountain"
        case .rainbow: return "Rainbow"
        case .moon: return "Moon"
        case .butterfly: return "Butterfly"
        case .fish: return "Fish"
        }
    }

    func strokes(center: CGPoint, color: UIColor, lineWidth: CGFloat, size: CGFloat = 118) -> [PKStroke] {
        let localPaths = paths(size: size)
        let translated = localPaths.map { points in
            points.map { CGPoint(x: center.x + $0.x, y: center.y + $0.y) }
        }
        return translated.compactMap { makeStroke(points: $0, color: color, lineWidth: max(2.5, lineWidth)) }
    }

    private func paths(size: CGFloat) -> [[CGPoint]] {
        let r = size * 0.5

        switch self {
        case .circle:
            return [ellipse(rx: r, ry: r)]

        case .square:
            return [[
                CGPoint(x: -r, y: -r), CGPoint(x: r, y: -r),
                CGPoint(x: r, y: r), CGPoint(x: -r, y: r), CGPoint(x: -r, y: -r)
            ]]

        case .triangle:
            return [[
                CGPoint(x: 0, y: -r), CGPoint(x: r, y: r),
                CGPoint(x: -r, y: r), CGPoint(x: 0, y: -r)
            ]]

        case .star:
            var p: [CGPoint] = []
            for i in 0..<10 {
                let radius = i.isMultiple(of: 2) ? r : r * 0.42
                let angle = -CGFloat.pi / 2 + CGFloat(i) * CGFloat.pi / 5
                p.append(CGPoint(x: cos(angle) * radius, y: sin(angle) * radius))
            }
            if let first = p.first { p.append(first) }
            return [p]

        case .heart:
            var p: [CGPoint] = []
            for i in 0...80 {
                let t = CGFloat(i) / 80 * 2 * CGFloat.pi
                let x = 16 * pow(sin(t), 3)
                let y = 13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t)
                p.append(CGPoint(x: x * size / 36, y: -y * size / 36 + size * 0.06))
            }
            return [p]

        case .sun:
            var result = [ellipse(rx: r * 0.48, ry: r * 0.48)]
            for i in 0..<12 {
                let a = CGFloat(i) * 2 * CGFloat.pi / 12
                result.append([
                    CGPoint(x: cos(a) * r * 0.64, y: sin(a) * r * 0.64),
                    CGPoint(x: cos(a) * r, y: sin(a) * r)
                ])
            }
            return result

        case .cloud:
            return [[
                CGPoint(x: -r, y: r * 0.20),
                CGPoint(x: -r * 0.80, y: -r * 0.08),
                CGPoint(x: -r * 0.58, y: -r * 0.18),
                CGPoint(x: -r * 0.48, y: -r * 0.52),
                CGPoint(x: -r * 0.12, y: -r * 0.66),
                CGPoint(x: r * 0.15, y: -r * 0.48),
                CGPoint(x: r * 0.34, y: -r * 0.30),
                CGPoint(x: r * 0.68, y: -r * 0.26),
                CGPoint(x: r, y: r * 0.06),
                CGPoint(x: r * 0.84, y: r * 0.38),
                CGPoint(x: r * 0.45, y: r * 0.48),
                CGPoint(x: -r * 0.55, y: r * 0.48),
                CGPoint(x: -r, y: r * 0.20)
            ]]

        case .tree:
            return [
                [CGPoint(x: -r * 0.18, y: r), CGPoint(x: -r * 0.12, y: r * 0.12), CGPoint(x: r * 0.12, y: r * 0.12), CGPoint(x: r * 0.18, y: r)],
                ellipse(rx: r * 0.62, ry: r * 0.48, center: CGPoint(x: 0, y: -r * 0.28)),
                ellipse(rx: r * 0.38, ry: r * 0.34, center: CGPoint(x: -r * 0.36, y: -r * 0.06)),
                ellipse(rx: r * 0.38, ry: r * 0.34, center: CGPoint(x: r * 0.36, y: -r * 0.06))
            ]

        case .flower:
            var result: [[CGPoint]] = []
            for i in 0..<6 {
                let a = CGFloat(i) * 2 * CGFloat.pi / 6
                let c = CGPoint(x: cos(a) * r * 0.48, y: sin(a) * r * 0.48)
                result.append(ellipse(rx: r * 0.28, ry: r * 0.34, center: c, rotation: a))
            }
            result.append(ellipse(rx: r * 0.20, ry: r * 0.20))
            result.append([CGPoint(x: 0, y: r * 0.20), CGPoint(x: 0, y: r)])
            result.append([CGPoint(x: 0, y: r * 0.62), CGPoint(x: -r * 0.35, y: r * 0.48), CGPoint(x: -r * 0.08, y: r * 0.76)])
            return result

        case .waves:
            return [-0.45, 0.0, 0.45].map { row in
                wave(y: r * CGFloat(row), width: size, amplitude: r * 0.18)
            }

        case .house:
            return [
                [CGPoint(x: -r * 0.76, y: -r * 0.05), CGPoint(x: 0, y: -r * 0.78), CGPoint(x: r * 0.76, y: -r * 0.05)],
                [CGPoint(x: -r * 0.62, y: -r * 0.18), CGPoint(x: -r * 0.62, y: r * 0.78), CGPoint(x: r * 0.62, y: r * 0.78), CGPoint(x: r * 0.62, y: -r * 0.18)],
                [CGPoint(x: -r * 0.16, y: r * 0.78), CGPoint(x: -r * 0.16, y: r * 0.26), CGPoint(x: r * 0.16, y: r * 0.26), CGPoint(x: r * 0.16, y: r * 0.78)],
                [CGPoint(x: -r * 0.47, y: r * 0.05), CGPoint(x: -r * 0.25, y: r * 0.05), CGPoint(x: -r * 0.25, y: r * 0.28), CGPoint(x: -r * 0.47, y: r * 0.28), CGPoint(x: -r * 0.47, y: r * 0.05)]
            ]

        case .mountain:
            return [[
                CGPoint(x: -r, y: r * 0.72), CGPoint(x: -r * 0.30, y: -r * 0.65),
                CGPoint(x: 0, y: -r * 0.12), CGPoint(x: r * 0.34, y: -r * 0.82),
                CGPoint(x: r, y: r * 0.72)
            ], [
                CGPoint(x: -r * 0.50, y: -r * 0.28), CGPoint(x: -r * 0.30, y: -r * 0.65), CGPoint(x: -r * 0.08, y: -r * 0.24)
            ], [
                CGPoint(x: r * 0.16, y: -r * 0.45), CGPoint(x: r * 0.34, y: -r * 0.82), CGPoint(x: r * 0.52, y: -r * 0.42)
            ]]

        case .rainbow:
            return [0.0, 0.18, 0.36, 0.54].map { inset in
                arc(radius: r * (1 - CGFloat(inset)), start: CGFloat.pi, end: 2 * CGFloat.pi)
            }

        case .moon:
            return [arc(radius: r, start: -CGFloat.pi * 0.70, end: CGFloat.pi * 0.70),
                    arc(radius: r * 0.76, center: CGPoint(x: r * 0.34, y: 0), start: CGFloat.pi * 0.70, end: -CGFloat.pi * 0.70)]

        case .butterfly:
            return [
                ellipse(rx: r * 0.42, ry: r * 0.50, center: CGPoint(x: -r * 0.38, y: -r * 0.12), rotation: -0.28),
                ellipse(rx: r * 0.42, ry: r * 0.50, center: CGPoint(x: r * 0.38, y: -r * 0.12), rotation: 0.28),
                ellipse(rx: r * 0.28, ry: r * 0.34, center: CGPoint(x: -r * 0.30, y: r * 0.40), rotation: 0.35),
                ellipse(rx: r * 0.28, ry: r * 0.34, center: CGPoint(x: r * 0.30, y: r * 0.40), rotation: -0.35),
                [CGPoint(x: 0, y: -r * 0.44), CGPoint(x: 0, y: r * 0.62)],
                [CGPoint(x: -r * 0.03, y: -r * 0.42), CGPoint(x: -r * 0.24, y: -r * 0.78)],
                [CGPoint(x: r * 0.03, y: -r * 0.42), CGPoint(x: r * 0.24, y: -r * 0.78)]
            ]

        case .fish:
            return [
                ellipse(rx: r * 0.72, ry: r * 0.44, center: CGPoint(x: -r * 0.12, y: 0)),
                [CGPoint(x: r * 0.50, y: 0), CGPoint(x: r, y: -r * 0.45), CGPoint(x: r, y: r * 0.45), CGPoint(x: r * 0.50, y: 0)],
                ellipse(rx: r * 0.055, ry: r * 0.055, center: CGPoint(x: -r * 0.48, y: -r * 0.10)),
                [CGPoint(x: -r * 0.08, y: -r * 0.40), CGPoint(x: r * 0.18, y: -r * 0.70), CGPoint(x: r * 0.30, y: -r * 0.34)]
            ]
        }
    }

    private func ellipse(rx: CGFloat, ry: CGFloat, center: CGPoint = .zero, rotation: CGFloat = 0) -> [CGPoint] {
        (0...48).map { i in
            let a = CGFloat(i) / 48 * 2 * CGFloat.pi
            let x = cos(a) * rx
            let y = sin(a) * ry
            return CGPoint(
                x: center.x + x * cos(rotation) - y * sin(rotation),
                y: center.y + x * sin(rotation) + y * cos(rotation)
            )
        }
    }

    private func arc(radius: CGFloat, center: CGPoint = .zero, start: CGFloat, end: CGFloat) -> [CGPoint] {
        (0...42).map { i in
            let t = CGFloat(i) / 42
            let a = start + (end - start) * t
            return CGPoint(x: center.x + cos(a) * radius, y: center.y + sin(a) * radius)
        }
    }

    private func wave(y: CGFloat, width: CGFloat, amplitude: CGFloat) -> [CGPoint] {
        (0...40).map { i in
            let t = CGFloat(i) / 40
            let x = -width * 0.5 + width * t
            return CGPoint(x: x, y: y + sin(t * 4 * CGFloat.pi) * amplitude)
        }
    }

    private func makeStroke(points: [CGPoint], color: UIColor, lineWidth: CGFloat) -> PKStroke? {
        guard points.count >= 2 else { return nil }
        let controlPoints = points.enumerated().map { index, point in
            PKStrokePoint(
                location: point,
                timeOffset: TimeInterval(index) * 0.01,
                size: CGSize(width: lineWidth, height: lineWidth),
                opacity: 1,
                force: 1,
                azimuth: 0,
                altitude: .pi / 2
            )
        }
        let path = PKStrokePath(controlPoints: controlPoints, creationDate: Date())
        return PKStroke(ink: PKInk(.pen, color: color), path: path)
    }
}
