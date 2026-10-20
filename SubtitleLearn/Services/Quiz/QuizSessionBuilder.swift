import Foundation

/// Picks the words for a quiz and builds one question each at the word's level.
/// Falls back to an easier question type when a harder one can't be built.
@MainActor
struct QuizSessionBuilder {
    let allWords: [SavedWord]
    let count: Int
    var focus: Set<String>? = nil

    struct Result {
        var questions: [QuizQuestion]
        var note: String?
    }

    func build() async -> Result {
        // Mastered words are never quizzed. Due words first, otherwise any active word.
        var pool = allWords.filter { !$0.isMastered }
        if let focus { pool = pool.filter { focus.contains($0.word) } }
        let due = pool.filter(\.isDue)
        // A focused review asks about all its words, not just the due ones.
        let source = (focus != nil || due.isEmpty) ? pool : due
        let chosen = Array(source.shuffled().prefix(count))

        let dictionary = await DictionaryLoader.shared.value
        let picker = DistractorPicker(
            saved: allWords.map { Candidate($0) }.filter { !$0.meanings.isEmpty },
            dictionary: dictionary
        )
        let (sentences, note) = await levelThreeSentences(for: chosen)

        var questions: [QuizQuestion] = []
        for word in chosen {
            if let q = question(for: word, picker: picker, dictionary: dictionary, sentences: sentences[word.word] ?? []) {
                questions.append(q)
            }
        }
        return Result(questions: questions, note: note)
    }

    private func question(
        for word: SavedWord,
        picker: DistractorPicker,
        dictionary: ChineseDictionary?,
        sentences: [ClozeSentence]
    ) -> QuizQuestion? {
        // Each level asks two question types. The streak says which: 0 is the first, 1 the second.
        let second = word.levelStreak > 0
        if word.level >= 3 {
            if second, let dictionary,
               let cloze = sentences.shuffled().lazy.compactMap({
                   ClozeQuestionBuilder.make(for: word, sentence: $0, picker: picker, dictionary: dictionary)
               }).first {
                return QuizQuestion(word: word.word, level: 3, kind: .cloze(cloze))
            }
            if !second, let listening = PairQuestionBuilder.make(for: word, variant: .audio, picker: picker) {
                return QuizQuestion(word: word.word, level: 3, kind: .pair(listening))
            }
        }
        if word.level >= 2,
           let pair = PairQuestionBuilder.make(for: word, variant: second ? .meaningToWord : .wordToMeaning, picker: picker) {
            return QuizQuestion(word: word.word, level: 2, kind: .pair(pair))
        }
        let direction: ChoiceQuestion.Direction = second ? .englishToChinese : .chineseToEnglish
        guard let choice = ChoiceQuestionBuilder.make(for: word, direction: direction, picker: picker) else { return nil }
        return QuizQuestion(word: word.word, level: 1, kind: .choice(choice))
    }

    /// Cached sentences, fetching only for words at the cloze step of level 3 that have none yet.
    private func levelThreeSentences(for words: [SavedWord]) async -> ([String: [ClozeSentence]], String?) {
        let needed = words.filter { $0.level >= 3 && $0.levelStreak > 0 }
        guard !needed.isEmpty else { return ([:], nil) }

        let cache = ClozeCache.all()
        let missing = needed.filter { cache[$0.word]?.isEmpty ?? true }
        guard !missing.isEmpty else { return (cache, nil) }

        let key = AppSettings.shared.geminiAPIKey
        guard !key.isEmpty else {
            return (cache, "Some level 3 words got easier questions. Add a Gemini API key in Settings for sentences.")
        }
        do {
            let fetched = try await ClozeSentenceFetcher(client: GeminiClient(apiKey: key))
                .fetch(for: missing.map { Candidate($0) })
            ClozeCache.store(fetched)
            return (ClozeCache.all(), nil)
        } catch {
            return (cache, "Some level 3 words got easier questions. \(String(error.localizedDescription.prefix(160)))")
        }
    }
}
