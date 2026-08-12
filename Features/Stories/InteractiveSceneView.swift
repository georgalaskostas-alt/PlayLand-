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
/// ## Two earlier attempts at the horizontal-overflow fix, and why they
/// weren't enough
///
/// 1. `.frame(maxWidth: .infinity, alignment: .leading)` pinned inside the
///    `ScrollView`. `maxWidth: .infinity` sets no *upper bound* — if
///    anything inside still reported wanting more width than was on
///    screen, the whole chain would happily grow to fit it.
/// 2. Computing an exact pixel width via arithmetic (`geometry.size.width`
///    minus a hand-tracked sum of paddings/spacings) and applying that as
///    a fixed `.frame(width:)`. A *fixed* frame does report its declared
///    size upward regardless of what its child wants, which fixes the
///    *reported/logical* size — but `.frame()` alone does not clip the
///    *rendered* pixels of an oversized child, so content that still
///    wanted to be wider than that number could keep painting past the
///    panel's own bounds, only ever getting caught by the outermost
///    `.clipped()` at the very bottom of this file — which crops relative
///    to the *full screen*, not the panel's own position, and that
///    mismatch is what actually produced "text missing from the left
///    edge of the device" rather than a clean wrap.
///
/// `panel(cap:)` below fixes both problems at once with a different
/// technique: it wraps its content in its own local `GeometryReader`
/// immediately, and uses *that* reader's measured size — never arithmetic
/// — as the width fed to everything inside. A `GeometryReader` is a
/// one-way wall for sizing: it always accepts exactly what its own parent
/// proposes and reports that measurement into its closure; nothing placed
/// *inside* it can ever cause it to ask its parent for more. That removes
/// the entire class of bug above, without needing to hand-track a single
/// padding/spacing constant. A local `.clipped()` on the panel itself is
/// also added as a genuine (not primary) safety net, so that if something
/// unforeseen still overflows, it crops relative to the panel's own
/// already-correct position — never a screen-edge-wide misfire again.
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
                    // iPad / regular width: artwork beside the panel.
                    // `.frame(maxWidth: .infinity)` here only tells the
                    // HStack "give this child the leftover space after the
                    // artwork's fixed regionWidth" — it's safe now because
                    // `panel(cap:)` starts with its own GeometryReader,
                    // which never negotiates for more than it's proposed
                    // regardless of what's inside it (see the type doc
                    // comment above).
                    let regionHeight = geometry.size.height - 40
                    let regionWidth = geometry.size.width * 0.42

                    HStack(spacing: 20) {
                        sceneArt(regionSize: CGSize(width: regionWidth, height: regionHeight))
                            .frame(width: regionWidth, height: regionHeight)

                        panel(cap: regionHeight)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(20)
                } else {
                    // iPhone / compact width: artwork on top, panel below.
                    // The margin is real `.padding()` applied at this call
                    // site — unambiguous, well-defined SwiftUI behavior —
                    // and `panel(cap:)`'s own GeometryReader measures
                    // whatever's left after it, rather than this view
                    // trying to compute that number itself.
                    let regionHeight = sceneHeight(totalHeight: geometry.size.height)

                    VStack(alignment: .center, spacing: 0) {
                        sceneArt(regionSize: CGSize(width: geometry.size.width, height: regionHeight))
                            .frame(width: geometry.size.width, height: regionHeight)

                        Spacer(minLength: 0)

                        panel(cap: geometry.size.height * 0.55)
                            .padding(.horizontal, PlayLandMetrics.contentHorizontalMargin)
                            .padding(.bottom, 12)
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

    /// Wraps its content in a local `GeometryReader` and uses *that*
    /// reader's measured width for everything inside — never arithmetic,
    /// never a `maxWidth` ceiling on the content itself. See the type doc
    /// comment for why this specific technique (a `GeometryReader`
    /// interposed as a sizing wall) is what actually closes off the
    /// overflow, where a computed fixed-width frame alone did not.
    private func panel(cap: CGFloat) -> some View {
        GeometryReader { panelGeometry in
            ScrollView {
                panelContent
                    .frame(width: panelGeometry.size.width, alignment: .leading)
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(key: PanelHeightKey.self, value: proxy.size.height)
                        }
                    )
            }
            .frame(width: panelGeometry.size.width, height: panelGeometry.size.height)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge))
            // Local safety net (not the primary fix — the GeometryReader
            // wall above is): crops relative to the panel's own correct
            // position if anything inside ever again asks for more than
            // it was measured to have.
            .clipped()
        }
        // Size to the panel's actual measured content, capped — not a
        // flat `maxHeight`, which a ScrollView will greedily fill even
        // when its content is one short line, producing an oversized
        // empty panel under a single choice. `nil` before the first
        // measurement lets this GeometryReader take its parent's proposed
        // height for that one frame, same as before.
        .frame(height: measuredPanelHeight > 0 ? min(measuredPanelHeight, cap) : nil)
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
