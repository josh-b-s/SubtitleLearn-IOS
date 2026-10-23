import Foundation

extension QuizQuestion {
    /// The same question again with options reordered, for the end-of-quiz re-ask.
    func asRetry() -> QuizQuestion {
        let reordered: Kind
        switch kind {
        case .choice(let q):
            reordered = .choice(ChoiceQuestion(direction: q.direction, prompt: q.prompt, hint: q.hint,
                                               choices: q.choices.shuffled(), answer: q.answer,
                                               choicePinyin: q.choicePinyin))
        case .pair(let q):
            reordered = .pair(PairQuestion(prompt: q.prompt, word: q.word, pinyin: q.pinyin, meaning: q.meaning,
                                           first: q.first.shuffled(), second: q.second.shuffled()))
        case .cloze(let q):
            reordered = .cloze(ClozeQuestion(before: q.before, after: q.after, translation: q.translation,
                                             choices: q.choices.shuffled(), answer: q.answer,
                                             pinyin: q.pinyin.shuffled(), meaning: q.meaning.shuffled()))
        }
        return QuizQuestion(word: word, level: level, kind: reordered, isRetry: true)
    }
}
