#if DEBUG
import Foundation
import SwiftData

/// Debug only. Seeded rows use a "seed:" word prefix so they can be cleared without touching real reviews.
enum ReviewLogSeeder {
    private static let prefix = "seed:"

    /// 40 fake words, one starting to be learned every two days, reviewed now and then since. Each also gets a saved word, the oldest 12 mastered.
    static func seed(into context: ModelContext) {
        let calendar = Calendar.current
        for index in 0..<40 {
            let word = "\(prefix)\(index)"
            let firstDay = 80 - index * 2
            context.insert(savedWord(word, index: index, firstDay: firstDay, calendar: calendar))
            for daysAgo in stride(from: firstDay, through: 0, by: -1) {
                let isFirst = daysAgo == firstDay
                guard isFirst || Double.random(in: 0...1) < 0.25 else { continue }
                let date = calendar.date(byAdding: .day, value: -daysAgo, to: .now)?
                    .addingTimeInterval(Double.random(in: -36_000...0)) ?? .now
                context.insert(ReviewLog(word: word, correct: isFirst || Double.random(in: 0...1) < 0.82, date: date))
            }
        }
        for daysAgo in 0..<4 {
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now
            context.insert(ReviewLog(word: "\(prefix)0", correct: true, date: date))
        }
        try? context.save()
    }

    private static func savedWord(_ word: String, index: Int, firstDay: Int, calendar: Calendar) -> SavedWord {
        func day(_ daysAgo: Int) -> Date { calendar.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now }
        let saved = SavedWord(word: word, pinyin: "", meanings: [], dateAdded: day(firstDay))
        if index < 12 {
            saved.level = Mastery.masteredLevel
            saved.masteredDate = day(max(firstDay - 20, 0))
        } else {
            saved.level = 1 + index % 3
        }
        return saved
    }

    static func clear(from context: ModelContext) {
        let logs = (try? context.fetch(FetchDescriptor<ReviewLog>())) ?? []
        for log in logs where log.word.hasPrefix(prefix) { context.delete(log) }
        let words = (try? context.fetch(FetchDescriptor<SavedWord>())) ?? []
        for word in words where word.word.hasPrefix(prefix) { context.delete(word) }
        try? context.save()
    }
}
#endif
