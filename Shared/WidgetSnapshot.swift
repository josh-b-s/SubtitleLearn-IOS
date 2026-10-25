import Foundation

/// What the home screen widget shows. The app writes it and the widget reads it, through a file in the App Group.
/// Add this file to BOTH the app and the widget targets.
struct WidgetSnapshot: Codable, Equatable {
    /// How many days of due counts are stored.
    static let daysAhead = 7

    /// Start of the day the snapshot was made.
    var day: Date
    /// Words due on `day` plus the index, assuming no reviews in between.
    var dueCounts: [Int]
    var streak: Int
    /// Last day the streak still counts if the user does not review again.
    var streakLastDay: Date

    func dueCount(on date: Date, calendar: Calendar = .current) -> Int {
        guard !dueCounts.isEmpty else { return 0 }
        let offset = calendar.dateComponents([.day], from: day, to: calendar.startOfDay(for: date)).day ?? 0
        return dueCounts[min(max(offset, 0), dueCounts.count - 1)]
    }

    func streak(on date: Date, calendar: Calendar = .current) -> Int {
        calendar.startOfDay(for: date) <= streakLastDay ? streak : 0
    }

    // MARK: - Storage

    private static var fileURL: URL? {
        BroadcastShared.containerURL?.appendingPathComponent("widget-snapshot.json")
    }

    /// Nil before the app has written one.
    static func load() -> WidgetSnapshot? {
        guard let fileURL, let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }

    func save() throws {
        guard let fileURL = Self.fileURL else { return }
        try JSONEncoder().encode(self).write(to: fileURL, options: .atomic)
    }
}
