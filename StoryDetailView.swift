import SwiftUI

struct StoryDetailView: View {
    let storyId: String
    @EnvironmentObject var progressManager: ProgressViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isFinished = false

    private var story: StoryContent? {
        StoryLibrary.story(withId: storyId)
    }

    var body: some View {
        Group {
            if let story {
                if isFinished {
                    finishedView(for: story)
                } else {
                    InteractiveSceneView(title: story.title, scenes: story.scenes) {
                        progressManager.completeStory(story.id)
                        isFinished = true
                    }
                }
            } else {
                Text("Story coming soon!")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .navigationBarBackButtonHidden(isFinished)
    }

    private func finishedView(for story: StoryContent) -> some View {
        ZStack {
            Image(story.scenes.last?.background ?? story.coverImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.35).ignoresSafeArea())

            CompletionBadgeView(
                title: "Story Complete!",
                message: "You finished \"\(story.title)\" and earned 5 stars.",
                stars: 3,
                buttonTitle: "Back to Stories",
                action: { dismiss() }
            )
        }
    }
}
