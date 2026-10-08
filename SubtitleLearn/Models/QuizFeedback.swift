import Foundation

/// Shown after each answer.
struct QuizFeedback {
    let correct: Bool
    let answerText: String
    let levelNote: String?   // set when the word moved level on this answer
}
