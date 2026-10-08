import Foundation

/// Level 2, built locally. Pinyin and meaning options use separate wrong sets.
enum PairQuestionBuilder {
    static func make(for word: SavedWord, picker: DistractorPicker) -> PairQuestion? {
        let target = Candidate(word)
        guard !target.meanings.isEmpty, !target.pinyin.isEmpty else { return nil }
        let wrongPinyin = picker.pick(for: target)
        let wrongMeaning = picker.pick(for: target)
        guard wrongPinyin.count == 3, wrongMeaning.count == 3 else { return nil }

        return PairQuestion(
            word: target.word,
            pinyinChoices: ([target] + wrongPinyin).map(\.pinyin).shuffled(),
            meaningChoices: ([target] + wrongMeaning).map(\.meaningText).shuffled(),
            pinyinAnswer: target.pinyin,
            meaningAnswer: target.meaningText
        )
    }
}
