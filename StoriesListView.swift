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
                            StoryRow(item: story, isCompleted: progressManager.isStoryCompleted(story.id))
                        }
                    }
                }
            }
            .navigationTitle("Stories")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct StoryRow: View {
    let item: StoryItem
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(item.coverImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                if isCompleted {
                    HStack(spacing: 4) {
                        Image("ui_check")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("Completed!")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(PlayLandTheme.leafGreen)
                    }
                }
            }

            Spacer()

            if isCompleted {
                VStack(spacing: 2) {
                    Image("ui_star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                    Text("+5")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(PlayLandTheme.sunOrange)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
