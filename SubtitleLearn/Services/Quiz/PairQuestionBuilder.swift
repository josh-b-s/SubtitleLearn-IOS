import Foundation

/// Level 2 and the level 3 listening question, built locally. Each column uses its own wrong set.
enum PairQuestionBuilder {
    enum Variant { case wordToMeaning, meaningToWord, audio }

    static func make(for word: SavedWord, variant: Variant, picker: DistractorPicker) -> PairQuestion? {
        let target = Candidate(word)
        guard !target.meanings.isEmpty, !target.pinyin.isEmpty else { return nil }
        let wrongPinyin = picker.pick(for: target)
        let wrongSecond = picker.pick(for: target)
        guard wrongPinyin.count == 3, wrongSecond.count == 3 else { return nil }

        // The listening question plays the prompt, so its options stay silent.
        let pinyin = QuizColumn.pinyin(target: target, wrong: wrongPinyin, speaks: variant != .audio)
        let second: QuizColumn
        let prompt: PairQuestion.Prompt
        switch variant {
        case .wordToMeaning, .audio:
            second = QuizColumn(title: "MEANING", choices: ([target] + wrongSecond).map(\.meaningText).shuffled(), answer: target.meaningText)
            prompt = variant == .audio ? .audio : .word
        case .meaningToWord:
            second = QuizColumn(title: "WORD", choices: ([target] + wrongSecond).map(\.word).shuffled(), answer: target.word)
            prompt = .meaning
        }
        return PairQuestion(prompt: prompt, word: target.word, meaning: target.meaningText, pinyin: pinyin, second: second)
    }
}
