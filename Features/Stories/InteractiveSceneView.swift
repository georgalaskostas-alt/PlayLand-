import SwiftUI

/// Plays through a branching sequence of `StoryScene`s. A scene can use a
/// dedicated storybook illustration; until that illustration is installed,
/// the renderer gracefully falls back to the existing character composition.
struct InteractiveSceneView: View {
    let title: String
    let scenes: [StoryScene]
    let onFinished: () -> Void

    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

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

    /// Key story beats become reasoning moments instead of simple "continue"
    /// taps. Wrong answers do not advance the story; they trigger a gentle,
    /// spoken educational hint and let the child try again.
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
            ZStack {
                PlayLandBackground(imageName: currentScene.background)
                    .transition(.opacity)
                    .id(currentScene.background)

                if horizontalSizeClass == .regular {
                    let regionHeight = geometry.size.height - 40
                    let regionWidth = geometry.size.width * 0.48

                    HStack(alignment: .top, spacing: 20) {
                        sceneArt(regionSize: CGSize(width: regionWidth, height: regionHeight))
                            .frame(width: regionWidth, height: regionHeight)

                        panel.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(20)
                } else {
                    let artHeight = geometry.size.height * 0.46

                    ScrollView {
                        VStack(spacing: 12) {
                            sceneArt(regionSize: CGSize(width: geometry.size.width, height: artHeight))
                                .frame(width: geometry.size.width, height: artHeight)

                            panel
                                .padding(.horizontal, PlayLandMetrics.contentHorizontalMargin)
                                .padding(.bottom, 12)
                        }
                        .frame(width: geometry.size.width)
                    }
                }
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
        // The final production set is numbered 01...15. Story index 0 maps to
        // illustration 01, index 1 to 02, and so on.
        let productionName = String(format: "story_babis_kotsifi_%02d", currentIndex + 1)
        if currentScene.illustration?.hasPrefix("story_babis_kotsifi_") == true,
           AppAssets.exists(productionName) {
            return productionName
        }
        if let fallback = currentScene.illustration, AppAssets.exists(fallback) {
            return fallback
        }
        return nil
    }

    @ViewBuilder
    private func sceneArt(regionSize: CGSize) -> some View {
        if let illustration = installedIllustrationName {
            AppAssets.image(illustration)
                .resizable()
                .scaledToFit()
                .frame(width: regionSize.width, height: regionSize.height)
                .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge))
                .shadow(color: .black.opacity(0.22), radius: 8, y: 4)
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                .accessibilityHidden(true)
        } else {
            characterComposition(regionSize: regionSize)
        }
    }

    private func characterComposition(regionSize: CGSize) -> some View {
        ZStack {
            ForEach(Array(currentScene.characters.enumerated()), id: \.offset) { index, character in
                let count = currentScene.characters.count
                let xFraction = CGFloat(index + 1) / CGFloat(count + 1)
                let widthFraction = characterWidthFraction(index: index, count: count)
                let charWidth = regionSize.width * widthFraction
                let charHeight = regionSize.height * 0.88

                AppAssets.image(character)
                    .resizable()
                    .scaledToFit()
                    .frame(width: charWidth, height: charHeight, alignment: .bottom)
                    .shadow(color: .black.opacity(0.35), radius: 6, y: 4)
                    .position(x: regionSize.width * xFraction, y: regionSize.height - charHeight / 2 - regionSize.height * 0.04)
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

    private var panel: some View {
        panelContent
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge))
    }

    private var panelContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            CharacterDialogueBubble(text: narrationText)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Spacer(minLength: 0)
                SpeakerButton(text: narrationText)
            }

            if let choiceFeedback {
                Text(choiceFeedback)
                    .font(PlayLandTypography.body)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusMedium))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if presentedChoices.isEmpty {
                PlayLandPrimaryButton(title: Loc.t("action.theEnd"), color: PlayLandColors.sunOrange, action: onFinished)
                    .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 10) {
                    ForEach(presentedChoices) { choice in
                        Button(action: { choose(choice) }) {
                            Text(StoryText.t(choice.textKey))
                        }
                        .buttonStyle(PlayLandChoiceButtonStyle())
                    }
                }
            }
        }
        .padding(16)
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
