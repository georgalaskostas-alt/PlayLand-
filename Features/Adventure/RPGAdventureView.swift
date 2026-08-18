import SwiftUI

struct RPGAdventureView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var showGame = false

    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                PlayLandBackground(imageName: "rpg_forest_ground_01", scrimOpacity: 0)
                    .overlay(Color.black.opacity(0.22).ignoresSafeArea())

                if geometry.size.width > geometry.size.height {
                    landscapeLauncher
                        .padding(.horizontal, 30)
                        .padding(.vertical, 20)
                } else {
                    portraitLauncher
                        .padding(.horizontal, 20)
                        .padding(.top, 18)
                        .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle(isGreek ? "Περιπέτειες" : "Adventures")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showGame) {
            ZStack(alignment: .topTrailing) {
                BabisRPGGameView()
                    .environmentObject(appSettings)

                Button {
                    showGame = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(.black.opacity(0.56))
                        .overlay(Circle().stroke(.white.opacity(0.22), lineWidth: 1))
                        .clipShape(Circle())
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
                .accessibilityLabel(isGreek ? "Έξοδος από το παιχνίδι" : "Exit game")
                .zIndex(100)
            }
        }
    }

    private var portraitLauncher: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                titleBlock

                HStack(alignment: .bottom, spacing: 14) {
                    AppAssets.image("babis_rpg_master")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 185, maxHeight: 225)

                    AppAssets.image("kotsifi_rpg_master")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 105, maxHeight: 135)
                }
                .frame(maxWidth: .infinity)

                introCard
                startButton

                Text(isGreek
                     ? "Μόλις ξεκινήσει το παιχνίδι, γύρισε το κινητό οριζόντια για τον πλήρη κόσμο RPG."
                     : "When the game starts, rotate the phone to landscape for the full RPG world.")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.88))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }
        }
    }

    private var landscapeLauncher: some View {
        HStack(spacing: 26) {
            VStack(spacing: 14) {
                titleBlock

                HStack(alignment: .bottom, spacing: 16) {
                    AppAssets.image("babis_rpg_master")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 210, height: 235)

                    AppAssets.image("kotsifi_rpg_master")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 145)
                }
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 18) {
                introCard
                startButton
                roadmapCard
            }
            .frame(maxWidth: 640)
        }
    }

    private var titleBlock: some View {
        VStack(spacing: 5) {
            Text(isGreek ? "Η Μεγάλη Περιπέτεια" : "The Great Adventure")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.4), radius: 5, y: 2)

            Text(isGreek ? "με τον Μπάμπη και το Κοτσύφι" : "with Babis & Kotsifi")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(isGreek ? "Ένας πραγματικός κόσμος σε πραγματικό χρόνο" : "A real-time world", systemImage: "sparkles")
                .font(.headline.weight(.black))
                .foregroundStyle(.white)

            Text(isGreek
                 ? "Εξερεύνησε το δάσος, μάζεψε αντικείμενα, βρες σεντούκια, άκου το Κοτσύφι και ολοκλήρωσε αποστολές."
                 : "Explore the forest, collect items, find chests, listen to Kotsifi and complete quests.")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.86))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.black.opacity(0.58))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var startButton: some View {
        Button {
            showGame = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "gamecontroller.fill")
                Text(isGreek ? "Ξεκίνα την Περιπέτεια" : "Start Adventure")
            }
            .font(.title3.weight(.black))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(PlayLandColors.sunOrange)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.28), radius: 7, y: 4)
        }
    }

    private var roadmapCard: some View {
        VStack(alignment: .leading, spacing: 7) {
            roadmapRow("🌲", isGreek ? "Δάσος — συλλογή και πρώτο σεντούκι" : "Forest — gathering and first chest")
            roadmapRow("🏘️", isGreek ? "Χωριό — NPC και αποστολές" : "Village — NPCs and quests")
            roadmapRow("💎", isGreek ? "Κρυστάλλινη Σπηλιά — γρίφοι" : "Crystal Cave — puzzles")
        }
        .padding(14)
        .background(.black.opacity(0.42))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func roadmapRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 9) {
            Text(icon)
            Text(text)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        RPGAdventureView()
            .environmentObject(ProgressViewModel())
            .environmentObject(AppSettings.shared)
    }
}
