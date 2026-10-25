import WidgetKit

struct ReviewTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ReviewEntry { .sample }

    func getSnapshot(in context: Context, completion: @escaping (ReviewEntry) -> Void) {
        completion(context.isPreview ? .sample : entry(at: .now, from: WidgetSnapshot.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ReviewEntry>) -> Void) {
        let snapshot = WidgetSnapshot.load()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        // One entry now and one at each midnight, so the count and streak roll over while the app is closed.
        let midnights = (1..<WidgetSnapshot.daysAhead).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
        let entries = ([Date.now] + midnights).map { entry(at: $0, from: snapshot) }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func entry(at date: Date, from snapshot: WidgetSnapshot?) -> ReviewEntry {
        ReviewEntry(
            date: date,
            dueCount: snapshot?.dueCount(on: date) ?? 0,
            streak: snapshot?.streak(on: date) ?? 0
        )
    }
}
