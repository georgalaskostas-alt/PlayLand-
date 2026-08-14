import SwiftUI

struct StoriesListView: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings

    private var stories: [StoryItem] {
        (StoryLibrary.stories + AdditionalStoryLibrary.stories).map {
            StoryItem(id: $0.id, title: StoryText.t($0.titleKey), description: StoryText.t($0.descriptionKey), coverImageName: $0.coverImageName)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text(Loc.t("stories.sectionHeader"))) {
                    ForEach(stories) { story in
                        NavigationLink(destination: StoryDetailView(storyId: story.id)) {
                            StoryCard(item: story, isCompleted: progressManager.isStoryCompleted(story.id))
                        }
                    }
                }
            }
            .navigationTitle(Loc.t("stories.navTitle"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
