import Foundation

extension QuizQuestion {
    /// The same question again with options reordered, for the end-of-quiz re-ask.
    func asRetry() -> QuizQuestion {
        let reordered: Kind
        switch kind {
        case .choice(let q):
            reordered = .choice(ChoiceQuestion(direction: q.direction, prompt: q.prompt, hint: q.hint,
                                               choices: q.choices.shuffled(), answer: q.answer))
        case .pair(let q):
            reordered = .pair(PairQuestion(word: q.word, pinyinChoices: q.pinyinChoices.shuffled(),
                                           meaningChoices: q.meaningChoices.shuffled(),
                                           pinyinAnswer: q.pinyinAnswer, meaningAnswer: q.meaningAnswer))
        case .cloze(let q):
            reordered = .cloze(ClozeQuestion(before: q.before, after: q.after, translation: q.translation,
                                             choices: q.choices.shuffled(), answer: q.answer))
        }
        return QuizQuestion(word: word, level: level, kind: reordered, isRetry: true)
    }
}
