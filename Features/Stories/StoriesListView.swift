import SwiftUI

struct StoriesListView: View {
    @EnvironmentObject var progressManager: ProgressViewModel

    private var stories: [StoryItem] {
        StoryLibrary.stories.map {
            StoryItem(id: $0.id, title: $0.title, description: $0.description, coverImageName: $0.coverImageName)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Interactive Stories")) {
                    ForEach(stories) { story in
                        NavigationLink(destination: StoryDetailView(storyId: story.id)) {
                            StoryCard(item: story, isCompleted: progressManager.isStoryCompleted(story.id))
                        }
                    }
                }
            }
            .navigationTitle("Stories")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
