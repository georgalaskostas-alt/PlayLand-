import SwiftUI

/// Plays through a branching sequence of `StoryScene`s: background,
/// characters, narration and choices. Used by both the Stories tab and
/// Adventure's Story Mode chapters, so the scene/choice engine only needs
/// to exist once.
///
/// ## Three attempts at the horizontal-overflow fix, and why the first two
/// weren't enough
///
/// 1. `.frame(maxWidth: .infinity, alignment: .leading)` pinned inside a
///    `ScrollView`. `maxWidth: .infinity` sets no *upper bound* — if
///    anything inside still reported wanting more width than was on
///    screen, the whole chain would happily grow to fit it.
/// 2. A width computed via arithmetic (`geometry.size.width` minus a
///    hand-tracked sum of paddings/spacings), applied as a fixed
///    `.frame(width:)`, with the interaction panel wrapped in its own
///    `GeometryReader` for both width *and* height. This one was
///    over-engineered in a different direction: using that inner
///    `GeometryReader`'s *height* to size the panel created a circular
///    dependency (the panel's rendered height depended on a
///    `PreferenceKey` measurement of its own content, which itself only
///    stabilized after the panel had already rendered), and on the very
///    first layout pass — before any measurement exists — a bare
///    `GeometryReader` is greedy: it competed with the `Spacer()` above it
///    for the entire remaining `VStack` height rather than sizing to its
///    two short choice buttons. That's the "massively oversized empty
///    panel" a real device confirmed. The *width* half of that fix (the
///    reader-as-sizing-wall idea) wasn't actually wrong, but the
///    left-clipping persisted anyway, and two rounds of unconfirmed
///    layout theory is enough — this pass simplifies instead of adding a
///    third layer of geometry math on top of the first two.
///
/// The current approach removes all of that in favor of the plainest
/// SwiftUI idiom for "content that wraps and sizes to itself": narration
/// and choices live in a normal `VStack` with
/// `.frame(maxWidth: .infinity, alignment: .leading)` and a real
/// `.padding(.horizontal:)`, and the surrounding `ScrollView` uses
/// `.fixedSize(horizontal: false, vertical: true)` + `.frame(maxHeight:)`
/// — a standard, well-documented pairing: `fixedSize` makes the scroll
/// view report its *content's* natural height to its parent (so a short
/// panel only ever claims a short amount of space — no `PreferenceKey`
/// measurement needed), and `frame(maxHeight:)` is purely an upper bound
/// that only starts clipping/scrolling once content genuinely exceeds it.
/// The one remaining `GeometryReader`, at the very top of `body`, is
/// still needed: it's what tells this view the real width/height it has
/// to divide between artwork and panel in the first place, and there is
/// no way to know that without asking the container.
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
                    // iPad / regular width: artwork beside the panel.
                    // `.frame(maxWidth: .infinity)` tells the HStack "give
                    // this child the leftover space after the artwork's
                    // fixed regionWidth" — the panel itself never claims
                    // more than that, or more vertical space than its own
                    // content needs (see `panel(maxHeight:)`).
                    let regionHeight = geometry.size.height - 40
                    let regionWidth = geometry.size.width * 0.42

                    HStack(alignment: .top, spacing: 20) {
                        sceneArt(regionSize: CGSize(width: regionWidth, height: regionHeight))
                            .frame(width: regionWidth, height: regionHeight)

                        panel(maxHeight: regionHeight)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(20)
                } else {
                    // iPhone / compact width: artwork on top at a fixed
                    // fraction of the screen (independent of how much
                    // dialogue text there is — no circular "artwork size
                    // depends on panel size which depends on artwork size"
                    // to reason about), then the panel sized to its own
                    // content directly below it, then a trailing Spacer
                    // absorbing whatever's left.
                    let artHeight = geometry.size.height * 0.42

                    VStack(spacing: 12) {
                        sceneArt(regionSize: CGSize(width: geometry.size.width, height: artHeight))
                            .frame(width: geometry.size.width, height: artHeight)

                        panel(maxHeight: geometry.size.height * 0.48)
                            .padding(.horizontal, PlayLandMetrics.contentHorizontalMargin)

                        Spacer(minLength: 0)
                    }
                    .padding(.bottom, 12)
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

    /// Sizes itself to `panelContent`'s own natural height — a short
    /// scene (narration + 1-2 choices) produces a short, compact panel —
    /// and only starts clipping/scrolling once that natural height
    /// exceeds `maxHeight`. No measurement, no `PreferenceKey`, no nested
    /// `GeometryReader`: `.fixedSize(vertical: true)` is what makes a
    /// `ScrollView` report its content's real height to its parent
    /// instead of greedily claiming whatever the parent offers, and
    /// `.frame(maxHeight:)` is a plain upper bound layered on top of that.
    private func panel(maxHeight: CGFloat) -> some View {
        ScrollView {
            panelContent
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxHeight: maxHeight)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: PlayLandMetrics.cornerRadiusLarge))
    }

    /// `.frame(maxWidth: .infinity, alignment: .leading)` here is what
    /// makes this content claim exactly the width its parent (the
    /// `ScrollView` above) offers — no more, no less — so narration and
    /// choice buttons wrap against a real, finite width instead of each
    /// negotiating their own.
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
