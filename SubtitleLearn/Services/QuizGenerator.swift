import Foundation

/// Builds quiz questions for a set of saved words using Gemini structured output.
struct QuizGenerator {
    var client: GeminiClient

    private let schema: [String: Any] = [
        "type": "ARRAY",
        "items": [
            "type": "OBJECT",
            "properties": [
                "type": ["type": "STRING", "enum": ["fill_blank", "translate_to_chinese", "translate_to_english", "multiple_choice", "sentence_correction"]],
                "word": ["type": "STRING"],
                "prompt": ["type": "STRING"],
                "answer": ["type": "STRING"],
                "choices": ["type": "ARRAY", "items": ["type": "STRING"]]
            ],
            "required": ["type", "word", "prompt", "answer"]
        ]
    ]

    /// One question per word in `words`, in the same order.
    func makeQuiz(for words: [SavedWord]) async throws -> [QuizQuestion] {
        guard !words.isEmpty else { return [] }

        let wordList = words.map { "\($0.word) (\($0.pinyin)) - \($0.meanings.joined(separator: "; "))" }
            .joined(separator: "\n")

        let prompt = """
        You are generating a Mandarin Chinese vocabulary quiz for a learner.
        For EACH word below, write exactly one question, in the SAME order, using a mix of these types:
        - fill_blank: a natural Chinese sentence using the word, with the word replaced by "___". answer = the word.
        - translate_to_chinese: an English sentence using the word's meaning. answer = a natural Chinese translation.
        - translate_to_english: a Chinese sentence using the word. answer = a natural English translation.
        - multiple_choice: a Chinese sentence with the word replaced by "___", plus 4 "choices" (the word and 3 plausible wrong words), answer = the word.
        - sentence_correction: a Chinese sentence that misuses the word or grammar near it, answer = the corrected sentence.

        Use multiple_choice and fill_blank for at least half the questions since they're easiest to self-grade.
        Keep sentences short (under 15 Chinese characters or 10 English words) and appropriate for a beginner/intermediate learner.
        Set "word" to exactly the vocabulary word it targets, spelled exactly as given below.

        Vocabulary:
        \(wordList)
        """

        let json = try await client.generateJSON(prompt: prompt, schema: schema)
        guard let data = json.data(using: .utf8) else { throw GeminiError.badResponse(json) }
        var questions = try JSONDecoder().decode([QuizQuestion].self, from: data)

        // Gemini can occasionally drop or reorder a word; keep only ones we recognise
        // and fall back gracefully rather than crashing the quiz.
        let known = Set(words.map(\.word))
        questions.removeAll { !known.contains($0.word) }
        return questions
    }
}
