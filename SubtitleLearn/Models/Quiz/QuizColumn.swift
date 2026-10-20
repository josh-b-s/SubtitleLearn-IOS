import Foundation

/// One column of answer options with its right answer.
struct QuizColumn {
    let title: String
    let choices: [String]
    let answer: String
    var spoken: [String: String] = [:]   // choice to the word the voice says when it's tapped; others stay silent

    func shuffled() -> QuizColumn { QuizColumn(title: title, choices: choices.shuffled(), answer: answer, spoken: spoken) }
}
