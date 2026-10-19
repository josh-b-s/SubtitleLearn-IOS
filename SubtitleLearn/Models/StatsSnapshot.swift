import Foundation

/// One week on the progress chart. Each count is a running total up to the end of that week.
struct WeeklyProgress: Identifiable {
    let weekStart: Date
    let learned: Int
    let saved: Int
    let mastered: Int

    var id: Date { weekStart }

    func value(for series: ProgressSeries) -> Int {
        switch series {
        case .learned: learned
        case .saved: saved
        case .mastered: mastered
        }
    }
}

/// Everything the stats screen displays.
struct StatsSnapshot {
    let streak: Int
    /// Both are for the selected period: first-try answers given and how many were right.
    let reviews: Int
    let correct: Int
    /// Reviews per day (keyed by start of day) for the heatmap window.
    let dailyCounts: [Date: Int]
    let weekly: [WeeklyProgress]

    var accuracy: Double? { reviews == 0 ? nil : Double(correct) / Double(reviews) }

    var learnedThisWeek: Int {
        guard let last = weekly.last else { return 0 }
        return last.learned - (weekly.dropLast().last?.learned ?? 0)
    }
}
