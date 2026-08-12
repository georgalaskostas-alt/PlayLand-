import Foundation

/// One word/phrase substitution, applied only to the string handed to
/// `AVSpeechSynthesizer` — never to anything shown on screen.
struct PronunciationEntry {
    /// The exact localized text to match (case-sensitive, whole-word).
    let original: String
    /// What should be spoken instead. Ordinary orthography, not IPA/a
    /// phonetic respelling — see `SpeechPronunciationResolver` for why.
    let spoken: String
}

/// Rewrites localized text into a TTS-friendlier form immediately before
/// it's handed to `AVSpeechSynthesizer` — the text shown on screen is
/// never touched, only the copy `SpeechManager` actually speaks.
///
/// This is wired into `SpeechManager.speak(text:language:)` itself, so
/// every call site in the app (game instructions, story narration, RPG
/// dialogue, chest/game completion praise) gets it automatically. No
/// screen needs its own pronunciation logic, and none should add one.
///
/// ## Why plain-text substitution, not IPA
/// `AVSpeechSynthesizer` does support precise phoneme control via
/// `AVSpeechSynthesisIPANotationAttributeName` on an attributed string
/// (a real, public, non-private API, available on this project's
/// deployment target). It was evaluated for this pass and intentionally
/// not used yet: correct IPA transcriptions can't be verified without
/// hearing real output on a device, and shipping a wrong phoneme string
/// would be worse than doing nothing — indistinguishable from doing
/// nothing "correctly" until someone listens to it. Respelling in plain
/// orthography (this file) is safer to guess at, trivially easy to tune
/// by ear, and needs no phonetic-alphabet expertise to edit. If IPA
/// tuning is wanted later, `PronunciationEntry` can grow an optional IPA
/// field and `SpeechManager` can switch to `AVSpeechUtterance(attributedString:)`
/// without changing this resolver's public shape.
enum SpeechPronunciationResolver {
    /// Returns the text that should actually be spoken for `text` in
    /// `language`. Identical to `text` whenever nothing in that language's
    /// dictionary matches — most languages have no entries at all yet, and
    /// return their input completely unchanged.
    static func spokenText(for text: String, language: AppLanguage) -> String {
        let entries = PronunciationDictionary.entries(for: language)
        guard !entries.isEmpty else { return text }

        var result = text
        for entry in entries where !entry.original.isEmpty {
            result = replacingWholeWord(entry.original, with: entry.spoken, in: result)
        }
        return result
    }

    /// Whole-word, case-sensitive substitution. Plain `String.replacingOccurrences`
    /// would happily match "Fox" inside "Foxglove"; this only matches a
    /// standalone occurrence of `original`, using `NSRegularExpression`'s
    /// Unicode-aware `\b` word-boundary matching (correct for Greek and
    /// other non-ASCII scripts, unlike a POSIX-style boundary check).
    /// Punctuation, spacing and everything else in `text` is left exactly
    /// as it was.
    private static func replacingWholeWord(_ original: String, with spoken: String, in text: String) -> String {
        let pattern = "\\b\(NSRegularExpression.escapedPattern(for: original))\\b"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return text }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let template = NSRegularExpression.escapedTemplate(for: spoken)
        return regex.stringByReplacingMatches(in: text, range: range, withTemplate: template)
    }
}

/// Per-language pronunciation overrides. Every language has its own list —
/// a Greek respelling must never apply to English speech and vice versa,
/// so there is deliberately no single shared/global dictionary.
enum PronunciationDictionary {
    static func entries(for language: AppLanguage) -> [PronunciationEntry] {
        switch language {
        case .greek: return greek
        case .english: return english
        case .spanish, .french, .german, .italian, .portuguese, .system: return []
        }
    }

    // MARK: - Greek
    //
    // Character names as they actually appear in Localizable.xcstrings
    // (`adventure.babisName`/`adventure.kotsifiName`/`adventure.foxName`,
    // "el" table): Μπάμπης, Κότσιφας, Αλεπού. All three use standard Greek
    // spelling and digraphs (μπ, τσ) that installed Greek voices normally
    // read correctly on their own, so there is no confirmed mispronunciation
    // to fix yet — these entries are `original == spoken` (a verified-safe
    // no-op) purely to prove the pipeline end-to-end and give an exact,
    // correct place to make a change: after listening on a real device,
    // edit only the `spoken` side of an entry below. Do not delete or
    // rename these — other code doesn't reference them, but keeping the
    // real catalog spelling here (rather than a guess) is the point.
    private static let greek: [PronunciationEntry] = [
        PronunciationEntry(original: "Μπάμπης", spoken: "Μπάμπης"),
        PronunciationEntry(original: "Κότσιφας", spoken: "Κότσιφας"),
        PronunciationEntry(original: "Αλεπού", spoken: "Αλεπού")
    ]

    // MARK: - English
    //
    // Same 3 names, as they appear in the "en" table (also shared verbatim
    // by es/fr/de/it/pt today: "Babis", "Kotsifi", "Alepou"). These are
    // Greek-origin proper nouns being read by a non-Greek voice, which is
    // at least as likely to sound off as the Greek case above — but for
    // the same reason as the Greek entries, no respelling is applied until
    // a real listening pass confirms what actually needs adjusting.
    private static let english: [PronunciationEntry] = [
        PronunciationEntry(original: "Babis", spoken: "Babis"),
        PronunciationEntry(original: "Kotsifi", spoken: "Kotsifi"),
        PronunciationEntry(original: "Alepou", spoken: "Alepou")
    ]
}
