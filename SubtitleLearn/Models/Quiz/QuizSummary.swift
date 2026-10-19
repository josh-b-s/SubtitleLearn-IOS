import Foundation

/// End-of-quiz totals. Retries are not counted, only first attempts.
struct QuizSummary {
    let attempted: Int
    let correctFirstTry: Int
    let leveledUp: Int
    let mastered: Int
}
