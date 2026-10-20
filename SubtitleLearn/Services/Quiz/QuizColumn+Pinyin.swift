import Foundation

extension QuizColumn {
    /// Pinyin options. When `speaks` is set, tapping one says the word it belongs to, since the voice can't read pinyin.
    static func pinyin(target: Candidate, wrong: [Candidate], speaks: Bool) -> QuizColumn {
        let all = [target] + wrong
        return QuizColumn(
            title: "PINYIN",
            choices: all.map(\.pinyin).shuffled(),
            answer: target.pinyin,
            spoken: speaks ? Dictionary(all.map { ($0.pinyin, $0.word) }, uniquingKeysWith: { first, _ in first }) : [:]
        )
    }
}
