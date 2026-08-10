import SwiftUI

/// Plays a `[DialogueNode]` sequence as a bottom-anchored overlay panel:
/// portrait, speaker name, spoken/readable line, and choices. One reusable
/// engine backs every NPC/object interaction in the RPG world instead of
/// each location hand-rolling its own dialogue UI.
struct DialogueView: View {
    let nodes: [DialogueNode]
    let onFinished: () -> Void

    @EnvironmentObject var appSettings: AppSettings
    @State private var currentIndex = 0

    private var currentNode: DialogueNode? {
        nodes.indices.contains(currentIndex) ? nodes[currentIndex] : nil
    }

    var body: some View {
        VStack {
            Spacer()

            if let currentNode {
                VStack(spacing: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        AppAssets.image(currentNode.portraitAsset)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                            .background(Circle().fill(Color.white))

                        VStack(alignment: .leading, spacing: 6) {
                            if currentNode.speakerKey != WorldSpeaker.narrator {
                                Text(Loc.t(currentNode.speakerKey))
                                    .font(PlayLandTypography.caption)
                                    .foregroundColor(PlayLandColors.sunOrange)
                            }
                            HStack(alignment: .top, spacing: 8) {
                                Text(Loc.t(currentNode.textKey))
                                    .font(PlayLandTypography.body)
                                    .fixedSize(horizontal: false, vertical: true)
                                SpeakerButton(text: Loc.t(currentNode.textKey))
                            }
                        }
                    }

                    if currentNode.choices.isEmpty {
                        PlayLandPrimaryButton(title: Loc.t("action.close"), color: PlayLandColors.sunOrange, action: onFinished)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(currentNode.choices) { choice in
                                Button(action: { choose(choice) }) {
                                    Text(Loc.t(choice.textKey))
                                }
                                .buttonStyle(PlayLandChoiceButtonStyle())
                            }
                        }
                    }
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge))
                .padding()
            }
        }
        .onAppear { speak() }
        .onChange(of: currentIndex) { _ in speak() }
    }

    private func choose(_ choice: DialogueChoice) {
        guard let next = choice.nextIndex, nodes.indices.contains(next) else {
            onFinished()
            return
        }
        currentIndex = next
    }

    private func speak() {
        guard let currentNode else { return }
        SpeechManager.shared.speak(text: Loc.t(currentNode.textKey))
    }
}
