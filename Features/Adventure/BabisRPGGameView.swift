import SwiftUI
import SpriteKit

final class RPGGameState: ObservableObject {
    @Published var apples = 0
    @Published var wood = 0
    @Published var water = 0
    @Published var questComplete = false
    @Published var message = ""

    var hasCompletedCollectionGoal: Bool { apples >= 3 && wood >= 2 && water >= 1 }

    func collect(kind: String) {
        switch kind {
        case "apple": apples += 1
        case "wood": wood += 1
        case "water": water += 1
        default: break
        }
        AudioManager.shared.play(.correct)
        if hasCompletedCollectionGoal {
            setMessage(greek: "Τα βρήκες όλα! Τώρα πήγαινε στο σεντούκι.", english: "You found everything! Now go to the chest.")
        }
    }

    func completeQuest() {
        questComplete = true
        AudioManager.shared.play(.storyNext)
        setMessage(greek: "Αποστολή ολοκληρώθηκε! Βρήκες το Χρυσό Φτερό!", english: "Quest complete! You found the Golden Feather!")
    }

    func setMessage(greek: String, english: String) {
        message = AppSettings.shared.resolvedLanguage == .greek ? greek : english
    }
}

struct BabisRPGGameView: View {
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var gameState = RPGGameState()
    @State private var scene: BabisRPGScene?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if let scene {
                    SpriteView(scene: scene, options: [.allowsTransparency])
                        .ignoresSafeArea()
                } else {
                    Color.black.ignoresSafeArea()
                }

                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        objectiveChip(icon: "🍎", value: "\(gameState.apples)/3", complete: gameState.apples >= 3)
                        objectiveChip(icon: "🪵", value: "\(gameState.wood)/2", complete: gameState.wood >= 2)
                        objectiveChip(icon: "💧", value: "\(gameState.water)/1", complete: gameState.water >= 1)
                        Spacer()
                        if gameState.questComplete {
                            Label(appSettings.resolvedLanguage == .greek ? "Αποστολή ✓" : "Quest ✓", systemImage: "star.fill")
                                .font(.headline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                    }

                    if !gameState.message.isEmpty {
                        Text(gameState.message)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .frame(maxWidth: 560)
                    }

                    Spacer()

                    Text(appSettings.resolvedLanguage == .greek ? "Άγγιξε το έδαφος για να κινηθεί ο Μπάμπης" : "Tap the ground to move Babis")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(.bottom, 12)
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
            }
            .onAppear {
                if scene == nil {
                    scene = BabisRPGScene(size: geometry.size, gameState: gameState)
                }
            }
            .onChange(of: geometry.size) { newSize in
                scene?.size = newSize
            }
        }
        .navigationTitle(appSettings.resolvedLanguage == .greek ? "Η Περιπέτεια του Μπάμπη" : "Babis Adventure")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func objectiveChip(icon: String, value: String, complete: Bool) -> some View {
        HStack(spacing: 5) {
            Text(icon)
            Text(value).font(.headline.monospacedDigit())
            if complete { Image(systemName: "checkmark.circle.fill").foregroundColor(PlayLandColors.leafGreen) }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}
