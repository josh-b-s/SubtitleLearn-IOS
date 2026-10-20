import Foundation

extension SavedWord {
    /// Matches word, pinyin or meaning. Pinyin ignores case, tone marks and spaces, so "xi huan" finds "xǐhuān".
    func matches(_ query: String) -> Bool {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return true }
        let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        let key = q.pinyinKey
        return word.contains(q)
            || (!key.isEmpty && pinyin.pinyinKey.contains(key))
            || meanings.contains { $0.range(of: q, options: options) != nil }
    }
}
