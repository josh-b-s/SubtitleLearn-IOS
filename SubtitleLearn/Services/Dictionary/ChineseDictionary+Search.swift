import Foundation

/// A dictionary search hit.
struct DictionaryMatch: Identifiable, Hashable, Sendable {
    let word: String
    let entry: DictionaryEntry
    let isCustom: Bool

    var id: String { word }

    /// Lets a hit open the same detail sheet as a translated word.
    var token: WordToken {
        WordToken(id: 0, text: word, pinyin: entry.pinyin, meanings: entry.meanings)
    }
}

extension ChineseDictionary {
    /// Finds words by Chinese text or English meaning. Exact and prefix matches rank first,
    /// custom words win ties, then shorter words. Call from a background task.
    func search(_ query: String, limit: Int = 50) -> [DictionaryMatch] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }

        var hits: [(score: Int, match: DictionaryMatch)] = []
        forEachEntry { word, entry, isCustom in
            guard let score = Self.score(q, word: word, meanings: entry.meanings) else { return }
            hits.append((score, DictionaryMatch(word: word, entry: entry, isCustom: isCustom)))
        }

        hits.sort { a, b in
            if a.score != b.score { return a.score < b.score }
            if a.match.isCustom != b.match.isCustom { return a.match.isCustom }
            if a.match.word.count != b.match.word.count { return a.match.word.count < b.match.word.count }
            return a.match.word < b.match.word
        }
        return hits.prefix(limit).map(\.match)
    }

    /// Lower is better. Nil means no match.
    private static func score(_ q: String, word: String, meanings: [String]) -> Int? {
        if word == q { return 0 }
        if word.hasPrefix(q) { return 1 }
        if word.contains(q) { return 2 }
        if meanings.contains(q) { return 3 }
        if meanings.contains(where: { $0.hasPrefix(q) }) { return 4 }
        if meanings.contains(where: { $0.contains(q) }) { return 5 }
        return nil
    }
}
