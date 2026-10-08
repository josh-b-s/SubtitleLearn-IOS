import Foundation

/// All grading is local exact match.
enum QuizGrader {
    static func isCorrect(_ question: QuizQuestion, answer: QuizAnswer) -> Bool {
        switch (question.kind, answer) {
        case (.choice(let q), .choice(let a)): a == q.answer
        case (.cloze(let q), .choice(let a)): a == q.answer
        case (.pair(let q), .pair(let pinyin, let meaning)): pinyin == q.pinyinAnswer && meaning == q.meaningAnswer
        default: false
        }
    }

    static func answerText(for question: QuizQuestion) -> String {
        switch question.kind {
        case .choice(let q): q.answer
        case .pair(let q): "\(q.pinyinAnswer) · \(q.meaningAnswer)"
        case .cloze(let q): q.answer
        }
    }
}
