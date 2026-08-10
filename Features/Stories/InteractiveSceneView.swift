import SwiftUI

struct InteractiveSceneView: View {
    let title: String
    let scenes: [StoryScene]
    let onFinished: () -> Void

    @State private var currentIndex = 0

    private var currentScene: StoryScene {
        scenes[min(currentIndex, scenes.count - 1)]
    }

    var body: some View {
        ZStack {
            PlayLandBackground(imageName: currentScene.background)
                .transition(.opacity)
                .id(currentScene.background)

            VStack(spacing: 0) {
                Spacer()

                HStack(alignment: .bottom, spacing: -24) {
                    ForEach(currentScene.characters, id: \.self) { character in
                        AppAssets.image(character)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 170)
                            .shadow(color: .black.opacity(0.35), radius: 6, y: 4)
                    }
                }
                .padding(.bottom, 16)
                .animation(.easeInOut, value: currentScene.id)

                VStack(spacing: 14) {
                    CharacterDialogueBubble(text: currentScene.narration)

                    if currentScene.choices.isEmpty {
                        PlayLandPrimaryButton(title: "The End 🎉", color: PlayLandColors.sunOrange, action: onFinished)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(currentScene.choices) { choice in
                                Button(action: { choose(choice) }) {
                                    Text(choice.text)
                                }
                                .buttonStyle(PlayLandChoiceButtonStyle())
                            }
                        }
                    }
                }
                .padding()
                .padding(.bottom, 16)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.3), value: currentIndex)
    }

    private func choose(_ choice: StoryChoice) {
        guard let next = choice.nextSceneIndex, scenes.indices.contains(next) else {
            onFinished()
            return
        }
        currentIndex = next
    }
}
