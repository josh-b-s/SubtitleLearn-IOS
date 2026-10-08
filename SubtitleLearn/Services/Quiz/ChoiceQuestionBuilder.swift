import Foundation

/// Level 1, built locally. Direction is random: zh to en or en to zh.
enum ChoiceQuestionBuilder {
    static func make(for word: SavedWord, picker: DistractorPicker) -> ChoiceQuestion? {
        let target = Candidate(word)
        guard !target.meanings.isEmpty else { return nil }
        let wrong = picker.pick(for: target)
        guard wrong.count == 3 else { return nil }
        let all = [target] + wrong

        if Bool.random() {
            return ChoiceQuestion(direction: .chineseToEnglish, prompt: target.word, hint: target.pinyin,
                                  choices: all.map(\.meaningText).shuffled(), answer: target.meaningText)
        }
        return ChoiceQuestion(direction: .englishToChinese, prompt: target.meaningText, hint: "",
                              choices: all.map(\.word).shuffled(), answer: target.word)
    }
}
