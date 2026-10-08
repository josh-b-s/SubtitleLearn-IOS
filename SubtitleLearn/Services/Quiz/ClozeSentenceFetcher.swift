import Foundation

/// The only Gemini call left: short example sentences with an English translation.
/// Pinyin and word meanings come from the local dictionary, not from Gemini.
struct ClozeSentenceFetcher {
    var client: GeminiClient
    static let perWord = 2

    private let schema: [String: Any] = [
        "type": "ARRAY",
        "items": [
            "type": "OBJECT",
            "properties": [
                "word": ["type": "STRING"],
                "sentence": ["type": "STRING"],
                "translation": ["type": "STRING"]
            ],
            "required": ["word", "sentence", "translation"]
        ]
    ]

    func fetch(for words: [Candidate]) async throws -> [ClozeSentence] {
        guard !words.isEmpty else { return [] }

        let list = words.map { "\($0.word) (\($0.pinyin)): \($0.meanings.joined(separator: "; "))" }
            .joined(separator: "\n")
        let prompt = """
        Write example sentences for a beginner learning Mandarin Chinese.
        For EACH word below write \(Self.perWord) different sentences. Rules:
        - Use the word exactly once, spelled exactly as given, as a whole word.
        - Use only very common words and simple grammar. Under 12 characters.
        - Make the sentence clear enough that only this word fits the gap.
        - Give a natural English translation.
        - Set "word" to the target word exactly as given.

        Words:
        \(list)
        """

        let json = try await client.generateJSON(prompt: prompt, schema: schema)
        guard let data = json.data(using: .utf8) else { throw GeminiError.badResponse(json) }
        let decoded = try JSONDecoder().decode([ClozeSentence].self, from: data)

        let known = Set(words.map(\.word))
        return decoded.filter { known.contains($0.word) && $0.isUsable }
    }
}
