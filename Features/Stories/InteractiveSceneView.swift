import SwiftUI

/// Plays through a branching sequence of `StoryScene`s. Production storybook
/// illustrations remain the visual focus while narration and choices stay
/// compact at the bottom of the screen.
struct InteractiveSceneView: View {
    let title: String
    let scenes: [StoryScene]
    let onFinished: () -> Void

    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var currentIndex = 0
    @State private var hasEnteredScene = false
    @State private var choiceFeedback: String?

    private struct PresentedChoice: Identifiable {
        let id = UUID()
        let textKey: String
        let nextSceneIndex: Int?
        let isCorrect: Bool
        let feedbackKey: String?
    }

    private var currentScene: StoryScene {
        scenes[min(currentIndex, scenes.count - 1)]
    }

    private var narrationText: String { StoryText.t(currentScene.narrationKey) }

    private var presentedChoices: [PresentedChoice] {
        switch currentScene.narrationKey {
        case "story.babisKotsifi.scene4.narration":
            return [
                PresentedChoice(textKey: "story.babisKotsifi.scene4.choice.left", nextSceneIndex: 4, isCorrect: true, feedbackKey: nil),
                PresentedChoice(textKey: "story.babisKotsifi.scene4.choice.right", nextSceneIndex: 4, isCorrect: false, feedbackKey: "story.babisKotsifi.feedback.water")
            ]
        case "story.babisKotsifi.scene5.narration":
            return [
                PresentedChoice(textKey: "story.babisKotsifi.scene5.choice.right", nextSceneIndex: 5, isCorrect: true, feedbackKey: nil),
                PresentedChoice(textKey: "story.babisKotsifi.scene5.choice.left", nextSceneIndex: 5, isCorrect: false, feedbackKey: "story.babisKotsifi.feedback.food")
            ]
        case "story.babisKotsifi.scene9.narration":
            return [
                PresentedChoice(textKey: "story.babisKotsifi.scene9.choice0", nextSceneIndex: 9, isCorrect: true, feedbackKey: nil),
                PresentedChoice(textKey: "story.babisKotsifi.scene9.choice1", nextSceneIndex: 9, isCorrect: false, feedbackKey: "story.babisKotsifi.feedback.clues")
            ]
        case "story.babisKotsifi.scene12.narration":
            return [
                PresentedChoice(textKey: "story.babisKotsifi.scene12.choice0", nextSceneIndex: 13, isCorrect: true, feedbackKey: nil),
                PresentedChoice(textKey: "story.babisKotsifi.scene12.choice1", nextSceneIndex: 13, isCorrect: false, feedbackKey: "story.babisKotsifi.feedback.repair")
            ]
        default:
            return currentScene.choices.map {
                PresentedChoice(textKey: $0.textKey, nextSceneIndex: $0.nextSceneIndex, isCorrect: true, feedbackKey: nil)
            }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                sceneBackground(size: geometry.size)

                LinearGradient(
                    colors: [.clear, .clear, .black.opacity(0.10), .black.opacity(0.38)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)

                compactPanel(maxHeight: geometry.size.height * 0.34)
                    .padding(.horizontal, PlayLandMetrics.contentHorizontalMargin)
                    .padding(.bottom, 12)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .animation(PlayLandAnimation.respecting(reduceMotion, .easeInOut(duration: 0.3)), value: currentIndex)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { enterScene() }
        .onChange(of: currentIndex) { _ in enterScene() }
    }

    // MARK: - Scene art

    private var installedIllustrationName: String? {
        let productionName = String(format: "story_babis_kotsifi_%02d", currentIndex + 1)
        if currentScene.illustration?.hasPrefix("story_babis_kotsifi_") == true,
           AppAssets.exists(productionName) {
            return AppAssets.storyIllustration(
                productionName,
                language: appSettings.resolvedLanguage
            )
        }

        if let fallback = currentScene.illustration, AppAssets.exists(fallback) {
            return AppAssets.storyIllustration(
                fallback,
                language: appSettings.resolvedLanguage
            )
        }

        return nil
    }

    @ViewBuilder
    private func sceneBackground(size: CGSize) -> some View {
        if let illustration = installedIllustrationName {
            ZStack {
                // The same illustration fills the entire screen as a soft
                // backdrop so there are no unrelated forest graphics behind it.
                AppAssets.image(illustration)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipped()
                    .blur(radius: 18)
                    .scaleEffect(1.08)
                    .overlay(Color.black.opacity(0.12))

                // The complete illustration stays sharp and fully visible.
                // This preserves the composition even on portrait devices.
                AppAssets.image(illustration)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: size.width,
                        height: size.height * 0.78,
                        alignment: .top
                    )
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .scale(scale: 0.995)))
                    .accessibilityHidden(true)
            }
            .frame(width: size.width, height: size.height)
            .clipped()
        } else {
            ZStack {
                PlayLandBackground(imageName: currentScene.background)
                    .transition(.opacity)
                    .id(currentScene.background)
                characterComposition(regionSize: size)
            }
        }
    }

    private func characterComposition(regionSize: CGSize) -> some View {
        ZStack {
            ForEach(Array(currentScene.characters.enumerated()), id: \.offset) { index, character in
                let count = currentScene.characters.count
                let xFraction = CGFloat(index + 1) / CGFloat(count + 1)
                let widthFraction = characterWidthFraction(index: index, count: count)
                let charWidth = regionSize.width * widthFraction
                let charHeight = regionSize.height * 0.72

                AppAssets.image(character)
                    .resizable()
                    .scaledToFit()
                    .frame(width: charWidth, height: charHeight, alignment: .bottom)
                    .shadow(color: .black.opacity(0.35), radius: 6, y: 4)
                    .position(x: regionSize.width * xFraction, y: regionSize.height - charHeight / 2 - regionSize.height * 0.08)
                    .scaleEffect(hasEnteredScene ? 1.0 : 0.85)
                    .opacity(hasEnteredScene ? 1.0 : 0.0)
            }
        }
        .frame(width: regionSize.width, height: regionSize.height)
        .clipped()
    }

    private func characterWidthFraction(index: Int, count: Int) -> CGFloat {
        switch count {
        case 1: return 0.34
        case 2: return index == 0 ? 0.32 : 0.24
        default: return index == 0 ? 0.28 : 0.20
        }
    }

    // MARK: - Interaction panel

    private func compactPanel(maxHeight: CGFloat) -> some View {
        panelContent
            .frame(maxHeight: maxHeight)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge))
            .overlay {
                RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge)
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.22), radius: 12, y: 5)
    }

    private var panelContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                ScrollView(.vertical, showsIndicators: false) {
                    CharacterDialogueBubble(text: narrationText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                SpeakerButton(text: narrationText)
                    .padding(.top, 2)
            }
            .frame(maxHeight: 150)

            if let choiceFeedback {
                Text(choiceFeedback)
                    .font(PlayLandTypography.body)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.30))
                    .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if presentedChoices.isEmpty {
                PlayLandPrimaryButton(title: Loc.t("action.theEnd"), color: PlayLandColors.sunOrange, action: onFinished)
                    .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 7) {
                    ForEach(presentedChoices) { choice in
                        Button(action: { choose(choice) }) {
                            Text(StoryText.t(choice.textKey))
                        }
                        .buttonStyle(PlayLandChoiceButtonStyle())
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func choose(_ choice: PresentedChoice) {
        if !choice.isCorrect {
            AudioManager.shared.play(.buttonTap)
            if let feedbackKey = choice.feedbackKey {
                let feedback = StoryText.t(feedbackKey)
                withAnimation(PlayLandAnimation.respecting(reduceMotion, .easeInOut(duration: 0.2))) {
                    choiceFeedback = feedback
                }
                SpeechManager.shared.speak(text: feedback)
            }
            return
        }

        choiceFeedback = nil
        AudioManager.shared.play(.storyNext)
        guard let next = choice.nextSceneIndex, scenes.indices.contains(next) else {
            onFinished()
            return
        }
        hasEnteredScene = false
        currentIndex = next
    }

    private func enterScene() {
        choiceFeedback = nil
        SpeechManager.shared.speak(text: narrationText)
        withAnimation(PlayLandAnimation.respecting(reduceMotion, PlayLandAnimation.bounce)) {
            hasEnteredScene = true
        }
    }
}
