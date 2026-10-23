import Foundation

/// Level 3: turns a cached sentence into a blank plus word tokens, with pinyin and meaning options. Graded locally.
enum ClozeQuestionBuilder {
    static func make(
        for word: SavedWord,
        sentence: ClozeSentence,
        picker: DistractorPicker,
        dictionary: ChineseDictionary,
        levels: [String: Int]
    ) -> ClozeQuestion? {
        guard sentence.word == word.word, let range = sentence.sentence.range(of: word.word) else { return nil }

        // The target must be a whole word here, not part of a longer one.
        guard dictionary.segment(sentence.sentence).filter({ $0 == word.word }).count == 1 else { return nil }

        let target = Candidate(word)
        guard !target.meanings.isEmpty, !target.pinyin.isEmpty else { return nil }
        let wrong = picker.pick(for: target)
        let wrongPinyin = picker.pick(for: target)
        let wrongMeaning = picker.pick(for: target)
        guard wrong.count == 3, wrongPinyin.count == 3, wrongMeaning.count == 3 else { return nil }

        // Neighbouring words show the hints their mastery level allows.
        let before = MasteryRedactor.apply(to: dictionary.tokens(for: String(sentence.sentence[..<range.lowerBound])), levels: levels)
        let after = MasteryRedactor.apply(to: dictionary.tokens(for: String(sentence.sentence[range.upperBound...])), levels: levels)
            .map { $0.reindexed($0.id + before.count + 1) }

        return ClozeQuestion(
            before: before,
            after: after,
            translation: sentence.translation,
            choices: ([word.word] + wrong.map(\.word)).shuffled(),
            answer: word.word,
            pinyin: .pinyin(target: target, wrong: wrongPinyin),
            meaning: QuizColumn(title: "MEANING", choices: ([target] + wrongMeaning).map(\.meaningText).shuffled(), answer: target.meaningText)
        )
    }
}
