import Foundation
import SwiftData

/// One first-attempt quiz answer. Feeds the stats screen.
@Model
final class ReviewLog {
    var date: Date
    var word: String
    var correct: Bool

    init(word: String, correct: Bool, date: Date = .now) {
        self.word = word
        self.correct = correct
        self.date = date
    }
}
