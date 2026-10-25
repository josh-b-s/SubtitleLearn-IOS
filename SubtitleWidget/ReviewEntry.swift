import WidgetKit

struct ReviewEntry: TimelineEntry {
    let date: Date
    let dueCount: Int
    let streak: Int

    static let sample = ReviewEntry(date: .now, dueCount: 12, streak: 5)
}
