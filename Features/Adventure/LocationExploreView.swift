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
    /// Runs once, then clears, when `activeDialogue` is dismissed — used to
    /// chain "approach dialogue closes → challenge launches" for chests
    /// without the dialogue engine needing to know chests exist.
    @State private var pendingAfterDialogue: (() -> Void)?
    @State private var activeChallenge: RPGChallenge?
    @State private var chestPendingChallenge: ChestDefinition?
    @State private var chestReward: ChestRewardPresentation?
    @State private var collectedObjectIds: Set<String> = []
    @State private var justUnlockedLocationKey: String?
    /// True while Babis is actively being moved (drag or D-pad), driving
    /// the run/fly frame-cycle animation. Never a source of movement logic
    /// itself — position math is untouched by this.
    @State private var isMoving = false

    private let step: CGFloat = 0.05

    /// Chests stay visible even when locked (a visible progression cue);
    /// every other unlock-gated object simply doesn't render until its
    /// requirement is met.
    private var remainingObjects: [WorldObject] {
        location.objects.filter { object in
            guard !collectedObjectIds.contains(object.id) else { return false }
            if object.chest != nil { return true }
            return progressManager.isRequirementMet(object.unlockRequirement)
        }
    }

    private var activeQuest: Quest? {
        location.objects.compactMap { $0.questId }.compactMap(QuestLibrary.quest(withId:)).first { !progressManager.isQuestCompleted($0.id) }
    }

    /// The current chapter of any available campaign that plays out here,
    /// if it isn't finished yet — shown as a friendlier "what to do right
    /// now" banner above the raw quest banner.
    private var activeChapterGoal: CampaignChapter? {
        CampaignLibrary.campaigns
            .filter { $0.status == .available }
            .compactMap { CampaignLibrary.currentChapter(for: $0, progress: progressManager) }
            .first { $0.locationId == location.id }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                PlayLandBackground(imageName: location.resolvedGroundAsset, scrimOpacity: 0)

                ForEach(remainingObjects) { object in
                    Button(action: { interact(with: object) }) {
                        objectVisual(for: object)
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
                            .onEnded { _ in
                                isMoving = false
                            }
                    )

                VStack(spacing: 8) {
                    if let activeChapterGoal {
                        chapterGoalBanner(for: activeChapterGoal)
                    }
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
                    let next = pendingAfterDialogue
                    pendingAfterDialogue = nil
                    next?()
                }
                .presentationDetents([.medium])
            }
        }
        .fullScreenCover(item: $activeChallenge) { challenge in
            ChallengeLauncherView(challenge: challenge) { outcome in
                activeChallenge = nil
                let chest = chestPendingChallenge
                chestPendingChallenge = nil
                handleChallengeOutcome(outcome, chest: chest)
            }
        }
        .fullScreenCover(item: $chestReward) { reward in
            CompletionCelebrationView(
                title: Loc.t("world.chestOpened"),
                message: Loc.t(reward.chest.rewardPraiseKey),
                stars: reward.stars,
                buttonTitle: Loc.t("action.continue"),
                action: { chestReward = nil },
                imageAssetName: AppAssets.PlannedProps.chestOpen,
                rewardItemId: reward.chest.challenge.rewardItemId,
                rewardItemCount: reward.chest.challenge.rewardItemCount
            )
        }
        .overlay(alignment: .top) {
            if let key = justUnlockedLocationKey {
                unlockToast(titleKey: key)
            }
        }
    }

    /// The world-tile art for `object`, if any exists: its own `assetName`
    /// (scenery like a tree or rock), or — for a collectible — the same
    /// art `ItemLibrary` already uses for that item everywhere else, so
    /// item art has exactly one source of truth.
    private func worldTileAsset(for object: WorldObject) -> String? {
        if let assetName = object.assetName { return assetName }
        if let itemId = object.collectibleItemId { return ItemLibrary.item(withId: itemId)?.assetName }
        return nil
    }

    @ViewBuilder
    private func objectVisual(for object: WorldObject) -> some View {
        Group {
            if let chest = object.chest {
                chestIcon(for: chest, state: chestState(for: chest, requirement: object.unlockRequirement))
            } else if let assetName = worldTileAsset(for: object), AppAssets.exists(assetName) {
                AppAssets.image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: PlayLandMetrics.worldSceneryVisualSize, height: PlayLandMetrics.worldSceneryVisualSize)
            } else {
                Text(object.emoji)
                    .font(.system(size: 50))
            }
        }
        // The tappable region stays a fixed, forgiving logical size no
        // matter how big the art renders or how much transparent padding
        // its source PNG has — production scenery reads at landscape scale
        // visually without ever changing what's actually tappable.
        .frame(width: PlayLandMetrics.primaryTouchTarget, height: PlayLandMetrics.primaryTouchTarget)
        .contentShape(Rectangle())
    }

    /// Cycles through `frames` (filtered to ones that actually exist) on a
    /// fixed interval while `isAnimating` is true. Built on `TimelineView`,
    /// which pauses itself whenever it isn't being drawn — there's no
    /// `Timer` to invalidate and nothing that can keep running off-screen.
    /// Falls back to a single static image when animation shouldn't run:
    /// Reduce Motion is on, nothing is actually moving, or none of
    /// `frames` resolve yet (today's case — a zero-regression no-op).
    @ViewBuilder
    private func animatedCharacter(frames: [String], interval: Double, isAnimating: Bool, fallback: Image, size: CGFloat) -> some View {
        let existingFrames = frames.filter(AppAssets.exists)
        if isAnimating, !reduceMotion, !existingFrames.isEmpty {
            TimelineView(.periodic(from: .now, by: interval)) { timeline in
                let index = Int(timeline.date.timeIntervalSinceReferenceDate / interval) % existingFrames.count
                AppAssets.image(existingFrames[index])
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            }
        } else {
            fallback
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
    }

    private func chestIcon(for chest: ChestDefinition, state: ChestVisualState) -> some View {
        ZStack {
            AppAssets.image(state == .opened ? AppAssets.PlannedProps.chestOpen : AppAssets.PlannedProps.chestClosed)
                .resizable()
                .scaledToFit()
                .frame(width: PlayLandMetrics.primaryTouchTarget, height: PlayLandMetrics.primaryTouchTarget)
                .opacity(state == .locked ? 0.55 : 1.0)

            if state == .locked {
                Image(systemName: "lock.fill")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Circle().fill(Color.black.opacity(0.6)))
                    .offset(x: 18, y: -18)
            }
        }
    }

    private func player(in geometry: GeometryProxy) -> some View {
        animatedCharacter(
            frames: BabisVisualState.runFrames,
            interval: 0.12,
            isAnimating: isMoving,
            fallback: AppAssets.image(AppAssets.Characters.babisSide),
            size: 90
        )
        .position(x: playerPosition.x * geometry.size.width, y: playerPosition.y * geometry.size.height)
        .accessibilityLabel(Text(Loc.t("adventure.babisName")))
    }

    private func companion(in geometry: GeometryProxy) -> some View {
        animatedCharacter(
            frames: [AppAssets.KotsifiStates.fly1, AppAssets.KotsifiStates.fly2, AppAssets.KotsifiStates.fly3],
            interval: 0.15,
            isAnimating: isMoving,
            fallback: AppAssets.image(AppAssets.Characters.kotsifiSide),
            size: 52
        )
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

    private func chapterGoalBanner(for chapter: CampaignChapter) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(Loc.t(chapter.titleKey))
                .font(PlayLandTypography.caption.weight(.bold))
            Text(Loc.t(chapter.goalKey))
                .font(PlayLandTypography.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(PlayLandColors.sunOrange)
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusSmall))
        .padding(.horizontal)
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
        isMoving = true
        withAnimation(PlayLandAnimation.respecting(reduceMotion, .easeInOut(duration: 0.2))) {
            playerPosition.x = min(0.95, max(0.05, playerPosition.x + dx))
            playerPosition.y = min(0.92, max(0.15, playerPosition.y + dy))
        }
        // A D-pad tap is a single instantaneous move, not a continuous
        // gesture with its own onEnded — clear the run/fly animation after
        // it's had a couple of frames to play, the same one-shot
        // `asyncAfter` pattern already used for `unlockToast` below.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isMoving = false
        }
    }

    private func move(to point: CGPoint) {
        isMoving = true
        playerPosition = CGPoint(
            x: min(0.95, max(0.05, point.x)),
            y: min(0.92, max(0.15, point.y))
        )
    }

    private func interact(with object: WorldObject) {
        AudioManager.shared.play(.buttonTap)

        if let chest = object.chest {
            interactWithChest(chest, object: object)
            return
        }

        activeDialogue = object.dialogue

        if let questId = object.questId {
            let previouslyUnlocked = Set(WorldLibrary.unlockRequirements.keys.filter(progressManager.isLocationUnlocked))
            progressManager.progressQuest(questId)
            if let itemId = object.collectibleItemId {
                progressManager.collectItem(itemId, count: object.collectibleItemCount)
                // Only one-off collectibles (a stone, an item) disappear once
                // picked up; NPCs and landmarks stay put for repeat visits.
                collectedObjectIds.insert(object.id)
            }
            announceNewlyUnlockedLocations(previouslyUnlocked: previouslyUnlocked)
        }
    }

    /// Tap → approach dialogue → challenge → reward, per the chest state:
    /// locked shows a "not yet" hint, challenge-available plays the approach
    /// dialogue then launches the mini-game, opened just shows flavor text.
    /// Walking away or losing the mini-game leaves the chest exactly as it
    /// was — there's no penalty and no lockout on retrying.
    private func interactWithChest(_ chest: ChestDefinition, object: WorldObject) {
        switch chestState(for: chest, requirement: object.unlockRequirement) {
        case .locked:
            activeDialogue = chest.lockedHintDialogue
        case .opened:
            activeDialogue = chest.openedFlavorDialogue
        case .challengeAvailable:
            activeDialogue = chest.approachDialogue
            pendingAfterDialogue = {
                chestPendingChallenge = chest
                activeChallenge = chest.challenge
            }
        }
    }

    private func chestState(for chest: ChestDefinition, requirement: LocationUnlockRequirement) -> ChestVisualState {
        if progressManager.isChallengeCompleted(chest.id) { return .opened }
        if !progressManager.isRequirementMet(requirement) { return .locked }
        return .challengeAvailable
    }

    private func handleChallengeOutcome(_ outcome: ChallengeOutcome, chest: ChestDefinition?) {
        guard let chest else { return }
        switch outcome {
        case .cancelled:
            break
        case .success(let stars):
            progressManager.completeChallenge(chest.id, rewardStars: chest.challenge.rewardStars)
            if let rewardItemId = chest.challenge.rewardItemId {
                progressManager.collectItem(rewardItemId, count: chest.challenge.rewardItemCount)
            }
            if let questId = chest.challenge.questIdToProgress {
                progressManager.progressQuest(questId)
            }
            chestReward = ChestRewardPresentation(id: chest.id, chest: chest, stars: stars)
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
        if object.chest != nil {
            return Loc.t("world.chest.accessibilityLabel")
        }
        if let firstNode = object.dialogue.first, firstNode.speakerKey != WorldSpeaker.narrator {
            return Loc.t(firstNode.speakerKey)
        }
        return object.emoji
    }
}

/// Wraps a won chest's data with its per-attempt star rating so
/// `.fullScreenCover(item:)` can present the reward celebration.
private struct ChestRewardPresentation: Identifiable {
    let id: String
    let chest: ChestDefinition
    let stars: Int
}
