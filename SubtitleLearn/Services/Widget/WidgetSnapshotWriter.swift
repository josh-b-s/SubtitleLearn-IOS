import SwiftData
import WidgetKit

/// Saves a fresh snapshot for the widget and asks WidgetKit to redraw it.
enum WidgetSnapshotWriter {
    @MainActor
    static func update(context: ModelContext) throws {
        let words = try context.fetch(FetchDescriptor<SavedWord>())
        let logs = try context.fetch(FetchDescriptor<ReviewLog>())
        try WidgetSnapshotBuilder.build(words: words, logs: logs).save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
