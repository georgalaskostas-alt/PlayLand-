import SwiftUI

// MARK: - TEMPORARY DIAGNOSTIC INSTRUMENTATION — DELETE AFTER USE
//
// Added solely to investigate the InteractiveSceneView horizontal-overflow
// / oversized-panel-height bug with REAL runtime frame data from a physical
// device, after two rounds of static-analysis-based fixes both failed on
// real hardware. Delete this entire file, and every `.debugLayout(...)`
// call site in `InteractiveSceneView.swift` and `CharacterDialogueBubble.swift`,
// once that bug is fixed using the evidence this produces. Not gated behind
// `#if DEBUG` deliberately, so it compiles the same way in whatever
// configuration is used to test on-device; remove it rather than leave it
// disabled.

struct DebugFrameEntry: Equatable {
    let label: String
    let global: CGRect
    let local: CGRect
}

struct DebugFramePreferenceKey: PreferenceKey {
    static var defaultValue: [DebugFrameEntry] = []
    static func reduce(value: inout [DebugFrameEntry], nextValue: () -> [DebugFrameEntry]) {
        value.append(contentsOf: nextValue())
    }
}

extension View {
    /// Draws a 2pt colored border around this view's ACTUAL layout
    /// bounds — no padding is added to make the border easier to see,
    /// per the investigation's own requirement that borders represent the
    /// real frame — and reports this view's runtime frame, in both
    /// `.global` and `.local` coordinate spaces, up to the nearest
    /// `.onPreferenceChange(DebugFramePreferenceKey.self)` ancestor.
    /// `.border()` and the measuring `.background(GeometryReader)` are
    /// applied without any padding/frame of their own, so they read
    /// exactly the size and position this view already has.
    func debugLayout(_ label: String, _ color: Color) -> some View {
        self
            .border(color, width: 2)
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: DebugFramePreferenceKey.self,
                        value: [DebugFrameEntry(
                            label: label,
                            global: proxy.frame(in: .global),
                            local: proxy.frame(in: .local)
                        )]
                    )
                }
            )
    }
}

/// Prints every collected `DebugFrameEntry` as requested for this
/// investigation. Call from a single
/// `.onPreferenceChange(DebugFramePreferenceKey.self)` at the top of
/// `InteractiveSceneView.body` — every `.debugLayout(...)` call anywhere
/// in its descendant tree (including inside `CharacterDialogueBubble`,
/// a different file) reports up to that one listener automatically via
/// SwiftUI's normal preference-key propagation.
func printLayoutDebug(_ entries: [DebugFrameEntry]) {
    func r(_ v: CGFloat) -> String { String(format: "%.1f", v) }
    print("LAYOUT DEBUG")
    for entry in entries {
        let g = entry.global
        let l = entry.local
        print("\(entry.label): global(x=\(r(g.origin.x)), y=\(r(g.origin.y)), w=\(r(g.width)), h=\(r(g.height)))  local(x=\(r(l.origin.x)), y=\(r(l.origin.y)), w=\(r(l.width)), h=\(r(l.height)))")
    }
}
