import Foundation

enum VocabularySort: String, CaseIterable, Identifiable {
    case newest = "Newest first"
    case oldest = "Oldest first"
    case dueSoonest = "Due soonest"
    case recentlyReviewed = "Recently reviewed"
    case mostMissed = "Most missed"
    case pinyin = "Pinyin A to Z"

    var id: String { rawValue }

    /// `logs` is only read by the review-based sorts.
    func sorted(_ words: [SavedWord], logs: [ReviewLog]) -> [SavedWord] {
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
        case .recentlyReviewed:
            let lastReviewed = Dictionary(logs.map { ($0.word, $0.date) }, uniquingKeysWith: max)
            return words.sorted { a, b in
                let (x, y) = (lastReviewed[a.word] ?? .distantPast, lastReviewed[b.word] ?? .distantPast)
                return x != y ? x > y : a.dateAdded > b.dateAdded
            }
        case .mostMissed:
            let misses = logs.filter { !$0.correct }.reduce(into: [String: Int]()) { $0[$1.word, default: 0] += 1 }
            return words.sorted { a, b in
                let (x, y) = (misses[a.word] ?? 0, misses[b.word] ?? 0)
                return x != y ? x > y : a.dateAdded > b.dateAdded
            }
        case .pinyin:
            return words.sorted {
                $0.pinyin.compare($1.pinyin, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedAscending
            }
        }
    }
}
