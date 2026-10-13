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
        let retention = inPeriod.isEmpty ? nil : Double(inPeriod.filter(\.correct).count) / Double(inPeriod.count)

        let weekly = weeklyLearned(logs: logs, today: today, calendar: calendar)

        return StatsSnapshot(
            wordsSaved: saved.count,
            masteredCount: saved.filter(\.isMastered).count,
            streak: streak(logs: logs, today: today, calendar: calendar),
            reviews: inPeriod.count,
            retention: retention,
            dailyCounts: dailyCounts(logs: logs, today: today, calendar: calendar),
            weekly: weekly.series,
            learnedTotal: weekly.total
        )
    }

    /// Consecutive days with a review. A day with no review yet today doesn't break the streak.
    private static func streak(logs: [ReviewLog], today: Date, calendar: Calendar) -> Int {
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

    /// A word counts as learned on the day of its first correct answer.
    private static func weeklyLearned(
        logs: [ReviewLog],
        today: Date,
        calendar: Calendar
    ) -> (series: [WeeklyLearned], total: Int) {
        var firstCorrect: [String: Date] = [:]
        for log in logs where log.correct {
            if let existing = firstCorrect[log.word], existing <= log.date { continue }
            firstCorrect[log.word] = log.date
        }

        guard let thisWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start,
              let firstWeek = calendar.date(byAdding: .weekOfYear, value: -(chartWeeks - 1), to: thisWeek)
        else { return ([], firstCorrect.count) }

        var running = firstCorrect.values.filter { $0 < firstWeek }.count
        var series: [WeeklyLearned] = []
        for offset in 0..<chartWeeks {
            guard let start = calendar.date(byAdding: .weekOfYear, value: offset, to: firstWeek),
                  let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start)
            else { continue }
            let gained = firstCorrect.values.filter { $0 >= start && $0 < end }.count
            running += gained
            series.append(WeeklyLearned(weekStart: start, gained: gained, total: running))
        }
        return (series, firstCorrect.count)
    }
}
