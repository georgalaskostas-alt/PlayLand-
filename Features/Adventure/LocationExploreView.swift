import SwiftUI

/// The explorable scene for a single `WorldLocation`: a background, tappable
/// objects placed proportionally within it, and Babis (drag-to-move, with a
/// directional pad for precise steps) with Kotsifi trailing a half-step
/// behind rather than glued to his exact position.
struct LocationExploreView: View {
    let location: WorldLocation

    @EnvironmentObject var progressManager: ProgressViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var playerPosition: CGPoint = CGPoint(x: 0.5, y: 0.75)
    @State private var activeDialogue: [DialogueNode]?
    @State private var collectedObjectIds: Set<String> = []
    @State private var justUnlockedLocationKey: String?

    private let step: CGFloat = 0.05

    private var remainingObjects: [WorldObject] {
        location.objects.filter { !collectedObjectIds.contains($0.id) }
    }

    private var activeQuest: Quest? {
        location.objects.compactMap { $0.questId }.compactMap(QuestLibrary.quest(withId:)).first { !progressManager.isQuestCompleted($0.id) }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                PlayLandBackground(imageName: location.backgroundAsset, scrimOpacity: 0)

                ForEach(remainingObjects) { object in
                    Button(action: { interact(with: object) }) {
                        Text(object.emoji)
                            .font(.system(size: 50))
                            .frame(width: PlayLandMetrics.primaryTouchTarget, height: PlayLandMetrics.primaryTouchTarget)
                    }
                    .position(x: object.position.x * geometry.size.width, y: object.position.y * geometry.size.height)
                    .accessibilityLabel(Text(objectAccessibilityLabel(for: object)))
                }

                companion(in: geometry)

                player(in: geometry)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                move(to: CGPoint(x: value.location.x / geometry.size.width, y: value.location.y / geometry.size.height))
                            }
                    )

                VStack {
                    if let activeQuest {
                        questBanner(for: activeQuest)
                    }
                    Spacer()
                }
                .padding(.top, 12)

                dPad
            }
            .onAppear {
                playerPosition = CGPoint(x: 0.5, y: min(0.85, 1 - (60 / geometry.size.height)))
            }
        }
        .navigationTitle(Loc.t(location.titleKey))
        .sheet(isPresented: Binding(get: { activeDialogue != nil }, set: { if !$0 { activeDialogue = nil } })) {
            if let activeDialogue {
                DialogueView(nodes: activeDialogue) {
                    self.activeDialogue = nil
                }
                .presentationDetents([.medium])
            }
        }
        .overlay(alignment: .top) {
            if let key = justUnlockedLocationKey {
                unlockToast(titleKey: key)
            }
        }
    }

    private func player(in geometry: GeometryProxy) -> some View {
        AppAssets.image(AppAssets.Characters.babisSide)
            .resizable()
            .scaledToFit()
            .frame(width: 90, height: 90)
            .position(x: playerPosition.x * geometry.size.width, y: playerPosition.y * geometry.size.height)
            .accessibilityLabel(Text(Loc.t("adventure.babisName")))
    }

    private func companion(in geometry: GeometryProxy) -> some View {
        AppAssets.image(AppAssets.Characters.kotsifiSide)
            .resizable()
            .scaledToFit()
            .frame(width: 52, height: 52)
            .position(
                x: min(0.95, playerPosition.x + 0.09) * geometry.size.width,
                y: max(0.05, playerPosition.y - 0.07) * geometry.size.height
            )
            // A longer, separate animation than the player's own movement is
            // what makes Kotsifi read as "trailing behind" rather than
            // rigidly glued to Babis's exact coordinate every frame.
            .animation(PlayLandAnimation.respecting(reduceMotion, .easeOut(duration: 0.45)), value: playerPosition)
            .accessibilityHidden(true)
    }

    private var dPad: some View {
        VStack {
            Spacer()
            HStack {
                VStack(spacing: 6) {
                    arrowButton("▲", label: "accessibility.moveUp") { move(dx: 0, dy: -step) }
                    HStack(spacing: 36) {
                        arrowButton("◀", label: "accessibility.moveLeft") { move(dx: -step, dy: 0) }
                        arrowButton("▶", label: "accessibility.moveRight") { move(dx: step, dy: 0) }
                    }
                    arrowButton("▼", label: "accessibility.moveDown") { move(dx: 0, dy: step) }
                }
                Spacer()
            }
            .padding()
        }
    }

    private func arrowButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(symbol)
                .font(.title.bold())
                .foregroundColor(.white)
                .frame(width: PlayLandMetrics.primaryTouchTarget * 0.8, height: PlayLandMetrics.primaryTouchTarget * 0.8)
                .background(PlayLandColors.sunOrange)
                .clipShape(Circle())
                .shadow(radius: 3)
        }
        .accessibilityLabel(Text(Loc.t(label)))
    }

    private func questBanner(for quest: Quest) -> some View {
        HStack {
            Text(Loc.t("world.questBanner", Loc.t(quest.titleKey)))
                .font(PlayLandTypography.caption.weight(.bold))
            Spacer()
            Text(Loc.t("world.questProgress", progressManager.progress(forQuest: quest.id), quest.requiredProgress))
                .font(PlayLandTypography.caption)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.thinMaterial)
        .clipShape(Capsule())
        .padding(.horizontal)
    }

    private func unlockToast(titleKey: String) -> some View {
        Text("🎉 \(Loc.t("world.locationUnlocked")): \(Loc.t(titleKey))")
            .font(PlayLandTypography.body.weight(.semibold))
            .padding()
            .background(PlayLandColors.leafGreen)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func move(dx: CGFloat, dy: CGFloat) {
        withAnimation(PlayLandAnimation.respecting(reduceMotion, .easeInOut(duration: 0.2))) {
            playerPosition.x = min(0.95, max(0.05, playerPosition.x + dx))
            playerPosition.y = min(0.92, max(0.15, playerPosition.y + dy))
        }
    }

    private func move(to point: CGPoint) {
        playerPosition = CGPoint(
            x: min(0.95, max(0.05, point.x)),
            y: min(0.92, max(0.15, point.y))
        )
    }

    private func interact(with object: WorldObject) {
        activeDialogue = object.dialogue
        AudioManager.shared.play(.buttonTap)

        if let questId = object.questId {
            let previouslyUnlocked = Set(WorldLibrary.unlockRequirements.keys.filter(progressManager.isLocationUnlocked))
            progressManager.progressQuest(questId)
            if let itemId = object.collectibleItemId {
                progressManager.collectItem(itemId)
                // Only one-off collectibles (a stone, an item) disappear once
                // picked up; NPCs and landmarks stay put for repeat visits.
                collectedObjectIds.insert(object.id)
            }
            announceNewlyUnlockedLocations(previouslyUnlocked: previouslyUnlocked)
        }
    }

    private func announceNewlyUnlockedLocations(previouslyUnlocked: Set<String>) {
        let newlyUnlocked = WorldLibrary.unlockRequirements.keys.filter {
            progressManager.isLocationUnlocked($0) && !previouslyUnlocked.contains($0)
        }
        guard let unlockedId = newlyUnlocked.first, let unlockedLocation = WorldLibrary.location(withId: unlockedId) else { return }

        AudioManager.shared.play(.starReward)
        SpeechManager.shared.speak(text: "\(Loc.t("world.locationUnlocked")) \(Loc.t(unlockedLocation.titleKey))")
        withAnimation { justUnlockedLocationKey = unlockedLocation.titleKey }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { justUnlockedLocationKey = nil }
        }
    }

    private func objectAccessibilityLabel(for object: WorldObject) -> String {
        if let firstNode = object.dialogue.first, firstNode.speakerKey != WorldSpeaker.narrator {
            return Loc.t(firstNode.speakerKey)
        }
        return object.emoji
    }
}
