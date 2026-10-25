import SwiftUI
import SwiftData
import OSLog

private let logger = Logger(subsystem: "SubtitleLearn", category: "Widget")

/// Updates the widget on launch and each time the app comes forward or goes away,
/// so it shows the latest quiz results.
private struct WidgetRefreshModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext

    func body(content: Content) -> some View {
        content.onChange(of: scenePhase, initial: true) { _, phase in
            guard phase != .inactive else { return }
            do {
                try WidgetSnapshotWriter.update(context: modelContext)
            } catch {
                logger.error("Widget update failed: \(error.localizedDescription)")
            }
        }
    }
}

extension View {
    func refreshesWidget() -> some View {
        modifier(WidgetRefreshModifier())
    }
}
