import Foundation

/// Level 3: turns a cached sentence into a blank plus tappable tokens, graded locally.
enum ClozeQuestionBuilder {
    static func make(
        for word: SavedWord,
        sentence: ClozeSentence,
        picker: DistractorPicker,
        dictionary: ChineseDictionary
    ) -> ClozeQuestion? {
        guard sentence.word == word.word, let range = sentence.sentence.range(of: word.word) else { return nil }

        // The target must be a whole word here, not part of a longer one.
        guard dictionary.segment(sentence.sentence).filter({ $0 == word.word }).count == 1 else { return nil }

        let wrong = picker.pick(for: Candidate(word))
        guard wrong.count == 3 else { return nil }

        let before = dictionary.tokens(for: String(sentence.sentence[..<range.lowerBound]))
        let after = dictionary.tokens(for: String(sentence.sentence[range.upperBound...]))
            .map { $0.reindexed($0.id + before.count + 1) }

        return ClozeQuestion(
            before: before,
            after: after,
            translation: sentence.translation,
            choices: ([word.word] + wrong.map(\.word)).shuffled(),
            answer: word.word
        )
    }
}
