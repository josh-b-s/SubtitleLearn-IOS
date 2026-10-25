import Foundation

/// Turns the review log and saved words into the numbers on the stats screen.
enum StatsCalculator {
    static let heatmapDays = 90
    static let chartWeeks = 12

    static func snapshot(
        logs: [ReviewLog],
        saved: [SavedWord],
        period: StatsPeriod,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> StatsSnapshot {
        let today = calendar.startOfDay(for: now)

        let inPeriod: [ReviewLog]
        if let days = period.days, let cutoff = calendar.date(byAdding: .day, value: -days, to: now) {
            inPeriod = logs.filter { $0.date >= cutoff }
        } else {
            inPeriod = logs
        }
        let correct = inPeriod.filter(\.correct).count

        return StatsSnapshot(
            streak: streak(logs: logs, today: today, calendar: calendar),
            reviews: inPeriod.count,
            correct: correct,
            dailyCounts: dailyCounts(logs: logs, today: today, calendar: calendar),
            weekly: weeklyProgress(logs: logs, saved: saved, today: today, calendar: calendar)
        )
    }

    /// Consecutive days with a review. A day with no review yet today doesn't break the streak.
    static func streak(logs: [ReviewLog], today: Date, calendar: Calendar) -> Int {
        let days = Set(logs.map { calendar.startOfDay(for: $0.date) })
        var day = today
        if !days.contains(day) { day = calendar.date(byAdding: .day, value: -1, to: day) ?? day }
        var count = 0
        while days.contains(day) {
            count += 1
            day = calendar.date(byAdding: .day, value: -1, to: day) ?? day
        }
        return count
    }

    private static func dailyCounts(logs: [ReviewLog], today: Date, calendar: Calendar) -> [Date: Int] {
        guard let start = calendar.date(byAdding: .day, value: -(heatmapDays - 1), to: today) else { return [:] }
        var counts: [Date: Int] = [:]
        for log in logs {
            let day = calendar.startOfDay(for: log.date)
            if day >= start { counts[day, default: 0] += 1 }
        }
        return counts
    }

    /// Running totals at the end of each of the last `chartWeeks` weeks. A word counts as learned
    /// on the day of its first correct answer, saved on the day it was added, mastered on `masteredDate`.
    private static func weeklyProgress(
        logs: [ReviewLog],
        saved: [SavedWord],
        today: Date,
        calendar: Calendar
    ) -> [WeeklyProgress] {
        var firstCorrect: [String: Date] = [:]
        for log in logs where log.correct {
            if let existing = firstCorrect[log.word], existing <= log.date { continue }
            firstCorrect[log.word] = log.date
        }
        let learnedDates = Array(firstCorrect.values)
        let savedDates = saved.map(\.dateAdded)
        // Words mastered before the date was tracked fall back to the day they were added.
        let masteredDates = saved.filter(\.isMastered).map { $0.masteredDate ?? $0.dateAdded }

        guard let thisWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start,
              let firstWeek = calendar.date(byAdding: .weekOfYear, value: -(chartWeeks - 1), to: thisWeek)
        else { return [] }

        return (0..<chartWeeks).compactMap { offset in
            guard let start = calendar.date(byAdding: .weekOfYear, value: offset, to: firstWeek),
                  let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start)
            else { return nil }
            return WeeklyProgress(
                weekStart: start,
                learned: learnedDates.filter { $0 < end }.count,
                saved: savedDates.filter { $0 < end }.count,
                mastered: masteredDates.filter { $0 < end }.count
            )
        }
    }
}
