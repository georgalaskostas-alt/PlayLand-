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
            Image(currentScene.background)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.18).ignoresSafeArea())
                .transition(.opacity)
                .id(currentScene.background)

            VStack(spacing: 0) {
                Spacer()

                HStack(alignment: .bottom, spacing: -24) {
                    ForEach(currentScene.characters, id: \.self) { character in
                        Image(character)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 170)
                            .shadow(color: .black.opacity(0.35), radius: 6, y: 4)
                    }
                }
                .padding(.bottom, 16)
                .animation(.easeInOut, value: currentScene.id)

                VStack(spacing: 14) {
                    Text(currentScene.narration)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(18)
                        .background(Color.black.opacity(0.55))
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    if currentScene.choices.isEmpty {
                        Button(action: onFinished) {
                            Text("The End 🎉")
                        }
                        .buttonStyle(PlayfulButtonStyle(color: PlayLandTheme.sunOrange))
                    } else {
                        VStack(spacing: 10) {
                            ForEach(currentScene.choices) { choice in
                                Button(action: { choose(choice) }) {
                                    Text(choice.text)
                                }
                                .buttonStyle(ChoiceButtonStyle())
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
