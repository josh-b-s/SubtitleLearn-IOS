import Foundation

/// One week on the "words learned" chart.
struct WeeklyLearned: Identifiable {
    let weekStart: Date
    let gained: Int
    /// Running total of words learned up to the end of this week.
    let total: Int

    var id: Date { weekStart }
}

/// Everything the stats screen displays.
struct StatsSnapshot {
    let wordsSaved: Int
    let masteredCount: Int
    let streak: Int
    /// Both are for the selected period.
    let reviews: Int
    let retention: Double?
    /// Reviews per day (keyed by start of day) for the heatmap window.
    let dailyCounts: [Date: Int]
    let weekly: [WeeklyLearned]
    let learnedTotal: Int

    var learnedThisWeek: Int { weekly.last?.gained ?? 0 }

    var masteredFraction: Double {
        wordsSaved == 0 ? 0 : Double(masteredCount) / Double(wordsSaved)
    }
}
