import Foundation

/// What the summary screen shows after a session.
struct SessionSummary: Identifiable {
    let id = UUID()
    let alreadyKnown: Int
    let learning: Int
    let newWords: Int
    /// Most heard words that are not mastered, most heard first.
    let topWords: [SessionEntry]
    /// Subset of `topWords` not saved yet. Saved before the review starts.
    let unsavedTopWords: Set<String>

    var total: Int { alreadyKnown + learning + newWords }
}
