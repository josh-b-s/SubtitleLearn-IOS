import Foundation

/// Three-way grouping of levels used by the Vocabulary row dots.
enum MasteryStatus: String, CaseIterable, Identifiable {
    case new = "New"
    case learning = "Learning"
    case mastered = "Mastered"

    var id: String { rawValue }

    init(level: Int) {
        switch level {
        case ...1: self = .new
        case 2, 3: self = .learning
        default: self = .mastered
        }
    }
}
