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
                    .overlay(Color.black.opacity(0.24).ignoresSafeArea())
                if geometry.size.width > geometry.size.height { landscapeLauncher(size: geometry.size) } else { portraitLauncher(size: geometry.size) }
            }
        }
        .navigationTitle(isGreek ? "Περιπέτειες" : "Adventures")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { OrientationController.allowAll() }
        .onDisappear { if !showGame { OrientationController.allowAll() } }
        .fullScreenCover(isPresented: $showGame, onDismiss: { OrientationController.allowAll() }) {
            ZStack(alignment: .topTrailing) {
                BabisRPGGameView().environmentObject(appSettings).environmentObject(progressManager)
                Button { OrientationController.allowAll(); showGame = false } label: {
                    Image(systemName: "xmark").font(.system(size: 18, weight: .black)).foregroundStyle(.white).frame(width: 46, height: 46).background(.black.opacity(0.56)).overlay(Circle().stroke(.white.opacity(0.22), lineWidth: 1)).clipShape(Circle())
                }.padding(.top, 16).padding(.trailing, 16).accessibilityLabel(isGreek ? "Έξοδος από το παιχνίδι" : "Exit game").zIndex(200)
            }.background(Color.black.ignoresSafeArea()).onAppear { OrientationController.requireLandscape() }
        }
    }

    private func portraitLauncher(size: CGSize) -> some View {
        let horizontalPadding: CGFloat = 18
        let contentWidth = max(0, size.width - horizontalPadding * 2)

        return ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                titleBlock(compact: size.height < 750)
                    .frame(width: contentWidth)

                HStack(alignment: .bottom, spacing: 10) {
                    AppAssets.image("babis_rpg_master")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            maxWidth: min(contentWidth * 0.44, 180),
                            maxHeight: size.height < 750 ? 145 : 205
                        )

                    AppAssets.image("kotsifi_rpg_master")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            maxWidth: min(contentWidth * 0.24, 100),
                            maxHeight: size.height < 750 ? 90 : 125
                        )
                }
                .frame(width: contentWidth)

                introCard
                    .frame(width: contentWidth)

                startButton
                    .frame(width: contentWidth)

                campaignCard
                    .frame(width: contentWidth)

                Text(
                    isGreek
                        ? "Η αρχική οθόνη λειτουργεί και κάθετα και οριζόντια. Μόλις πατήσεις Έναρξη, το παιχνίδι περνά οριζόντια."
                        : "The launcher works in portrait and landscape. After tapping Start, gameplay switches to landscape."
                )
                .font(.footnote.weight(.bold))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: contentWidth)
                .padding(.top, 2)
            }
            .frame(width: size.width)
            .padding(.top, 12)
            .padding(.bottom, 110)
        }
        .frame(width: size.width)
    }

    private func landscapeLauncher(size: CGSize) -> some View {
        ScrollView(showsIndicators: false) {
            HStack(alignment: .center, spacing: 24) {
                VStack(spacing: 10) {
                    titleBlock(compact: size.height < 500)
                    HStack(alignment: .bottom, spacing: 12) {
                        AppAssets.image("babis_rpg_master").resizable().scaledToFit().frame(maxWidth: 190, maxHeight: min(210, size.height * 0.43))
                        AppAssets.image("kotsifi_rpg_master").resizable().scaledToFit().frame(maxWidth: 105, maxHeight: min(125, size.height * 0.28))
                    }
                }.frame(maxWidth: .infinity)
                VStack(spacing: 12) { introCard; startButton; campaignCard }.frame(maxWidth: min(620, size.width * 0.52))
            }.padding(.horizontal, 28).padding(.vertical, 16).frame(minHeight: size.height)
        }
    }

    private func titleBlock(compact: Bool) -> some View {
        VStack(spacing: 4) {
            Text(isGreek ? "Η Μεγάλη Περιπέτεια" : "The Great Adventure").font(.system(size: compact ? 26 : 32, weight: .black, design: .rounded)).foregroundStyle(.white).multilineTextAlignment(.center).minimumScaleFactor(0.72).shadow(color: .black.opacity(0.4), radius: 5, y: 2)
            Text(isGreek ? "με τον Μπάμπη και το Κοτσύφι" : "with Babis & Kotsifi").font(.headline.weight(.bold)).foregroundStyle(.white.opacity(0.9)).multilineTextAlignment(.center)
        }
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 7) {
            Label(
                isGreek ? "Ένας μεγάλος κόσμος RPG σε πραγματικό χρόνο" : "A large real-time RPG world",
                systemImage: "sparkles"
            )
            .font(.headline.weight(.black))
            .foregroundStyle(.white)
            .fixedSize(horizontal: false, vertical: true)

            Text(isGreek ? "10 μεγάλα κεφάλαια με ελεύθερη εξερεύνηση, δεινόσαυρους, ζώα, έντομα, μαγικά πλάσματα, σεντούκια, θησαυρούς, γρίφους, ποτάμι, Κρυστάλλινη Σπηλιά και τελική αποστολή." : "10 large chapters with free exploration, dinosaurs, animals, insects, magical creatures, chests, treasure, puzzles, a river, Crystal Cave and a final mission.").font(.subheadline.weight(.semibold)).foregroundStyle(.white.opacity(0.9)).fixedSize(horizontal: false, vertical: true)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(15).background(.black.opacity(0.6)).overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.16), lineWidth: 1)).clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var startButton: some View {
        Button { OrientationController.requireLandscape(); showGame = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "gamecontroller.fill")
                Text(isGreek ? "Ξεκίνα τη Μεγάλη Περιπέτεια" : "Start Great Adventure")
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .font(.title3.weight(.black))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(PlayLandColors.sunOrange)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.28), radius: 7, y: 4)
        }
    }

    private var campaignCard: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(isGreek ? "10 ΚΕΦΑΛΑΙΑ" : "10 CHAPTERS").font(.caption.weight(.black)).foregroundStyle(.white.opacity(0.72))
            HStack(alignment: .top, spacing: 10) {
                campaignColumn([("🌲", isGreek ? "Μεγάλο Δάσος" : "Great Forest"),("🐾", isGreek ? "Ξέφωτο Διάσωσης" : "Rescue Clearing"),("🏘️", isGreek ? "Χωριό" : "Village"),("🌉", isGreek ? "Ποτάμι" : "River Crossing"),("🧩", isGreek ? "Ξέφωτο Γρίφων" : "Puzzle Clearing")])
                campaignColumn([("💎", isGreek ? "Κρυστάλλινη Σπηλιά" : "Crystal Cave"),("🌙", isGreek ? "Νυχτερινό Δάσος" : "Night Forest"),("🦄", isGreek ? "Άλσος Μονόκερου" : "Unicorn Grove"),("🏆", isGreek ? "Μεγάλος Θησαυρός" : "Treasure Hunt"),("🦊", isGreek ? "Φωλιά Αλεπούς" : "Fox Den")])
            }
        }.padding(13).background(.black.opacity(0.48)).clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func campaignColumn(_ rows: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in HStack(spacing: 6) { Text(row.0); Text(row.1).font(.caption2.weight(.semibold)).foregroundStyle(.white).lineLimit(2).minimumScaleFactor(0.8); Spacer(minLength: 0) } }
        }.frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

#Preview { NavigationStack { RPGAdventureView().environmentObject(ProgressViewModel()).environmentObject(AppSettings.shared) } }
