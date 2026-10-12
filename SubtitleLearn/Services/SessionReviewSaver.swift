import Foundation
import SwiftData

/// Saves the session's unsaved top words so the quiz can ask about them.
enum SessionReviewSaver {
    static func saveUnsaved(from summary: SessionSummary, into context: ModelContext) {
        for entry in summary.topWords where summary.unsavedTopWords.contains(entry.token.text) {
            context.insert(SavedWord(word: entry.token.text, pinyin: entry.token.pinyin, meanings: entry.token.meanings))
        }
        try? context.save()
    }
}
