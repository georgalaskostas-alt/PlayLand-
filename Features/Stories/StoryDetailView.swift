import SwiftUI

struct StoryDetailView: View {
    let storyId: String
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    @State private var isFinished = false

    private var story: StoryContent? {
        (StoryLibrary.stories + AdditionalStoryLibrary.stories).first { $0.id == storyId }
    }

    var body: some View {
        Group {
            if let story {
                if isFinished {
                    finishedView(for: story)
                } else {
                    InteractiveSceneView(title: StoryText.t(story.titleKey), scenes: story.scenes) {
                        progressManager.completeStory(story.id)
                        isFinished = true
                    }
                }
            } else {
                Text(Loc.t("stories.comingSoon"))
                    .font(PlayLandTypography.heading)
                    .foregroundColor(PlayLandColors.secondaryText)
            }
        }
        .navigationBarBackButtonHidden(isFinished)
        .toolbar(.hidden, for: .tabBar)
    }

    private func finishedView(for story: StoryContent) -> some View {
        ZStack {
            PlayLandBackground(imageName: story.scenes.last?.background ?? story.coverImageName, scrimOpacity: 0.35)
            CompletionCelebrationView(
                title: Loc.t("stories.completeTitle"),
                message: Loc.t("stories.completeMessage", StoryText.t(story.titleKey), 5),
                stars: 3,
                buttonTitle: Loc.t("stories.backToStories"),
                action: { dismiss() }
            )
        }
    }
}
