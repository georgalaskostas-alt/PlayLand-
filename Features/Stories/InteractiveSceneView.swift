import SwiftUI

/// Plays through a branching sequence of `StoryScene`s: background,
/// characters, narration and choices. Used by both the Stories tab and
/// Adventure's Story Mode chapters, so the scene/choice engine only needs
/// to exist once.
///
/// Layout is deliberately non-fixed-height: the character art gets a
/// height proportional to the available screen (capped, not fixed), and
/// the narration + choices panel is a bounded, independently-scrolling
/// region pinned to the bottom. On a small phone, a tall translation, or
/// a scene with three choices, the panel scrolls internally instead of
/// pushing content past the bottom of the screen — narration and choices
/// can never be clipped or become unreachable the way a single unbounded
/// `VStack` would allow.
struct InteractiveSceneView: View {
    let title: String
    let scenes: [StoryScene]
    let onFinished: () -> Void

    @EnvironmentObject var appSettings: AppSettings

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var currentIndex = 0
    @State private var hasEnteredScene = false

    private var currentScene: StoryScene {
        scenes[min(currentIndex, scenes.count - 1)]
    }

    private var narrationText: String {
        Loc.t(currentScene.narrationKey)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                PlayLandBackground(imageName: currentScene.background)
                    .transition(.opacity)
                    .id(currentScene.background)

                VStack(spacing: 0) {
                    Spacer(minLength: 8)

                    HStack(alignment: .bottom, spacing: -24) {
                        ForEach(currentScene.characters, id: \.self) { character in
                            AppAssets.image(character)
                                .resizable()
                                .scaledToFit()
                                .shadow(color: .black.opacity(0.35), radius: 6, y: 4)
                        }
                    }
                    .frame(height: min(geometry.size.height * 0.3, 190))
                    .scaleEffect(hasEnteredScene ? 1.0 : 0.85)
                    .opacity(hasEnteredScene ? 1.0 : 0.0)
                    .padding(.bottom, 12)

                    ScrollView {
                        VStack(spacing: 14) {
                            HStack(alignment: .top, spacing: 10) {
                                CharacterDialogueBubble(text: narrationText)
                                SpeakerButton(text: narrationText)
                            }

                            if currentScene.choices.isEmpty {
                                PlayLandPrimaryButton(title: Loc.t("action.theEnd"), color: PlayLandColors.sunOrange, action: onFinished)
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(currentScene.choices) { choice in
                                        Button(action: { choose(choice) }) {
                                            Text(Loc.t(choice.textKey))
                                        }
                                        .buttonStyle(PlayLandChoiceButtonStyle())
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(maxHeight: geometry.size.height * 0.56)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge))
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                }
            }
        }
        .animation(PlayLandAnimation.respecting(reduceMotion, .easeInOut(duration: 0.3)), value: currentIndex)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { enterScene() }
        .onChange(of: currentIndex) { _ in enterScene() }
    }

    private func choose(_ choice: StoryChoice) {
        AudioManager.shared.play(.storyNext)
        guard let next = choice.nextSceneIndex, scenes.indices.contains(next) else {
            onFinished()
            return
        }
        hasEnteredScene = false
        currentIndex = next
    }

    private func enterScene() {
        SpeechManager.shared.speak(text: narrationText)
        withAnimation(PlayLandAnimation.respecting(reduceMotion, PlayLandAnimation.bounce)) {
            hasEnteredScene = true
        }
    }
}
