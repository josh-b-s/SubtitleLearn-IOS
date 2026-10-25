import Foundation
import SwiftData
import UserNotifications

/// Keeps the pending review reminders in step with the saved words and the reminder settings.
enum ReviewReminderScheduler {
    private static let idPrefix = "review-reminder-"

    /// False when the user declines, or declined earlier (iOS then skips the prompt).
    static func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) ?? false
    }

    /// Replaces every pending reminder with a fresh plan, or just clears them when reminders are off.
    @MainActor
    static func refresh(context: ModelContext, settings: AppSettings = .shared) async throws {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        center.removePendingNotificationRequests(
            withIdentifiers: pending.map(\.identifier).filter { $0.hasPrefix(idPrefix) }
        )
        guard settings.reminderEnabled else { return }

        let words = try context.fetch(FetchDescriptor<SavedWord>())
        let plan = ReminderPlanner.plan(
            dueDates: words.filter { !$0.isMastered }.map(\.dueDate),
            minutesAfterMidnight: settings.reminderMinutes
        )
        for reminder in plan {
            try await center.add(request(for: reminder))
        }
    }

    private static func request(for reminder: ReminderPlanner.Reminder) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "Time to review"
        content.body = "\(reminder.dueCount) word\(reminder.dueCount == 1 ? "" : "s") due for review."
        content.sound = .default

        let parts = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.fireDate)
        return UNNotificationRequest(
            identifier: idPrefix + String(Int(reminder.fireDate.timeIntervalSince1970)),
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
        )
    }
}
