import SwiftUI

struct Chapter: Identifiable {
    let id: String
    let order: Int
    let title: String
    let description: String
    let image: String
}

struct StoryModeView: View {
    @EnvironmentObject var progressManager: ProgressViewModel

    private var chapters: [Chapter] {
        ChapterLibrary.chapters.map {
            Chapter(id: $0.id, order: $0.order, title: $0.title, description: $0.description, image: $0.imageName)
        }
    }

    var body: some View {
        List {
            Section(header: Text("Choose a Chapter")) {
                ForEach(chapters) { chapter in
                    NavigationLink(destination: ChapterDetailView(chapter: chapter)) {
                        HStack(spacing: 15) {
                            Image(chapter.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Chapter \(chapter.order)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(chapter.title)
                                    .font(.headline)
                                Text(chapter.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if progressManager.isStoryCompleted("chapter_\(chapter.id)") {
                                Image("ui_check")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .navigationTitle("Story Mode")
    }
}

struct ChapterDetailView: View {
    let chapter: Chapter
    @EnvironmentObject var progressManager: ProgressViewModel
    @State private var isPlaying = false
    @State private var isFinished = false

    private var chapterContent: ChapterContent? {
        ChapterLibrary.chapters.first { $0.id == chapter.id }
    }

    var body: some View {
        Group {
            if isPlaying, let chapterContent {
                InteractiveSceneView(title: chapterContent.title, scenes: chapterContent.scenes) {
                    progressManager.completeStory("chapter_\(chapter.id)")
                    withAnimation {
                        isPlaying = false
                        isFinished = true
                    }
                }
            } else {
                overview
            }
        }
        .navigationTitle(chapter.title)
    }

    private var overview: some View {
        VStack(spacing: 20) {
            Image(chapter.image)
                .resizable()
                .scaledToFill()
                .frame(maxHeight: 260)
                .clipShape(RoundedRectangle(cornerRadius: 18))

            Text("Chapter \(chapter.order): \(chapter.title)")
                .font(.title.bold())
                .multilineTextAlignment(.center)

            Text(chapter.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if isFinished {
                StarRatingView(stars: 3)
                Text("Chapter Complete!")
                    .font(.headline)
                    .foregroundColor(PlayLandTheme.leafGreen)
            }

            Button(action: { isPlaying = true }) {
                Text(isFinished ? "Play Again" : "Start Chapter")
            }
            .buttonStyle(PlayfulButtonStyle(color: PlayLandTheme.sunOrange))

            Spacer()
        }
        .padding()
    }
}
