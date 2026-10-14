import Foundation
import SwiftData

/// One quiz run and the first-attempt result of each question in it. Shown in quiz history.
@Model
final class QuizRecord {
    var date: Date
    var items: [QuizRecordItem]

    var correctCount: Int { items.filter(\.correct).count }

    init(items: [QuizRecordItem] = [], date: Date = .now) {
        self.items = items
        self.date = date
    }
}
