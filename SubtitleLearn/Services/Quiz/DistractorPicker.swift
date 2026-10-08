import Foundation

/// Chooses plausible wrong options: other saved words first, dictionary words to fill.
struct DistractorPicker {
    let saved: [Candidate]
    let dictionary: ChineseDictionary?

    func pick(for target: Candidate, count: Int = 3) -> [Candidate] {
        let length = target.word.count
        let targetMeanings = Set(target.meanings)
        var picked: [Candidate] = []

        func consider(_ c: Candidate) {
            guard picked.count < count,
                  c.word != target.word, c.pinyin != target.pinyin,
                  !c.meanings.isEmpty, targetMeanings.isDisjoint(with: c.meanings)
            else { return }
            let clash = picked.contains {
                $0.word == c.word || $0.pinyin == c.pinyin || $0.meaningText == c.meaningText
            }
            if !clash { picked.append(c) }
        }

        // Same length first so options look alike.
        let sameLength = saved.filter { $0.word.count == length }.shuffled()
        let others = saved.filter { $0.word.count != length }.shuffled()
        for c in sameLength + others { consider(c) }

        if picked.count < count, let dictionary {
            let extra = dictionary.sample(count: (count - picked.count) * 4, length: length)
            for e in extra {
                consider(Candidate(word: e.word, pinyin: e.entry.pinyin, meanings: e.entry.meanings))
            }
        }
        return picked
    }
}
