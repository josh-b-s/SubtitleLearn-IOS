import Foundation

enum VocabularySort: String, CaseIterable, Identifiable {
    case newest = "Newest first"
    case oldest = "Oldest first"
    case dueSoonest = "Due soonest"
    case pinyin = "Pinyin A to Z"

    var id: String { rawValue }

    func sorted(_ words: [SavedWord]) -> [SavedWord] {
        switch self {
        case .newest:
            return words.sorted { $0.dateAdded > $1.dateAdded }
        case .oldest:
            return words.sorted { $0.dateAdded < $1.dateAdded }
        case .dueSoonest:
            // Mastered words aren't quizzed, so their stale due dates would otherwise lead the list.
            return words.sorted { a, b in
                if a.isMastered != b.isMastered { return !a.isMastered }
                return a.dueDate < b.dueDate
            }
        case .pinyin:
            return words.sorted {
                $0.pinyin.compare($1.pinyin, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedAscending
            }
        }
    }
}
