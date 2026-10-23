import Foundation

/// Level 2 and the level 3 listening question, built locally. Each column uses its own wrong set.
enum PairQuestionBuilder {
    enum Variant { case wordToMeaning, meaningToWord, audio }

    static func make(for word: SavedWord, variant: Variant, picker: DistractorPicker) -> PairQuestion? {
        let target = Candidate(word)
        guard !target.meanings.isEmpty, !target.pinyin.isEmpty else { return nil }
        let wrongFirst = picker.pick(for: target)
        let wrongSecond = picker.pick(for: target)
        guard wrongFirst.count == 3, wrongSecond.count == 3 else { return nil }

        let prompt: PairQuestion.Prompt
        let first: QuizColumn
        let second: QuizColumn
        switch variant {
        case .wordToMeaning:
            prompt = .word
            first = .pinyin(target: target, wrong: wrongFirst)
            second = meanings(target: target, wrong: wrongSecond)
        case .meaningToWord:
            prompt = .meaning
            first = .pinyin(target: target, wrong: wrongFirst)
            second = words(target: target, wrong: wrongSecond)
        case .audio:
            // The word is played, so neither column speaks when tapped.
            prompt = .audio
            first = words(target: target, wrong: wrongFirst)
            second = meanings(target: target, wrong: wrongSecond)
        }
        return PairQuestion(prompt: prompt, word: target.word, pinyin: target.pinyin, meaning: target.meaningText, first: first, second: second)
    }

    private static func meanings(target: Candidate, wrong: [Candidate]) -> QuizColumn {
        QuizColumn(title: "MEANING", choices: ([target] + wrong).map(\.meaningText).shuffled(), answer: target.meaningText)
    }

    private static func words(target: Candidate, wrong: [Candidate]) -> QuizColumn {
        QuizColumn(title: "WORD", choices: ([target] + wrong).map(\.word).shuffled(), answer: target.word)
    }
}
