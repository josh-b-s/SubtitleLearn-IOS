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

    /// The question as a short line for history, with the blank shown for cloze.
    static func promptText(for question: QuizQuestion) -> String {
        switch question.kind {
        case .choice(let q): q.hint.isEmpty ? q.prompt : "\(q.prompt) (\(q.hint))"
        case .pair(let q): q.word
        case .cloze(let q): q.before.map(\.text).joined() + "___" + q.after.map(\.text).joined()
        }
    }

    static func explanation(for question: QuizQuestion) -> String {
        switch question.kind {
        case .choice(let q):
            q.direction == .chineseToEnglish ? "\(q.prompt) means \"\(q.answer)\"" : "\(q.answer) means \"\(q.prompt)\""
        case .pair(let q): "\(q.word) is \(q.pinyinAnswer), \"\(q.meaningAnswer)\""
        case .cloze(let q): "\(q.answer) fits the blank"
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
