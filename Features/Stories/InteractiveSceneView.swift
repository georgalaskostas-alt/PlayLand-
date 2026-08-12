import SwiftUI

/// Reports a measured view's height up the tree so a parent can size a
/// container to its content instead of guessing or greedily filling.
private struct PanelHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// Plays through a branching sequence of `StoryScene`s: background,
/// characters, narration and choices. Used by both the Stories tab and
/// Adventure's Story Mode chapters, so the scene/choice engine only needs
/// to exist once.
///
/// Every size in this view is derived from the enclosing `GeometryReader`'s
/// *local* coordinate space — never from `UIScreen.main.bounds`, and never
/// left to a child's own "ideal" size.
///
/// A first attempt at the horizontal-overflow fix here relied on
/// `.frame(maxWidth: .infinity, alignment: .leading)` propagating a bounded
/// width down through a `ScrollView` and an `HStack`. That's ambiguous:
/// `maxWidth: .infinity` only says "expand to fill *whatever's offered*" —
/// it doesn't itself guarantee what's offered is already the real,
/// margin-adjusted screen width, and a vertical `ScrollView`'s cross-axis
/// sizing of unconstrained content is exactly the kind of thing that can
/// differ from what static reading of the modifier chain suggests, which
/// is what a real-device test caught. The panel below now computes its
/// width *once*, from `geometry.size.width`, and passes that single
/// concrete number down as a fixed `.frame(width:)` — not a `maxWidth` —
/// so there's nothing left to negotiate: every descendant (the dialogue
/// bubble, the choice buttons) is handed the same already-correct value
/// and can only wrap within it, never claim more.
struct InteractiveSceneView: View {
    let title: String
    let scenes: [StoryScene]
    let onFinished: () -> Void

    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var currentIndex = 0
    @State private var hasEnteredScene = false
    /// The interaction panel's own natural content height, measured via
    /// `PanelHeightKey`. 0 means "not measured yet."
    @State private var measuredPanelHeight: CGFloat = 0

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
                    // iPad / regular width: artwork beside the panel. The
                    // panel's width is computed once, right here, as
                    // exactly the leftover HStack space (total width minus
                    // the artwork's own width, the inter-item spacing, and
                    // this HStack's own .padding(20) on both sides) — not
                    // left for `maxWidth: .infinity` to resolve inside the
                    // ScrollView further down. It's the *exact* leftover
                    // amount, not an under-estimate, so the HStack's two
                    // children exactly fill the space the HStack itself
                    // was given; the panel's own internal 16pt padding
                    // (see `panelContent`) provides its text inset, rather
                    // than a second, separate margin subtracted here that
                    // would leave asymmetric unclaimed space on one side.
                    let outerPadding: CGFloat = 20
                    let interItemSpacing: CGFloat = 20
                    let regionHeight = geometry.size.height - 40
                    let regionWidth = geometry.size.width * 0.42
                    let panelWidth = max(geometry.size.width - regionWidth - interItemSpacing - outerPadding * 2, 0)

                    HStack(spacing: interItemSpacing) {
                        sceneArt(regionSize: CGSize(width: regionWidth, height: regionHeight))
                            .frame(width: regionWidth, height: regionHeight)

                        panel(cap: regionHeight, width: panelWidth)
                    }
                    .padding(outerPadding)
                } else {
                    // iPhone / compact width: artwork on top, panel below,
                    // centered with an equal margin on both sides. Same
                    // principle as the iPad branch: the panel's width is
                    // computed once from `geometry.size.width` and handed
                    // down as a concrete number.
                    let regionHeight = sceneHeight(totalHeight: geometry.size.height)
                    let panelWidth = max(geometry.size.width - PlayLandMetrics.contentHorizontalMargin * 2, 0)

                    VStack(alignment: .center, spacing: 0) {
                        sceneArt(regionSize: CGSize(width: geometry.size.width, height: regionHeight))
                            .frame(width: geometry.size.width, height: regionHeight)

                        Spacer(minLength: 0)

                        panel(cap: geometry.size.height * 0.55, width: panelWidth)
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

    /// The scene art region's height on iPhone: whatever's left after the
    /// interaction panel's *actual measured* height (capped), not a fixed
    /// split. A short panel (one line, no choices) gives the artwork more
    /// room; a long one (three choices, a long translation) gives the
    /// artwork less — clamped to a sensible range either way so characters
    /// are never crushed and the panel never dominates the whole screen.
    private func sceneHeight(totalHeight: CGFloat) -> CGFloat {
        let interactionCap = totalHeight * 0.55
        let usedByPanel = measuredPanelHeight > 0 ? min(measuredPanelHeight, interactionCap) : totalHeight * 0.5
        let remaining = totalHeight - usedByPanel
        return min(max(remaining, totalHeight * 0.32), totalHeight * 0.52)
    }

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

    /// `width` is the exact, already-margin-adjusted width computed by the
    /// caller (see `body`) — a fixed number, not a `maxWidth` ceiling. Both
    /// the `ScrollView` and its content are pinned to this same literal
    /// value, so nothing here can end up wider than what was actually
    /// computed, regardless of what a `ScrollView`'s cross-axis sizing or
    /// an `HStack`'s flexibility heuristics would otherwise decide on
    /// their own. Padding (in `panelContent`) is applied *before* this
    /// fixed frame, i.e. inside `width` — never outside it, which would
    /// silently add back the overflow this exists to prevent.
    private func panel(cap: CGFloat, width: CGFloat) -> some View {
        ScrollView {
            panelContent
                .frame(width: width, alignment: .leading)
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(key: PanelHeightKey.self, value: proxy.size.height)
                    }
                )
        }
        .frame(width: width)
        // Size to the panel's actual measured content, capped — not a
        // flat `maxHeight`, which a ScrollView will greedily fill even
        // when its content is one short line, producing an oversized
        // empty panel under a single choice.
        .frame(height: measuredPanelHeight > 0 ? min(measuredPanelHeight, cap) : nil)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge))
        .padding(.bottom, 12)
        .onPreferenceChange(PanelHeightKey.self) { measuredPanelHeight = $0 }
    }

    private var panelContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                SpeakerButton(text: narrationText)
                CharacterDialogueBubble(text: narrationText)
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
    }

    private func choose(_ choice: StoryChoice) {
        AudioManager.shared.play(.storyNext)
        guard let next = choice.nextSceneIndex, scenes.indices.contains(next) else {
            onFinished()
            return
        }
        hasEnteredScene = false
        measuredPanelHeight = 0
        currentIndex = next
    }

    private func enterScene() {
        SpeechManager.shared.speak(text: narrationText)
        withAnimation(PlayLandAnimation.respecting(reduceMotion, PlayLandAnimation.bounce)) {
            hasEnteredScene = true
        }
    }
}
