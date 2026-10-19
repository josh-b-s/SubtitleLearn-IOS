import Foundation

/// The lines on the progress chart.
enum ProgressSeries: String, CaseIterable, Identifiable {
    case learned = "Learned"
    case saved = "Saved"
    case mastered = "Mastered"

    var id: String { rawValue }
    var label: String { rawValue }
}
