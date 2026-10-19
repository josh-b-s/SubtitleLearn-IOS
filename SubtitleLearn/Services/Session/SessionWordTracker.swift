import Foundation

/// Counts the words heard during one screen share session.
@MainActor
final class SessionWordTracker {
    private var counts: [String: SessionEntry] = [:]
    private var pending: [WordToken] = []

    var entries: [SessionEntry] { Array(counts.values) }

    /// Each partial replaces the last, so only a final result is counted.
    func update(_ tokens: [WordToken], isFinal: Bool) {
        pending = tokens
        if isFinal { commitPending() }
    }

    /// Counts an unfinished last utterance. Call when the session ends.
    func flush() { commitPending() }

    func reset() {
        counts = [:]
        pending = []
    }

    /// Words with no dictionary meaning are skipped, they can't be quizzed.
    private func commitPending() {
        for token in pending where !token.meanings.isEmpty {
            counts[token.text, default: SessionEntry(token: token, count: 0)].count += 1
        }
        pending = []
    }
}
