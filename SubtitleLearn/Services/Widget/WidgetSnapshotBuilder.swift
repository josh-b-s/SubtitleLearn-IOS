import Foundation

/// Turns the saved words and review log into the numbers the widget shows.
enum WidgetSnapshotBuilder {
    static func build(
        words: [SavedWord],
        logs: [ReviewLog],
        now: Date = .now,
        calendar: Calendar = .current
    ) -> WidgetSnapshot {
        let today = calendar.startOfDay(for: now)

        // Same rule as SavedWord.isDue: due by the end of the day.
        let dueDates = words.filter { !$0.isMastered }.map(\.dueDate)
        let dueCounts = (0..<WidgetSnapshot.daysAhead).map { offset in
            let endOfDay = calendar.date(byAdding: .day, value: offset + 1, to: today) ?? today
            return dueDates.filter { $0 <= endOfDay }.count
        }

        // A streak survives one day without a review, so it lasts through tomorrow only if today already has one.
        let reviewedToday = logs.contains { calendar.isDate($0.date, inSameDayAs: now) }
        let streakLastDay = calendar.date(byAdding: .day, value: reviewedToday ? 1 : 0, to: today) ?? today

        return WidgetSnapshot(
            day: today,
            dueCounts: dueCounts,
            streak: StatsCalculator.streak(logs: logs, today: today, calendar: calendar),
            streakLastDay: streakLastDay
        )
    }
}
