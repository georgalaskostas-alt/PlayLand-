import SwiftUI

struct StoriesListView: View {
    @EnvironmentObject var progressManager: ProgressViewModel
    
    let stories = [
        StoryItem(id: "babis_kotsifi", title: "Babis & Kotsifi", description: "Dinosaur hero!", coverImageName: "babis_dinosaur"),
        StoryItem(id: "babis_rabbit", title: "Lost Rabbit", description: "Save the bunny!", coverImageName: "kotsifi_bird"),
        StoryItem(id: "babis_storm", title: "Big Storm", description: "Protect animals!", coverImageName: "alepou_fox")
    ]

    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("📚 Interactive Stories")) {
                    ForEach(stories) { story in
                        NavigationLink(destination: StoryDetailView(storyId: story.id)) {
                            HStack {
                                Image(story.coverImageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(15)
                                    .shadow(radius: 5)

                                
                                VStack(alignment: .leading) {
                                    Text(story.title)
                                        .font(.headline)
                                    Text(story.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                    
                                    if progressManager.isStoryCompleted(story.id) {
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            Text("Completed!")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                if progressManager.isStoryCompleted(story.id) {
                                    VStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                        Text("5 ⭐")
                                            .font(.caption)
                                            .foregroundColor(.yellow)
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .navigationTitle("Stories")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct StoryItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let coverIcon: String
    let color: Color
}
