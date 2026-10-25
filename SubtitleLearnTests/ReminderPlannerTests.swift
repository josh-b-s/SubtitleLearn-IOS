import Foundation
import Testing
@testable import SubtitleLearn

struct ReminderPlannerTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()
    private let now = Date(timeIntervalSince1970: 1_792_324_800) // 2026-10-18 12:00 UTC
    private let evening = 19 * 60

    private func plan(_ dueDates: [Date], minutes: Int? = nil) -> [ReminderPlanner.Reminder] {
        ReminderPlanner.plan(dueDates: dueDates, minutesAfterMidnight: minutes ?? evening, now: now, calendar: calendar)
    }

    private func days(_ count: Int) -> Date {
        calendar.date(byAdding: .day, value: count, to: now)!
    }

    @Test func nothingDueGivesNoReminders() {
        #expect(plan([]).isEmpty)
    }

    @Test func overdueWordsRemindEveryDayInTheHorizon() {
        let reminders = plan([days(-3)])
        #expect(reminders.count == ReminderPlanner.horizonDays)
        let first = calendar.dateComponents([.day, .hour, .minute], from: reminders[0].fireDate)
        #expect(first.day == 18 && first.hour == 19 && first.minute == 0)
    }

    @Test func countGrowsAsMoreWordsFallDue() {
        let reminders = plan([days(-1), days(1)])
        #expect(reminders[0].dueCount == 1)
        #expect(reminders[1].dueCount == 2)
    }

    @Test func daysBeforeAnyWordIsDueAreSkipped() {
        let reminders = plan([days(3)])
        let first = calendar.dateComponents([.day], from: reminders[0].fireDate)
        #expect(first.day == 21)
    }

    @Test func todayIsSkippedOnceTheTimeHasPassed() {
        let reminders = plan([days(-1)], minutes: 8 * 60)
        let first = calendar.dateComponents([.day, .hour], from: reminders[0].fireDate)
        #expect(first.day == 19 && first.hour == 8)
    }
}
