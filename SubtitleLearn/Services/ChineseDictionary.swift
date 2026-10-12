import Foundation

struct DictionaryEntry: Sendable, Hashable, Codable {
    let pinyin: String
    let meanings: [String]
}

/// One word shown as a card in the interactive breakdown.
struct WordToken: Identifiable, Hashable {
    let id: Int              // position in the sentence, so repeated words still get unique ids
    let text: String
    let pinyin: String
    let meanings: [String]   // at most 3
    var hideMeaning = false  // set for words the learner has outgrown
    var hidePinyin = false

    func reindexed(_ id: Int) -> WordToken {
        WordToken(id: id, text: text, pinyin: pinyin, meanings: meanings,
                  hideMeaning: hideMeaning, hidePinyin: hidePinyin)
    }
}

/// Bundled zh-en.tsv dictionary plus greedy longest-match segmentation
/// (same approach as the Android version's Dictionary.segment).
struct ChineseDictionary: Sendable {
    private let entries: [String: DictionaryEntry]
    private let custom: [String: DictionaryEntry]   // user-added words, win over bundled ones
    private let maxWordLength = 6
    static let maxMeanings = 3

    init(entries: [String: DictionaryEntry], custom: [String: DictionaryEntry] = [:]) {
        self.entries = entries
        self.custom = custom
    }

    /// Same bundled words with the user's custom words layered on top. Cheap, shares the big table.
    func withCustom(_ custom: [String: DictionaryEntry]) -> ChineseDictionary {
        ChineseDictionary(entries: entries, custom: custom)
    }

    private func lookup(_ word: String) -> DictionaryEntry? { custom[word] ?? entries[word] }

    /// Visits every word, custom ones first. `isCustom` is true for user-added words.
    func forEachEntry(_ body: (_ word: String, _ entry: DictionaryEntry, _ isCustom: Bool) -> Void) {
        for (word, entry) in custom { body(word, entry, true) }
        for (word, entry) in entries where custom[word] == nil { body(word, entry, false) }
    }

    /// Loads Resources/zh-en.tsv. Each line: word <TAB> meanings (slash separated) <TAB> pinyin
    /// Same rules as the Android loader: the first entry for a word wins, and meanings
    /// are shortened to at most 3. Call from a background task.
    static func loadBundled() throws -> ChineseDictionary {
        guard let url = Bundle.main.url(forResource: "zh-en", withExtension: "tsv") else {
            throw CocoaError(.fileNoSuchFile)
        }
        let text = try String(contentsOf: url, encoding: .utf8)
        var entries: [String: DictionaryEntry] = [:]
        entries.reserveCapacity(110_000)

        text.enumerateLines { line, _ in
            let parts = line.split(separator: "\t", omittingEmptySubsequences: false)
            guard parts.count >= 2 else { return }
            let word = parts[0].trimmingCharacters(in: .whitespaces)
            guard !word.isEmpty, entries[word] == nil else { return }
            let meanings = shortMeanings(String(parts[1]))
            guard !meanings.isEmpty else { return }
            let pinyin = parts.count > 2
                ? parts[2].replacingOccurrences(of: " ", with: "").trimmingCharacters(in: .whitespaces)
                : ""
            entries[word] = DictionaryEntry(pinyin: pinyin, meanings: meanings)
        }
        return ChineseDictionary(entries: entries)
    }

    private static let splitPattern = try! NSRegularExpression(pattern: "\\s*[/;|,·•]\\s*|\\s+-\\s+")
    private static let parenPattern = try! NSRegularExpression(pattern: "\\(.*?\\)")

    /// Port of Dictionary.shortMeaning: split, lowercase, drop "to ", drop (notes), dedupe, keep 3.
    static func shortMeanings(_ definition: String) -> [String] {
        let range = NSRange(definition.startIndex..., in: definition)
        let marked = splitPattern.stringByReplacingMatches(in: definition, range: range, withTemplate: "\u{1F}")
        var seen = Set<String>()
        var result: [String] = []
        for piece in marked.split(separator: "\u{1F}") {
            var m = piece.trimmingCharacters(in: .whitespaces).lowercased()
            if m.hasPrefix("to ") { m.removeFirst(3) }
            m = parenPattern.stringByReplacingMatches(in: m, range: NSRange(m.startIndex..., in: m), withTemplate: "")
            m = m.split(whereSeparator: \.isWhitespace).joined(separator: " ")
            if m == "i" { m = "I" }
            guard !m.isEmpty, seen.insert(m).inserted else { continue }
            result.append(m)
            if result.count == maxMeanings { break }
        }
        return result
    }

    // MARK: - Segmentation

    func segment(_ text: String) -> [String] {
        let chars = Array(text)
        var words: [String] = []
        var i = 0
        while i < chars.count {
            // Skip spaces, punctuation, latin letters, digits, etc.
            guard chars[i].isHanCharacter else { i += 1; continue }

            let limit = min(maxWordLength, chars.count - i)
            var matched = 1
            if limit >= 2 {
                for length in stride(from: limit, through: 2, by: -1) {
                    let slice = chars[i ..< i + length]
                    if slice.allSatisfy(\.isHanCharacter), lookup(String(slice)) != nil {
                        matched = length
                        break
                    }
                }
            }
            words.append(String(chars[i ..< i + matched]))
            i += matched
        }
        return words
    }

    // MARK: - Sampling

    /// Random all-Han entries with exactly `length` characters, for quiz wrong options.
    func sample(count: Int, length: Int) -> [(word: String, entry: DictionaryEntry)] {
        var result: [(word: String, entry: DictionaryEntry)] = []
        var seen = Set<String>()
        var attempts = 0
        while result.count < count, attempts < count * 60 {
            attempts += 1
            guard let pair = entries.randomElement(),
                  pair.key.count == length,
                  pair.key.allSatisfy(\.isHanCharacter),
                  seen.insert(pair.key).inserted
            else { continue }
            result.append((word: pair.key, entry: pair.value))
        }
        return result
    }

    // MARK: - Lookup

    func entry(for word: String) -> DictionaryEntry? { lookup(word) }

    func tokens(for text: String) -> [WordToken] {
        segment(text).enumerated().map { index, word in
            if let entry = lookup(word) {
                return WordToken(id: index, text: word, pinyin: entry.pinyin, meanings: entry.meanings)
            }
            // Not in the dictionary: still give pinyin using the system transliterator.
            return WordToken(id: index, text: word, pinyin: Self.fallbackPinyin(word), meanings: [])
        }
    }

    static func fallbackPinyin(_ word: String) -> String {
        (word.applyingTransform(.mandarinToLatin, reverse: false) ?? "")
            .replacingOccurrences(of: " ", with: "")
    }
}

extension Character {
    var isHanCharacter: Bool {
        unicodeScalars.contains { $0.properties.isIdeographic }
    }
}
