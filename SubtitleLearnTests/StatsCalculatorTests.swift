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

    @Test func emptyDataGivesZerosAndNoAccuracy() {
        let stats = snapshot([])
        #expect(stats.reviews == 0)
        #expect(stats.accuracy == nil)
        #expect(stats.streak == 0)
        #expect(stats.weekly.last?.learned == 0)
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

    // MARK: - Period and accuracy

    @Test func periodLimitsReviewsAndAccuracy() {
        let logs = [
            log(correct: true, daysAgo: 2),
            log(correct: false, daysAgo: 3),
            log(correct: false, daysAgo: 20)
        ]
        let week = snapshot(logs, period: .week)
        #expect(week.reviews == 2)
        #expect(week.correct == 1)
        #expect(week.accuracy == 0.5)

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
        #expect(stats.learnedThisWeek == 1)
        #expect(stats.weekly.count == StatsCalculator.chartWeeks)
        #expect(stats.weekly.last?.learned == 2)
    }

    // MARK: - Saved and mastered

    private func date(daysAgo: Int) -> Date {
        calendar.date(byAdding: .day, value: -daysAgo, to: now)!
    }

    @Test func savedAndMasteredAreRunningTotals() {
        let old = SavedWord(word: "a", pinyin: "", meanings: [], dateAdded: date(daysAgo: 200))
        let recent = SavedWord(word: "b", pinyin: "", meanings: [], dateAdded: date(daysAgo: 1))
        recent.level = Mastery.masteredLevel
        recent.masteredDate = date(daysAgo: 1)

        let weekly = snapshot([], saved: [old, recent]).weekly
        #expect(weekly.first?.saved == 1)
        #expect(weekly.first?.mastered == 0)
        #expect(weekly.last?.saved == 2)
        #expect(weekly.last?.mastered == 1)
    }

    @Test func masteredWithoutADateCountsFromTheDayItWasAdded() {
        let legacy = SavedWord(word: "a", pinyin: "", meanings: [], dateAdded: date(daysAgo: 200))
        legacy.level = Mastery.masteredLevel

        #expect(snapshot([], saved: [legacy]).weekly.first?.mastered == 1)
    }
}
