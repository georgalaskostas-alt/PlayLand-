import SwiftUI

struct RPGAdventureView: View {
    @EnvironmentObject var appSettings: AppSettings

    private var isGreek: Bool { appSettings.resolvedLanguage == .greek }

    var body: some View {
        NavigationStack {
            ZStack {
                PlayLandBackground(imageName: "rpg_forest_ground_01", scrimOpacity: 0)
                    .overlay(Color.black.opacity(0.18).ignoresSafeArea())

                ScrollView {
                    VStack(spacing: 22) {
                        Text(isGreek ? "Η Μεγάλη Περιπέτεια του Μπάμπη" : "Babis: The Great Adventure")
                            .font(PlayLandTypography.display)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .shadow(radius: 4)

                        HStack(alignment: .bottom, spacing: 20) {
                            AppAssets.image("babis_neutral")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 155, height: 155)
                            AppAssets.image("kotsifi_idle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                        }

                        PlayLandCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(isGreek ? "Πραγματικός κόσμος σε πραγματικό χρόνο" : "A real-time world")
                                    .font(PlayLandTypography.title)
                                Text(isGreek
                                     ? "Κίνησε τον Μπάμπη μέσα στο δάσος, μάζεψε τρόφιμα, νερό και ξύλα, βρες το σεντούκι και ολοκλήρωσε αποστολές. Ο κόσμος θα μεγαλώνει με νέες περιοχές, NPC, γρίφους και quests."
                                     : "Move Babis through the forest, collect food, water and wood, find the chest and complete quests. The world will expand with new areas, NPCs, puzzles and missions.")
                                    .font(PlayLandTypography.body)
                                    .foregroundColor(PlayLandColors.secondaryText)
                            }
                        }

                        NavigationLink(destination: BabisRPGGameView()) {
                            HStack {
                                Image(systemName: "gamecontroller.fill")
                                Text(isGreek ? "Ξεκίνα την Περιπέτεια" : "Start Adventure")
                                    .font(.title3.weight(.bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(PlayLandColors.sunOrange)
                            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge))
                            .shadow(color: .black.opacity(0.25), radius: 6, y: 4)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text(isGreek ? "Τι έρχεται στον κόσμο" : "World roadmap")
                                .font(PlayLandTypography.heading)
                                .foregroundColor(.white)
                            roadmapRow("🌲", isGreek ? "Δάσος — συλλογή και πρώτο σεντούκι" : "Forest — gathering and first chest")
                            roadmapRow("🏘️", isGreek ? "Χωριό — NPC και αποστολές" : "Village — NPCs and quests")
                            roadmapRow("💎", isGreek ? "Κρυστάλλινη Σπηλιά — γρίφοι" : "Crystal Cave — puzzles")
                            roadmapRow("🌙", isGreek ? "Νυχτερινό Δάσος — εξερεύνηση" : "Night Forest — exploration")
                            roadmapRow("🦊", isGreek ? "Περιοχή Αλεπούς — story quests" : "Fox Area — story quests")
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge))
                    }
                    .padding()
                }
            }
            .navigationTitle(isGreek ? "Περιπέτειες" : "Adventures")
        }
    }

    private func roadmapRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 10) {
            Text(icon).font(.title2)
            Text(text).font(PlayLandTypography.body).foregroundColor(.white)
            Spacer()
        }
    }
}

#Preview {
    RPGAdventureView()
        .environmentObject(ProgressViewModel())
        .environmentObject(AppSettings.shared)
}
