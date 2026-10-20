import Foundation

/// One column of answer options with its right answer.
struct QuizColumn {
    let title: String
    let choices: [String]
    let answer: String

    func shuffled() -> QuizColumn { QuizColumn(title: title, choices: choices.shuffled(), answer: answer) }
}
