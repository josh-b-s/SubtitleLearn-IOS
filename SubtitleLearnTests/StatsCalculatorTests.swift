import Foundation
import Testing
@testable import SubtitleLearn

struct StatsCalculatorTests {
    // Fixed clock and calendar so results don't depend on the device or the day the tests run.
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        return calendar
    }()
    private let now = Date(timeIntervalSince1970: 1_792_324_800) // 2026-10-18 12:00 UTC, a Sunday

    private func log(_ word: String = "w", correct: Bool = true, daysAgo: Int) -> ReviewLog {
        ReviewLog(word: word, correct: correct, date: calendar.date(byAdding: .day, value: -daysAgo, to: now)!)
    }

    private func snapshot(
        _ logs: [ReviewLog],
        saved: [SavedWord] = [],
        period: StatsPeriod = .all
    ) -> StatsSnapshot {
        StatsCalculator.snapshot(logs: logs, saved: saved, period: period, now: now, calendar: calendar)
    }

    @Test func emptyDataGivesZerosAndNoRetention() {
        let stats = snapshot([])
        #expect(stats.reviews == 0)
        #expect(stats.retention == nil)
        #expect(stats.streak == 0)
        #expect(stats.masteredFraction == 0)
        #expect(stats.learnedTotal == 0)
    }

    // MARK: - Streak

    @Test func streakCountsConsecutiveDaysIncludingToday() {
        #expect(snapshot([log(daysAgo: 0), log(daysAgo: 1), log(daysAgo: 2)]).streak == 3)
    }

    @Test func streakSurvivesADayWithNoReviewYet() {
        #expect(snapshot([log(daysAgo: 1), log(daysAgo: 2)]).streak == 2)
    }

    @Test func gapEndsTheStreak() {
        #expect(snapshot([log(daysAgo: 0), log(daysAgo: 2)]).streak == 1)
    }

    @Test func streakIsZeroAfterTwoMissedDays() {
        #expect(snapshot([log(daysAgo: 2), log(daysAgo: 3)]).streak == 0)
    }

    // MARK: - Period and retention

    @Test func periodLimitsReviewsAndRetention() {
        let logs = [
            log(correct: true, daysAgo: 2),
            log(correct: false, daysAgo: 3),
            log(correct: false, daysAgo: 20)
        ]
        let week = snapshot(logs, period: .week)
        #expect(week.reviews == 2)
        #expect(week.retention == 0.5)

        #expect(snapshot(logs, period: .month).reviews == 3)
        #expect(snapshot(logs, period: .all).reviews == 3)
    }

    // MARK: - Heatmap

    @Test func dailyCountsGroupBySameDay() {
        let stats = snapshot([log(daysAgo: 1), log(daysAgo: 1), log(daysAgo: 0)])
        let yesterday = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -1, to: now)!)
        #expect(stats.dailyCounts[yesterday] == 2)
    }

    @Test func dailyCountsIgnoreReviewsOlderThanTheWindow() {
        #expect(snapshot([log(daysAgo: StatsCalculator.heatmapDays + 5)]).dailyCounts.isEmpty)
    }

    // MARK: - Words learned

    @Test func wordCountsAsLearnedOnlyOnceAndOnlyWhenCorrect() {
        let logs = [
            log("a", correct: true, daysAgo: 10),
            log("a", correct: true, daysAgo: 1),
            log("b", correct: false, daysAgo: 1),
            log("c", correct: true, daysAgo: 1)
        ]
        let stats = snapshot(logs)
        #expect(stats.learnedTotal == 2)
        #expect(stats.learnedThisWeek == 1)
        #expect(stats.weekly.count == StatsCalculator.chartWeeks)
        #expect(stats.weekly.last?.total == 2)
    }

    @Test func masteredFractionUsesSavedWords() {
        let saved = (0..<4).map { SavedWord(word: "w\($0)", pinyin: "", meanings: []) }
        saved[0].level = Mastery.masteredLevel
        let stats = snapshot([], saved: saved)
        #expect(stats.wordsSaved == 4)
        #expect(stats.masteredCount == 1)
        #expect(stats.masteredFraction == 0.25)
    }
}
