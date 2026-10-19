import Foundation

/// The user's own dictionary words, kept in UserDefaults as JSON.
enum CustomDictionaryStore {
    private static let key = "customDictionaryEntries"

    static func load() -> [String: DictionaryEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let entries = try? JSONDecoder().decode([String: DictionaryEntry].self, from: data)
        else { return [:] }
        return entries
    }

    /// Adds or overwrites a word. Blank pinyin is filled in automatically.
    static func add(word: String, pinyin: String, meaning: String) {
        let meanings = parseMeanings(meaning)
        guard !word.isEmpty, !meanings.isEmpty else { return }

        let typedPinyin = pinyin.replacingOccurrences(of: " ", with: "").trimmingCharacters(in: .whitespaces)
        let finalPinyin = typedPinyin.isEmpty ? ChineseDictionary.fallbackPinyin(word) : typedPinyin

        var all = load()
        all[word] = DictionaryEntry(pinyin: finalPinyin, meanings: meanings)
        if let data = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    /// Splits on / ; , (also the Chinese ones), lowercases, keeps at most 3.
    static func parseMeanings(_ text: String) -> [String] {
        text.split(whereSeparator: { "/;,，；、".contains($0) })
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            .filter { !$0.isEmpty }
            .prefix(ChineseDictionary.maxMeanings)
            .map { $0 }
    }
}
