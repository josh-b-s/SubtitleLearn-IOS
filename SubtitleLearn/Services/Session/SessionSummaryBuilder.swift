import Foundation

/// Turns a session's word counts into the numbers and lists on the summary screen.
enum SessionSummaryBuilder {
    static let maxTopWords = 8

    /// Known = saved and mastered, learning = saved but not mastered, new = not saved.
    static func build(from entries: [SessionEntry], saved: [SavedWord]) -> SessionSummary? {
        guard !entries.isEmpty else { return nil }
        let savedByWord = Dictionary(saved.map { ($0.word, $0) }, uniquingKeysWith: { first, _ in first })

        var known = 0, learning = 0, new = 0
        for entry in entries {
            switch savedByWord[entry.token.text] {
            case nil: new += 1
            case let word? where word.isMastered: known += 1
            default: learning += 1
            }
        }

        let top = entries
            .filter { savedByWord[$0.token.text]?.isMastered != true }
            .sorted { a, b in
                a.count != b.count ? a.count > b.count : a.token.text < b.token.text
            }
            .prefix(maxTopWords)
        let unsaved = Set(top.filter { savedByWord[$0.token.text] == nil }.map(\.token.text))

        return SessionSummary(
            alreadyKnown: known,
            learning: learning,
            newWords: new,
            topWords: Array(top),
            unsavedTopWords: unsaved
        )
    }
}
