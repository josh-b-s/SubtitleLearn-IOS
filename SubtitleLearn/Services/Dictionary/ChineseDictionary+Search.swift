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
    /// Finds words by Chinese text, pinyin or English meaning. Exact and prefix matches rank first,
    /// custom words win ties, then shorter words. Call from a background task.
    func search(_ query: String, limit: Int = 50) -> [DictionaryMatch] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }

        let key = q.pinyinKey
        let pinyinQuery = key.allSatisfy { $0.isASCII && $0.isLetter } ? key : nil

        var hits: [(score: Int, match: DictionaryMatch)] = []
        forEachEntry { word, entry, isCustom, pinyinKey in
            guard let score = Self.score(q, pinyinQuery: pinyinQuery, word: word, pinyinKey: pinyinKey, meanings: entry.meanings)
            else { return }
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

    /// Lower is better. Nil means no match. Pinyin sits between exact and partial English matches,
    /// because short syllables like "he" are also English words.
    private static func score(_ q: String, pinyinQuery: String?, word: String, pinyinKey: String, meanings: [String]) -> Int? {
        if word == q { return 0 }
        if word.hasPrefix(q) { return 1 }
        if word.contains(q) { return 2 }
        if meanings.contains(q) { return 3 }
        if let pinyinQuery {
            if pinyinKey == pinyinQuery { return 4 }
            if pinyinKey.hasPrefix(pinyinQuery) { return 5 }
        }
        if meanings.contains(where: { $0.hasPrefix(q) }) { return 6 }
        if meanings.contains(where: { $0.contains(q) }) { return 7 }
        return nil
    }
}
