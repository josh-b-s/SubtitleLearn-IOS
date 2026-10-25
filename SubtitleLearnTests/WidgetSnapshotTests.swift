import Foundation
import Testing
@testable import SubtitleLearn

struct WidgetSnapshotTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()
    private let now = Date(timeIntervalSince1970: 1_792_324_800) // 2026-10-18 12:00 UTC

    private func days(_ count: Int) -> Date {
        calendar.date(byAdding: .day, value: count, to: now)!
    }

    private func word(_ name: String, dueIn count: Int, level: Int = 1) -> SavedWord {
        let word = SavedWord(word: name, pinyin: "", meanings: [])
        word.dueDate = days(count)
        word.level = level
        return word
    }

    private func build(words: [SavedWord] = [], logs: [ReviewLog] = []) -> WidgetSnapshot {
        WidgetSnapshotBuilder.build(words: words, logs: logs, now: now, calendar: calendar)
    }

    @Test func dueCountsGrowAsWordsFallDue() {
        let snapshot = build(words: [word("a", dueIn: -2), word("b", dueIn: 1)])
        #expect(snapshot.dueCounts.prefix(3) == [1, 2, 2])
    }

    @Test func masteredWordsAreNotCounted() {
        let snapshot = build(words: [word("a", dueIn: -1, level: Mastery.masteredLevel)])
        #expect(snapshot.dueCounts.allSatisfy { $0 == 0 })
    }

    @Test func countClampsToTheStoredRange() {
        let snapshot = build(words: [word("a", dueIn: 1)])
        #expect(snapshot.dueCount(on: days(30), calendar: calendar) == 1)
        #expect(snapshot.dueCount(on: days(-5), calendar: calendar) == 0)
    }

    @Test func streakSurvivesTomorrowOnlyIfReviewedToday() {
        let reviewed = [ReviewLog(word: "a", correct: true, date: now), ReviewLog(word: "a", correct: true, date: days(-1))]
        let withToday = build(logs: reviewed)
        #expect(withToday.streak(on: days(1), calendar: calendar) == 2)
        #expect(withToday.streak(on: days(2), calendar: calendar) == 0)

        let withoutToday = build(logs: [ReviewLog(word: "a", correct: true, date: days(-1))])
        #expect(withoutToday.streak(on: now, calendar: calendar) == 1)
        #expect(withoutToday.streak(on: days(1), calendar: calendar) == 0)
    }
}
