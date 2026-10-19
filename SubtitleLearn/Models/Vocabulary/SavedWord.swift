import Foundation
import SwiftData

/// A vocabulary word the user saved from the Translate screen.
@Model
final class SavedWord {
    @Attribute(.unique) var word: String
    var pinyin: String
    var meanings: [String]
    var dateAdded: Date

    // Spaced repetition (SM-2)
    var repetitions: Int
    var easeFactor: Double
    var intervalDays: Int
    var dueDate: Date

    // Mastery: levels 1 to 3 are quizzed, 4 is mastered. Defaults let old stores migrate.
    var level: Int = 1
    var levelStreak: Int = 0
    /// When the word reached the mastered level. Nil if not mastered, or mastered before this was tracked.
    var masteredDate: Date?

    init(word: String, pinyin: String, meanings: [String], dateAdded: Date = .now) {
        self.word = word
        self.pinyin = pinyin
        self.meanings = meanings
        self.dateAdded = dateAdded
        self.repetitions = 0
        self.easeFactor = 2.5
        self.intervalDays = 0
        self.dueDate = dateAdded
    }
}
