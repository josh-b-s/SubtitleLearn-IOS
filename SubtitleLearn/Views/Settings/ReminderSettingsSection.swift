import SwiftUI

/// Settings section for the daily review reminder.
struct ReminderSettingsSection: View {
    @State private var settings = AppSettings.shared
    @State private var showPermissionAlert = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: settings.reminderMinutes / 60,
                    minute: settings.reminderMinutes % 60,
                    second: 0,
                    of: .now
                ) ?? .now
            },
            set: {
                let parts = Calendar.current.dateComponents([.hour, .minute], from: $0)
                settings.reminderMinutes = (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
            }
        )
    }

    var body: some View {
        Section {
            Toggle("Daily review reminder", isOn: $settings.reminderEnabled)
                .onChange(of: settings.reminderEnabled) { _, enabled in
                    Task { await reminderToggled(enabled) }
                }
                .onChange(of: settings.reminderMinutes) {
                    Task { try? await ReviewReminderScheduler.refresh(context: modelContext) }
                }
                .alert("Notifications are off", isPresented: $showPermissionAlert) {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Allow notifications for Subtitle Learn in iOS Settings to get review reminders.")
                }

            if settings.reminderEnabled {
                DatePicker("Time", selection: reminderTime, displayedComponents: .hourAndMinute)
            }
        } header: {
            Text("Reminders")
        } footer: {
            Text("Sends a notification at this time on days when words are due for review. Turning it on asks for permission to send notifications.")
        }
    }

    private func reminderToggled(_ enabled: Bool) async {
        if enabled {
            let granted = await ReviewReminderScheduler.requestAuthorization()
            if !granted {
                settings.reminderEnabled = false
                showPermissionAlert = true
                return
            }
        }
        try? await ReviewReminderScheduler.refresh(context: modelContext)
    }
}
