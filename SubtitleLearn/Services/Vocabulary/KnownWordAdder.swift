import Foundation
import SwiftData

/// Adds a dictionary word straight into Vocabulary at a chosen mastery score.
enum KnownWordAdder {
    /// Updates `existing` if the word is already saved. Levels 2 and 3 also get a review so the
    /// word isn't quizzed immediately. Mastered words are never quizzed.
    static func add(_ match: DictionaryMatch, progress: Double, existing: SavedWord?, into context: ModelContext) {
        let word = existing ?? SavedWord(word: match.word, pinyin: match.entry.pinyin, meanings: match.entry.meanings)
        if existing == nil { context.insert(word) }

        word.setProgress(progress)
        switch word.level {
        case 2: word.review(quality: 3)
        case 3: word.review(quality: 4)
        default: break
        }
        try? context.save()
    }
}
