import Foundation

/// Shown after each answer.
struct QuizFeedback {
    let correct: Bool
    let answerText: String
    let explanation: String  // one line on why the answer is right, shown after a correct answer
    let levelNote: String?   // set when the word moved level on this answer
}
