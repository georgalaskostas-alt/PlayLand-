import SwiftUI

struct StoryDetailView: View {
    let storyId: String
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
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
                    InteractiveSceneView(title: Loc.t(story.titleKey), scenes: story.scenes) {
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
        // Immersive story mode: hide the app's tab bar for the duration of
        // this screen only. SwiftUI restores it automatically once this
        // view is popped off the navigation stack — nothing elsewhere
        // needs to (or should) touch tab bar visibility.
        .toolbar(.hidden, for: .tabBar)
    }

    private func finishedView(for story: StoryContent) -> some View {
        ZStack {
            PlayLandBackground(imageName: story.scenes.last?.background ?? story.coverImageName, scrimOpacity: 0.35)

            CompletionCelebrationView(
                title: Loc.t("stories.completeTitle"),
                message: Loc.t("stories.completeMessage", Loc.t(story.titleKey), 5),
                stars: 3,
                buttonTitle: Loc.t("stories.backToStories"),
                action: { dismiss() }
            )
        }
    }
}
