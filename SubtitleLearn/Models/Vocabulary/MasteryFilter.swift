import Foundation

/// Vocabulary filter chips. Unlike MasteryStatus, levels 2 and 3 are separate.
enum MasteryFilter: String, CaseIterable, Identifiable {
    case new = "New"
    case level2 = "Level 2"
    case level3 = "Level 3"
    case mastered = "Mastered"

    var id: String { rawValue }

    func matches(level: Int) -> Bool {
        switch self {
        case .new: level <= 1
        case .level2: level == 2
        case .level3: level == 3
        case .mastered: Mastery.isMastered(level)
        }
    }
}
