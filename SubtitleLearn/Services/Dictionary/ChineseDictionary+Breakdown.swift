import Foundation

/// One character of a multi-character word with its own pinyin and meaning.
struct CharGloss: Identifiable, Hashable {
    let id: Int
    let char: String
    let pinyin: String
    let meaning: String
}

extension ChineseDictionary {
    /// Per-character gloss for words of 2+ characters. Characters not in the dictionary are skipped.
    func breakdown(for word: String) -> [CharGloss] {
        guard word.count > 1 else { return [] }
        return word.enumerated().compactMap { index, character in
            let text = String(character)
            guard let entry = entry(for: text) else { return nil }
            return CharGloss(
                id: index,
                char: text,
                pinyin: entry.pinyin,
                meaning: entry.meanings.prefix(2).joined(separator: " / ")
            )
        }
    }
}
