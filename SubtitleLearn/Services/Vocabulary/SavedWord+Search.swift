import Foundation

extension SavedWord {
    /// Matches word, pinyin or meaning. Pinyin ignores case and tone marks, so "xihuan" finds "xǐhuān".
    func matches(_ query: String) -> Bool {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return true }
        let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        return word.contains(q)
            || pinyin.range(of: q, options: options) != nil
            || meanings.contains { $0.range(of: q, options: options) != nil }
    }
}
