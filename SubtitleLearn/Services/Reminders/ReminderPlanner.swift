import Foundation

/// Works out which days get a review reminder and how many words each one mentions.
enum ReminderPlanner {
    struct Reminder: Equatable {
        let fireDate: Date
        let dueCount: Int
    }

    /// iOS keeps at most 64 pending notifications, so plan a fortnight ahead and top up whenever the app opens or closes.
    static let horizonDays = 14

    /// `dueDates` belong to words still being learned. As in `SavedWord.isDue`, a word counts for a day
    /// once it is due by the end of that day. Days with nothing due, and times already past, get no reminder.
    static func plan(
        dueDates: [Date],
        minutesAfterMidnight: Int,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [Reminder] {
        let today = calendar.startOfDay(for: now)
        return (0..<horizonDays).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: today),
                  let nextDay = calendar.date(byAdding: .day, value: 1, to: day),
                  let fireDate = calendar.date(
                    bySettingHour: minutesAfterMidnight / 60,
                    minute: minutesAfterMidnight % 60,
                    second: 0,
                    of: day
                  ),
                  fireDate > now
            else { return nil }
            let count = dueDates.filter { $0 <= nextDay }.count
            return count > 0 ? Reminder(fireDate: fireDate, dueCount: count) : nil
        }
    }
}
