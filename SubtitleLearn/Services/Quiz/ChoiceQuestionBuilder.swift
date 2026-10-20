import Foundation

/// Level 1, built locally.
enum ChoiceQuestionBuilder {
    static func make(for word: SavedWord, direction: ChoiceQuestion.Direction, picker: DistractorPicker) -> ChoiceQuestion? {
        let target = Candidate(word)
        guard !target.meanings.isEmpty else { return nil }
        let wrong = picker.pick(for: target)
        guard wrong.count == 3 else { return nil }
        let all = [target] + wrong

        if direction == .chineseToEnglish {
            return ChoiceQuestion(direction: .chineseToEnglish, prompt: target.word, hint: target.pinyin,
                                  choices: all.map(\.meaningText).shuffled(), answer: target.meaningText)
        }
        return ChoiceQuestion(direction: .englishToChinese, prompt: target.meaningText, hint: "",
                              choices: all.map(\.word).shuffled(), answer: target.word,
                              choicePinyin: Dictionary(all.map { ($0.word, $0.pinyin) }, uniquingKeysWith: { first, _ in first }))
    }
}
