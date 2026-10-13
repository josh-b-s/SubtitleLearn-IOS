import Foundation

/// Window for the reviews and retention numbers.
enum StatsPeriod: String, CaseIterable, Identifiable {
    case week, month, all

    var id: String { rawValue }

    var label: String {
        switch self {
        case .week: "7 days"
        case .month: "30 days"
        case .all: "All time"
        }
    }

    /// Nil means no cutoff.
    var days: Int? {
        switch self {
        case .week: 7
        case .month: 30
        case .all: nil
        }
    }
}
