import SwiftUI
import SwiftData

/// Rebuilds the reminders on launch and each time the app comes forward or goes away,
/// so the counts follow the latest quiz results.
private struct ReminderRefreshModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext

    func body(content: Content) -> some View {
        content.onChange(of: scenePhase, initial: true) { _, phase in
            guard phase != .inactive else { return }
            Task {
                // A missed refresh only leaves an older plan in place, so there is nothing to show the user.
                try? await ReviewReminderScheduler.refresh(context: modelContext)
            }
        }
    }
}

extension View {
    func refreshesReviewReminders() -> some View {
        modifier(ReminderRefreshModifier())
    }
}
