import SwiftUI

/// Keeps the original Art Studio collection and the newer expanded collection available together.
struct ArtStudioCollectionsView: View {
    @EnvironmentObject private var appSettings: AppSettings
    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text("🎨")
                    .font(.system(size: 54))
                Text(isGreek ? "Εργαστήριο Ζωγραφικής" : "Art Studio")
                    .font(.system(size: 30, weight: .black, design: .rounded))

                NavigationLink {
                    ArtStudioView()
                } label: {
                    collectionCard(
                        emoji: "🖍️",
                        title: isGreek ? "Προηγούμενη συλλογή" : "Classic collection",
                        subtitle: isGreek ? "Όλα τα σχέδια που υπήρχαν ήδη — δεν αφαιρούνται." : "All previously available pictures are preserved."
                    )
                }

                NavigationLink {
                    ArtStudioFixedView()
                } label: {
                    collectionCard(
                        emoji: "🏰",
                        title: isGreek ? "Νέα συλλογή" : "Expanded collection",
                        subtitle: isGreek ? "Capybara, κάστρα, πριγκίπισσες, μονόκεροι, γοργόνες, φοίνικας και άλλα." : "Capybaras, castles, princesses, unicorns, mermaids, phoenixes and more."
                    )
                }
            }
            .padding(18)
        }
        .background(
            LinearGradient(colors: [.purple.opacity(0.18), .blue.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
        .navigationTitle(isGreek ? "Ζωγραφική" : "Drawing")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func collectionCard(emoji: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Text(emoji).font(.system(size: 42))
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.title3.weight(.black))
                Text(subtitle).font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.headline.weight(.bold)).foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 112)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}
