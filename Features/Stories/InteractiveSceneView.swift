import SwiftUI

/// Plays through a branching sequence of `StoryScene`s: background,
/// characters, narration and choices. Used by both the Stories tab and
/// Adventure's Story Mode chapters, so the scene/choice engine only needs
/// to exist once.
///
/// ## The two confirmed bugs, from real-device diagnostic evidence
///
/// A diagnostic build (colored borders + runtime frame logging on a
/// physical iPhone) tracked down two structural issues that no amount of
/// static layout reasoning had found:
///
/// 1. **Narration width.** Choice buttons were always contained correctly;
///    narration was not — its text painted outside the left edge of the
///    screen. The cause was `HStack { SpeakerButton; CharacterDialogueBubble }`
///    in `panelContent`: an `HStack` splits its offered width between its
///    children, and that negotiation is what let the bubble claim more
///    width than it was actually offered, even though `CharacterDialogueBubble`'s
///    own modifiers were fine in isolation. Choices never went through this
///    negotiation, which is exactly why they were unaffected.
///
///    Fixed by removing `SpeakerButton` from narration's horizontal sizing
///    path entirely: it's now a `ZStack` overlay on top of
///    `CharacterDialogueBubble` instead of a sibling beside it. A `ZStack`
///    proposes its own full resolved size to *each* child independently —
///    there's no splitting — so `SpeakerButton` can no longer influence the
///    width `CharacterDialogueBubble` receives. The bubble now gets the
///    same bounded width choice buttons get, from the same parent.
///
/// 2. **Panel height.** `ScrollView` + `.fixedSize(horizontal: false,
///    vertical: true)` + `.frame(maxHeight:)` — a commonly-cited pattern
///    for "content-driven height with a cap" — was confirmed on-device to
///    not behave that way in this hierarchy: the panel rendered far taller
///    than its actual content, leaving large empty space below the choice
///    buttons.
///
///    Fixed by making the panel a plain, ordinary `VStack` with no
///    `ScrollView` and no height cap of its own — its height comes only
///    from its children (narration + choices) plus padding, the same way
///    any normal SwiftUI view sizes itself. For scenes whose *total*
///    on-screen content (artwork + panel) genuinely exceeds the available
///    height — long narration, larger Dynamic Type sizes — the iPhone
///    layout wraps artwork+panel together in one outer `ScrollView`, so
///    there is exactly one, clearly-owned scrolling region and it only
///    engages when content actually overflows. A normal short scene never
///    triggers it.
///
/// The one remaining `GeometryReader`, at the very top of `body`, is still
/// needed: it's what tells this view the real width/height it has to
/// divide between artwork and panel, and there is no way to know that
/// without asking the container.
struct InteractiveSceneView: View {
    let title: String
    let scenes: [StoryScene]
    let onFinished: () -> Void

    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var currentIndex = 0
    @State private var hasEnteredScene = false

    private var currentScene: StoryScene {
        scenes[min(currentIndex, scenes.count - 1)]
    }

    private var narrationText: String {
        Loc.t(currentScene.narrationKey)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                PlayLandBackground(imageName: currentScene.background)
                    .transition(.opacity)
                    .id(currentScene.background)

                if horizontalSizeClass == .regular {
                    // iPad / regular width: artwork beside the panel,
                    // side by side. `.frame(maxWidth: .infinity)` gives the
                    // panel the leftover width after the artwork's fixed
                    // regionWidth; the panel's height comes purely from its
                    // own content (see `panel`).
                    let regionHeight = geometry.size.height - 40
                    let regionWidth = geometry.size.width * 0.42

                    HStack(alignment: .top, spacing: 20) {
                        sceneArt(regionSize: CGSize(width: regionWidth, height: regionHeight))
                            .frame(width: regionWidth, height: regionHeight)

                        panel
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(20)
                } else {
                    // iPhone / compact width: artwork on top at a fixed
                    // fraction of the screen, then the content-sized panel
                    // directly below it. The two are wrapped in a single
                    // outer ScrollView so genuinely tall content (long
                    // narration, large Dynamic Type) can scroll — but a
                    // normal short scene's total height stays under the
                    // screen's, so it never actually scrolls or leaves
                    // empty space.
                    let artHeight = geometry.size.height * 0.42

                    ScrollView {
                        VStack(spacing: 12) {
                            sceneArt(regionSize: CGSize(width: geometry.size.width, height: artHeight))
                                .frame(width: geometry.size.width, height: artHeight)

                            panel
                                .padding(.horizontal, PlayLandMetrics.contentHorizontalMargin)
                                .padding(.bottom, 12)
                        }
                        .frame(width: geometry.size.width)
                    }
                }
            }
            // Hard backstop: nothing rendered inside this scene can ever
            // claim more width or height than the device actually has.
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .animation(PlayLandAnimation.respecting(reduceMotion, .easeInOut(duration: 0.3)), value: currentIndex)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { enterScene() }
        .onChange(of: currentIndex) { _ in enterScene() }
    }

    // MARK: - Scene art

    /// Characters are placed and sized as fractions of `regionSize` — the
    /// scene art region's *own* local size, never the full screen — so
    /// they scale with the region instead of being positioned by
    /// screen-wide offsets that assume one device size.
    private func sceneArt(regionSize: CGSize) -> some View {
        ZStack {
            ForEach(Array(currentScene.characters.enumerated()), id: \.offset) { index, character in
                let count = currentScene.characters.count
                // Evenly distributes 1-3 characters across the width with
                // built-in margins: for count=1 this is 0.5 (centered); for
                // count=3 it's 0.25/0.5/0.75. No case ever places a
                // character at the literal edge.
                let xFraction = CGFloat(index + 1) / CGFloat(count + 1)
                let widthFraction = characterWidthFraction(index: index, count: count)
                let charWidth = regionSize.width * widthFraction
                let charHeight = regionSize.height * 0.88

                AppAssets.image(character)
                    .resizable()
                    .scaledToFit()
                    // Both dimensions are capped, so scaledToFit can only
                    // ever shrink to fit inside this box — never grow past
                    // the width or height budget, regardless of the source
                    // image's aspect ratio.
                    .frame(width: charWidth, height: charHeight, alignment: .bottom)
                    .shadow(color: .black.opacity(0.35), radius: 6, y: 4)
                    .position(x: regionSize.width * xFraction, y: regionSize.height - charHeight / 2 - regionSize.height * 0.04)
                    .scaleEffect(hasEnteredScene ? 1.0 : 0.85)
                    .opacity(hasEnteredScene ? 1.0 : 0.0)
            }
        }
        .frame(width: regionSize.width, height: regionSize.height)
        .clipped()
    }

    /// Roughly matches "Babis ~25-35%, Kotsifi ~20-28%" of the scene
    /// width, tightened slightly when a third character is present so
    /// nobody crowds past their margin.
    private func characterWidthFraction(index: Int, count: Int) -> CGFloat {
        switch count {
        case 1: return 0.34
        case 2: return index == 0 ? 0.32 : 0.24
        default: return index == 0 ? 0.28 : 0.20
        }
    }

    // MARK: - Interaction panel

    /// A plain, content-sized panel: its height comes only from
    /// `panelContent`'s children and padding — no `ScrollView`, no height
    /// cap, no measurement. See the type-level doc comment for why the
    /// previous `ScrollView` + `fixedSize` + `frame(maxHeight:)` approach
    /// is gone.
    private var panel: some View {
        panelContent
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge))
    }

    /// Narration and choices are siblings in one `VStack` that receives
    /// the parent's full offered width via
    /// `.frame(maxWidth: .infinity, alignment: .leading)` — the same
    /// bounded width for both, no separate width computation for either.
    /// `SpeakerButton` is layered on top of `CharacterDialogueBubble` as a
    /// `ZStack` overlay so it never participates in the bubble's width
    /// negotiation (see the type-level doc comment).
    private var panelContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack(alignment: .topTrailing) {
                CharacterDialogueBubble(text: narrationText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                SpeakerButton(text: narrationText)
                    .padding(8)
            }

            if currentScene.choices.isEmpty {
                PlayLandPrimaryButton(title: Loc.t("action.theEnd"), color: PlayLandColors.sunOrange, action: onFinished)
                    .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 10) {
                    ForEach(currentScene.choices) { choice in
                        Button(action: { choose(choice) }) {
                            Text(Loc.t(choice.textKey))
                        }
                        .buttonStyle(PlayLandChoiceButtonStyle())
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func choose(_ choice: StoryChoice) {
        AudioManager.shared.play(.storyNext)
        guard let next = choice.nextSceneIndex, scenes.indices.contains(next) else {
            onFinished()
            return
        }
        hasEnteredScene = false
        currentIndex = next
    }

    private func enterScene() {
        SpeechManager.shared.speak(text: narrationText)
        withAnimation(PlayLandAnimation.respecting(reduceMotion, PlayLandAnimation.bounce)) {
            hasEnteredScene = true
        }
    }
}
