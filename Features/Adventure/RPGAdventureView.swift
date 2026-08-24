import SwiftUI

struct RPGAdventureView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var progressManager: ProgressViewModel
    @State private var showGame = false

    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                PlayLandBackground(imageName: "rpg_forest_ground_v2", scrimOpacity: 0)
                    .overlay(Color.black.opacity(0.22).ignoresSafeArea())

                if geometry.size.width > geometry.size.height {
                    landscapeLauncher.padding(.horizontal, 30).padding(.vertical, 20)
                } else {
                    portraitLauncher.padding(.horizontal, 20).padding(.top, 18).padding(.bottom, 24)
                }
            }
        }
        .navigationTitle(isGreek ? "Περιπέτειες" : "Adventures")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showGame) {
            ZStack(alignment: .topTrailing) {
                BabisRPGGameView()
                    .environmentObject(appSettings)
                    .environmentObject(progressManager)

                Button { showGame = false } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(.black.opacity(0.56))
                        .overlay(Circle().stroke(.white.opacity(0.22), lineWidth: 1))
                        .clipShape(Circle())
                }
                .padding(.top, 16).padding(.trailing, 16)
                .accessibilityLabel(isGreek ? "Έξοδος από το παιχνίδι" : "Exit game")
                .zIndex(200)
            }
            .background(Color.black.ignoresSafeArea())
        }
    }

    private var portraitLauncher: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                titleBlock
                HStack(alignment: .bottom, spacing: 14) {
                    AppAssets.image("babis_rpg_master").resizable().scaledToFit().frame(maxWidth: 185, maxHeight: 225)
                    AppAssets.image("kotsifi_rpg_master").resizable().scaledToFit().frame(maxWidth: 105, maxHeight: 135)
                }.frame(maxWidth: .infinity)
                introCard
                startButton
                campaignCard
                Text(isGreek ? "Παίζεται κανονικά σε κάθετη και οριζόντια προβολή. Μπορείς να αλλάξεις προσανατολισμό οποιαδήποτε στιγμή." : "Play normally in portrait or landscape and rotate at any time.")
                    .font(.footnote.weight(.semibold)).foregroundStyle(.white.opacity(0.88)).multilineTextAlignment(.center).padding(.horizontal, 12)
            }
        }
    }

    private var landscapeLauncher: some View {
        HStack(spacing: 26) {
            VStack(spacing: 14) {
                titleBlock
                HStack(alignment: .bottom, spacing: 16) {
                    AppAssets.image("babis_rpg_master").resizable().scaledToFit().frame(width: 210, height: 235)
                    AppAssets.image("kotsifi_rpg_master").resizable().scaledToFit().frame(width: 120, height: 145)
                }
            }.frame(maxWidth: .infinity)
            VStack(spacing: 18) { introCard; startButton; campaignCard }.frame(maxWidth: 670)
        }
    }

    private var titleBlock: some View {
        VStack(spacing: 5) {
            Text(isGreek ? "Η Μεγάλη Περιπέτεια" : "The Great Adventure")
                .font(.system(size: 32, weight: .black, design: .rounded)).foregroundStyle(.white).multilineTextAlignment(.center).shadow(color: .black.opacity(0.4), radius: 5, y: 2)
            Text(isGreek ? "με τον Μπάμπη και το Κοτσύφι" : "with Babis & Kotsifi").font(.headline.weight(.bold)).foregroundStyle(.white.opacity(0.9))
        }
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(isGreek ? "Ένας μεγάλος κόσμος RPG σε πραγματικό χρόνο" : "A large real-time RPG world", systemImage: "sparkles")
                .font(.headline.weight(.black)).foregroundStyle(.white)
            Text(isGreek ? "10 μεγάλα κεφάλαια με ελεύθερη εξερεύνηση, δεινόσαυρους, ζώα, έντομα, μαγικά πλάσματα, σεντούκια, θησαυρούς, γρίφους, ποτάμι, Κρυστάλλινη Σπηλιά και τελική αποστολή." : "10 large chapters with free exploration, dinosaurs, animals, insects, magical creatures, chests, treasure, puzzles, a river, Crystal Cave and a final mission.")
                .font(.subheadline.weight(.semibold)).foregroundStyle(.white.opacity(0.88)).fixedSize(horizontal: false, vertical: true)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(18).background(.black.opacity(0.58)).overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.16), lineWidth: 1)).clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var startButton: some View {
        Button { showGame = true } label: {
            HStack(spacing: 10) { Image(systemName: "gamecontroller.fill"); Text(isGreek ? "Ξεκίνα τη Μεγάλη Περιπέτεια" : "Start Great Adventure") }
                .font(.title3.weight(.black)).foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 17).background(PlayLandColors.sunOrange).clipShape(RoundedRectangle(cornerRadius: 20)).shadow(color: .black.opacity(0.28), radius: 7, y: 4)
        }
    }

    private var campaignCard: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(isGreek ? "10 ΚΕΦΑΛΑΙΑ" : "10 CHAPTERS").font(.caption.weight(.black)).foregroundStyle(.white.opacity(0.72))
            HStack(spacing: 10) {
                campaignColumn([("🌲", isGreek ? "Μεγάλο Δάσος" : "Great Forest"),("🐾", isGreek ? "Ξέφωτο Διάσωσης" : "Rescue Clearing"),("🏘️", isGreek ? "Χωριό" : "Village"),("🌉", isGreek ? "Ποτάμι" : "River Crossing"),("🧩", isGreek ? "Ξέφωτο Γρίφων" : "Puzzle Clearing")])
                campaignColumn([("💎", isGreek ? "Κρυστάλλινη Σπηλιά" : "Crystal Cave"),("🌙", isGreek ? "Νυχτερινό Δάσος" : "Night Forest"),("🦄", isGreek ? "Άλσος Μονόκερου" : "Unicorn Grove"),("🏆", isGreek ? "Μεγάλος Θησαυρός" : "Treasure Hunt"),("🦊", isGreek ? "Φωλιά Αλεπούς" : "Fox Den")])
            }
        }.padding(14).background(.black.opacity(0.44)).clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func campaignColumn(_ rows: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 7) { Text(row.0); Text(row.1).font(.caption2.weight(.semibold)).foregroundStyle(.white).lineLimit(1); Spacer(minLength: 0) }
            }
        }.frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack { RPGAdventureView().environmentObject(ProgressViewModel()).environmentObject(AppSettings.shared) }
}
