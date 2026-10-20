import Foundation

/// All grading is local exact match.
enum QuizGrader {
    static func isCorrect(_ question: QuizQuestion, answer: QuizAnswer) -> Bool {
        switch (question.kind, answer) {
        case (.choice(let q), .choice(let a)): a == q.answer
        case (.cloze(let q), .cloze(let word, let pinyin, let meaning)):
            word == q.answer && pinyin == q.pinyin.answer && meaning == q.meaning.answer
        case (.pair(let q), .pair(let pinyin, let second)): pinyin == q.pinyin.answer && second == q.second.answer
        default: false
        }
    }

    /// The question as a short line for history, with the blank shown for cloze.
    static func promptText(for question: QuizQuestion) -> String {
        switch question.kind {
        case .choice(let q): q.hint.isEmpty ? q.prompt : "\(q.prompt) (\(q.hint))"
        case .pair(let q): q.prompt == .meaning ? q.meaning : q.word
        case .cloze(let q): q.before.map(\.text).joined() + "___" + q.after.map(\.text).joined()
        }
    }

    static func explanation(for question: QuizQuestion) -> String {
        switch question.kind {
        case .choice(let q):
            q.direction == .chineseToEnglish ? "\(q.prompt) means \"\(q.answer)\"" : "\(q.answer) means \"\(q.prompt)\""
        case .pair(let q): "\(q.word) is \(q.pinyin.answer), \"\(q.meaning)\""
        case .cloze(let q): "\(q.answer) fits the blank: \(q.pinyin.answer), \"\(q.meaning.answer)\""
        }
    }

    static func answerText(for question: QuizQuestion) -> String {
        switch question.kind {
        case .choice(let q): q.answer
        case .pair(let q): "\(q.pinyin.answer) · \(q.second.answer)"
        case .cloze(let q): "\(q.answer) · \(q.pinyin.answer) · \(q.meaning.answer)"
        }
    }
}
