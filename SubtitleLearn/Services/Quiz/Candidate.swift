import Foundation

/// A word as quiz material: a saved word or a dictionary entry used as a wrong option.
struct Candidate {
    let word: String
    let pinyin: String
    let meanings: [String]

    /// Meaning as shown on answer buttons.
    var meaningText: String { meanings.prefix(2).joined(separator: " · ") }
}

extension Candidate {
    init(_ saved: SavedWord) {
        self.init(word: saved.word, pinyin: saved.pinyin, meanings: saved.meanings)
    }
}
