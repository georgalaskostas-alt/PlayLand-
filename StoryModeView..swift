import SwiftUI

struct StoryModeView: View {
    @State private var currentChapter = 0
    
    let chapters = [
        Chapter(id: 0, title: "Meeting Babis", description: "Meet the friendly dinosaur", image: "babis_dinosaur"),
        Chapter(id: 1, title: "Kotsifi Arrives", description: "A little bird lands on Babis' nose", image: "kotsifi_bird"),
        Chapter(id: 2, title: "The Agreement", description: "Babis and Kotsifi become friends", image: "forest_background"),
        Chapter(id: 3, title: "The Clever Fox", description: "A mischievous fox appears", image: "alepou_fox"),
        Chapter(id: 4, title: "The Forest Hero", description: "Babis saves the forest", image: "celebration_background")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("📖 Choose a Chapter")
                .font(.title)
                .fontWeight(.bold)
            
            List {
                ForEach(chapters) { chapter in
                    NavigationLink(destination: ChapterDetailView(chapter: chapter)) {
                        HStack(spacing: 15) {
                            Image(chapter.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .cornerRadius(10)
                            
                            VStack(alignment: .leading) {
                                Text("Chapter \(chapter.id + 1)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(chapter.title)
                                    .font(.headline)
                                
                                Text(chapter.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Story Mode")
    }
}

struct Chapter: Identifiable {
    let id: Int
    let title: String
    let description: String
    let image: String
}

struct ChapterDetailView: View {
    let chapter: Chapter
    
    var body: some View {
        VStack(spacing: 20) {
            Image(chapter.image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 300)
                .cornerRadius(15)
            
            Text("Chapter \(chapter.id + 1): \(chapter.title)")
                .font(.title)
                .fontWeight(.bold)
            
            Text(chapter.description)
                .font(.body)
                .padding()
            
            Button(action: {
                // Start interactive story
            }) {
                Text("Start Chapter")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(Color.orange)
                    .cornerRadius(25)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Story")
    }
}
