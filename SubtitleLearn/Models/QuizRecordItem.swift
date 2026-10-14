import Foundation

/// One question as it was asked, with the right answer and whether the first try got it.
struct QuizRecordItem: Codable, Hashable {
    let prompt: String
    let answer: String
    let correct: Bool
}
