import Foundation
import SwiftData

/// A vocabulary word the user saved from the Translate screen.
/// The spaced-repetition fields are unused until Stage 4 but are included now
/// so the schema doesn't need migrating later.
@Model
final class SavedWord {
    @Attribute(.unique) var word: String
    var pinyin: String
    var meanings: [String]
    var dateAdded: Date

    // Spaced repetition (Stage 4)
    var repetitions: Int
    var easeFactor: Double
    var intervalDays: Int
    var dueDate: Date

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
