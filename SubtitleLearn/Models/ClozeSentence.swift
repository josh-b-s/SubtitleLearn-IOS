import Foundation

/// One Gemini-written example sentence for a word, cached on device.
struct ClozeSentence: Codable, Equatable {
    let word: String
    let sentence: String
    let translation: String

    /// Cheap checks before trusting Gemini: short, translated, word appears exactly once.
    var isUsable: Bool {
        !word.isEmpty
            && !translation.isEmpty
            && sentence.count <= 20
            && sentence.components(separatedBy: word).count == 2
    }
}
