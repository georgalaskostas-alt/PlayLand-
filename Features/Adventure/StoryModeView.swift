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
    @EnvironmentObject var appSettings: AppSettings

    private var chapters: [Chapter] {
        ChapterLibrary.chapters.map {
            Chapter(id: $0.id, order: $0.order, title: Loc.t($0.titleKey), description: Loc.t($0.descriptionKey), image: $0.imageName)
        }
    }

    var body: some View {
        List {
            Section(header: Text(Loc.t("adventure.storyMode.chooseChapter"))) {
                ForEach(chapters) { chapter in
                    NavigationLink(destination: ChapterDetailView(chapter: chapter)) {
                        HStack(spacing: 15) {
                            AppAssets.image(chapter.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusSmall))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(Loc.t("adventure.storyMode.chapterNumber", chapter.order))
                                    .font(PlayLandTypography.caption)
                                    .foregroundColor(PlayLandColors.secondaryText)
                                Text(chapter.title)
                                    .font(PlayLandTypography.heading)
                                Text(chapter.description)
                                    .font(PlayLandTypography.body)
                                    .foregroundColor(PlayLandColors.secondaryText)

                                if progressManager.isChapterCompleted(chapter.id) {
                                    ProgressBadge()
                                }
                            }

                            Spacer()
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .navigationTitle(Loc.t("adventure.storyMode.navTitle"))
    }
}

struct ChapterDetailView: View {
    let chapter: Chapter
    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
    @State private var isPlaying = false
    @State private var isFinished = false

    private var chapterContent: ChapterContent? {
        ChapterLibrary.chapters.first { $0.id == chapter.id }
    }

    var body: some View {
        Group {
            if isPlaying, let chapterContent {
                InteractiveSceneView(title: chapter.title, scenes: chapterContent.scenes) {
                    progressManager.completeChapter(chapter.id)
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
        .onAppear {
            isFinished = progressManager.isChapterCompleted(chapter.id)
        }
    }

    private var overview: some View {
        VStack(spacing: 20) {
            AppAssets.image(chapter.image)
                .resizable()
                .scaledToFill()
                .frame(maxHeight: 260)
                .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge))

            Text(Loc.t("adventure.storyMode.chapterTitled", chapter.order, chapter.title))
                .font(PlayLandTypography.title)
                .multilineTextAlignment(.center)

            Text(chapter.description)
                .font(PlayLandTypography.body)
                .foregroundColor(PlayLandColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if isFinished {
                StarCounter(stars: 3)
                ProgressBadge(text: Loc.t("adventure.storyMode.chapterComplete"))
            }

            PlayLandPrimaryButton(
                title: isFinished ? Loc.t("action.playAgain") : Loc.t("action.startChapter"),
                color: PlayLandColors.sunOrange,
                action: { isPlaying = true }
            )

            Spacer()
        }
        .padding()
    }
}
