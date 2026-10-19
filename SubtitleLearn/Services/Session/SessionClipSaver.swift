import Foundation

/// Decides which of a session's clips are worth keeping: level 1 words only.
enum SessionClipSaver {
    /// Keeps clips for saved level 1 words plus the session's unsaved top words, which the
    /// Review button saves at level 1. Clips for words that moved up or were removed are deleted.
    static func save(_ session: SessionResult, summary: SessionSummary, saved: [SavedWord]) {
        let levelOne = Set(saved.filter { $0.level == 1 }.map(\.word))
        AudioClipStore.sync(
            newClips: session.clips,
            keeping: levelOne.union(summary.unsavedTopWords),
            sampleRate: Int(BroadcastShared.sampleRate)
        )
    }
}
