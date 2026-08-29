import SwiftUI
import SpriteKit

extension BabisRPGScene {
    func applyPlayLandWideCamera(animated: Bool = false) {
        guard let camera else { return }
        let action = SKAction.scale(to: 1.55, duration: animated ? 0.35 : 0)
        action.timingMode = .easeInEaseOut
        camera.run(action)
    }

    func runAnimalThankYouCinematic(kind: String) {
        let greek = AppSettings.shared.resolvedLanguage == .greek
        SpeechManager.shared.speak(text: greek ? "Ευχαριστώ πολύ! Τώρα μπορώ να φύγω με ασφάλεια!" : "Thank you so much! Now I can leave safely!")

        enumerateChildNodes(withName: "//npc:\(kind):happy") { node, _ in
            node.name = "rescued_departed"
            node.userData?["action"] = nil

            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = greek ? "Ευχαριστώ! ❤️" : "Thank you! ❤️"
            label.fontSize = 34
            label.fontColor = .white
            label.position = CGPoint(x: 0, y: max(100, node.frame.height * 0.65))
            label.zPosition = 10000
            node.addChild(label)

            let pop = SKAction.sequence([
                .scale(to: 1.12, duration: 0.20),
                .scale(to: 1.0, duration: 0.20),
                .wait(forDuration: 0.8)
            ])
            let leave = SKAction.group([
                .moveBy(x: 700, y: 150, duration: 1.8),
                .fadeOut(withDuration: 1.5),
                .scale(to: 0.75, duration: 1.8)
            ])
            leave.timingMode = .easeInEaseOut
            node.run(.sequence([pop, leave, .removeFromParent()]))
        }
    }
}

struct RPGEnhancedGameView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var progressManager: ProgressViewModel
    @StateObject private var gameState = RPGGameState()
    @State private var scene: BabisRPGScene?
    @State private var dragStart: CGPoint?

    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()

                if let scene {
                    SpriteView(scene: scene, options: [.allowsTransparency])
                        .ignoresSafeArea()
                }

                VStack {
                    topHUD
                    Spacer()
                    HStack(alignment: .bottom) {
                        joystick
                        Spacer()
                        if gameState.nearbyAction != nil {
                            Button {
                                scene?.performInteraction()
                            } label: {
                                Label(gameState.interactionTitle, systemImage: gameState.interactionIcon)
                                    .font(.headline.weight(.black))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 14)
                                    .background(.orange)
                                    .clipShape(Capsule())
                                    .shadow(radius: 5)
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 18)
                }

                if let challenge = gameState.pendingChallenge {
                    RPGQuickPuzzleView(
                        challenge: challenge,
                        isGreek: isGreek,
                        onSuccess: {
                            gameState.completeChallenge(challenge)
                            scene?.completeActiveChallenge()
                        },
                        onCancel: {
                            gameState.pendingChallenge = nil
                        }
                    )
                }

                if let encounter = gameState.pendingEncounter {
                    encounterOverlay(encounter)
                }
            }
            .onAppear {
                guard scene == nil else { return }
                gameState.attach(progress: progressManager)
                gameState.setMessageForCurrentArea()
                let newScene = BabisRPGScene(size: geometry.size, gameState: gameState)
                scene = newScene
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                    newScene.applyPlayLandWideCamera(animated: false)
                }
            }
            .onDisappear {
                scene?.stopMovement()
                SpeechManager.shared.stop()
            }
        }
    }

    private var topHUD: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(gameState.area.icon) \(gameState.currentAreaTitle)")
                    .font(.headline.weight(.black))
                Text(gameState.areaNumberText)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
            HStack(spacing: 7) {
                ForEach(gameState.objectiveItems) { item in
                    Text("\(item.icon) \(min(item.current, item.target))/\(item.target)")
                        .font(.caption2.weight(.black))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(item.current >= item.target ? Color.green.opacity(0.82) : Color.black.opacity(0.58))
                        .clipShape(Capsule())
                }
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(.black.opacity(0.38))
    }

    private var joystick: some View {
        ZStack {
            Circle().fill(.black.opacity(0.35)).frame(width: 116, height: 116)
            Circle().fill(.white.opacity(0.85)).frame(width: 46, height: 46)
        }
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if dragStart == nil { dragStart = value.startLocation }
                    guard let start = dragStart else { return }
                    let dx = value.location.x - start.x
                    let dy = value.location.y - start.y
                    let maxDistance: CGFloat = 52
                    let length = max(1, hypot(dx, dy))
                    let scale = min(1, maxDistance / length)
                    scene?.setMovementVector(CGVector(dx: dx * scale / maxDistance, dy: -dy * scale / maxDistance))
                }
                .onEnded { _ in
                    dragStart = nil
                    scene?.stopMovement()
                }
        )
    }

    @ViewBuilder
    private func encounterOverlay(_ encounter: RPGEncounter) -> some View {
        switch encounter {
        case .animal(let kind):
            AnimalHelpPuzzleView(kind: kind, isGreek: isGreek) {
                scene?.confirmPendingEncounter()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    scene?.runAnimalThankYouCinematic(kind: kind)
                }
            } onCancel: {
                scene?.cancelPendingEncounter()
            }
        default:
            ZStack {
                Color.black.opacity(0.48).ignoresSafeArea()
                VStack(spacing: 16) {
                    Text(isGreek ? "Θέλεις να βοηθήσεις;" : "Ready to help?")
                        .font(.title2.weight(.black))
                    Button(isGreek ? "Ναι!" : "Yes!") { scene?.confirmPendingEncounter() }
                        .buttonStyle(.borderedProminent)
                    Button(isGreek ? "Όχι τώρα" : "Not now") { scene?.cancelPendingEncounter() }
                        .buttonStyle(.bordered)
                }
                .padding(28)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28))
            }
        }
    }
}

private struct AnimalHelpPuzzleView: View {
    let kind: String
    let isGreek: Bool
    let onSuccess: () -> Void
    let onCancel: () -> Void
    @State private var questionIndex = 0
    @State private var correctCount = 0
    @State private var feedback = ""

    private var questions: [(String, [String], Int)] {
        if isGreek {
            return [
                ("Ποιο μονοπάτι είναι ασφαλές για το ζωάκι;", ["Μέσα στους θάμνους", "Στο καθαρό μονοπάτι", "Μέσα στο ποτάμι"], 1),
                ("Τι χρειάζεται πρώτα ένα διψασμένο ζωάκι;", ["Νερό", "Πέτρες", "Κλαδιά"], 0),
                ("Ποιο σχήμα ταιριάζει; 🔺 🔺 ?", ["⚪️", "🔺", "⬛️"], 1)
            ]
        }
        return [
            ("Which path is safest for the animal?", ["Through bushes", "The clear path", "Into the river"], 1),
            ("What does a thirsty animal need first?", ["Water", "Rocks", "Branches"], 0),
            ("Which shape comes next? 🔺 🔺 ?", ["⚪️", "🔺", "⬛️"], 1)
        ]
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.56).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("🐾")
                    .font(.system(size: 48))
                Text(isGreek ? "Βοήθησε το ζωάκι" : "Help the animal")
                    .font(.title2.weight(.black))
                Text(questions[questionIndex].0)
                    .font(.headline.weight(.bold))
                    .multilineTextAlignment(.center)

                ForEach(Array(questions[questionIndex].1.enumerated()), id: \.offset) { index, answer in
                    Button(answer) {
                        if index == questions[questionIndex].2 {
                            correctCount += 1
                            feedback = isGreek ? "Μπράβο! ⭐" : "Great! ⭐"
                            if questionIndex == questions.count - 1 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { onSuccess() }
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    questionIndex += 1
                                    feedback = ""
                                }
                            }
                        } else {
                            feedback = isGreek ? "Δοκίμασε ξανά 🙂" : "Try again 🙂"
                        }
                    }
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Text(feedback).font(.headline.weight(.black))
                Button(isGreek ? "Αργότερα" : "Later", action: onCancel)
                    .font(.subheadline.weight(.bold))
            }
            .padding(24)
            .frame(maxWidth: 520)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .padding(20)
        }
    }
}

private struct RPGQuickPuzzleView: View {
    let challenge: RPGChallenge
    let isGreek: Bool
    let onSuccess: () -> Void
    let onCancel: () -> Void
    @State private var feedback = ""

    private var data: (String, [String], Int) {
        switch challenge {
        case .memory:
            return (isGreek ? "Θυμήσου: 🍎 ⭐ 🍎 — ποιο ήταν στη μέση;" : "Remember: 🍎 ⭐ 🍎 — what was in the middle?", ["🍎", "⭐", "🌳"], 1)
        case .numbers:
            return (isGreek ? "Πόσο κάνει 2 + 3;" : "What is 2 + 3?", ["4", "5", "6"], 1)
        case .shapes:
            return (isGreek ? "Ποιο είναι το τρίγωνο;" : "Which one is the triangle?", ["⚪️", "🔺", "⬛️"], 1)
        case .words:
            return (isGreek ? "Ποια λέξη αρχίζει από Δ;" : "Which word starts with D?", isGreek ? ["Δέντρο", "Μήλο", "Νερό"] : ["Dinosaur", "Apple", "Water"], 0)
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.52).ignoresSafeArea()
            VStack(spacing: 14) {
                Text("🧩").font(.system(size: 44))
                Text(data.0).font(.title3.weight(.black)).multilineTextAlignment(.center)
                ForEach(Array(data.1.enumerated()), id: \.offset) { index, answer in
                    Button(answer) {
                        if index == data.2 { onSuccess() }
                        else { feedback = isGreek ? "Δοκίμασε ξανά" : "Try again" }
                    }
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                Text(feedback).font(.subheadline.weight(.bold))
                Button(isGreek ? "Κλείσιμο" : "Close", action: onCancel)
            }
            .padding(24)
            .frame(maxWidth: 500)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .padding(20)
        }
    }
}
