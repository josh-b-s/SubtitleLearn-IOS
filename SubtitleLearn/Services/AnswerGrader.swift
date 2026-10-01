import Foundation

/// Grades free-text answers (translation / sentence-correction questions) with Gemini.
/// Locally-gradable question types (multiple choice, fill in the blank) never reach this.
struct AnswerGrader {
    var client: GeminiClient

    private let schema: [String: Any] = [
        "type": "OBJECT",
        "properties": [
            "quality": ["type": "INTEGER", "enum": ["1", "3", "5"]],
            "feedback": ["type": "STRING"]
        ],
        "required": ["quality", "feedback"]
    ]

    /// `quality` follows the SM-2 scale used everywhere else in the app:
    /// 1 = no idea / wrong, 3 = roughly right, 5 = got it.
    func grade(question: QuizQuestion, userAnswer: String) async throws -> GradeResult {
        let prompt = """
        Grade a learner's answer to a Mandarin Chinese quiz question.
        Question type: \(question.type.rawValue)
        Question: \(question.prompt)
        Expected answer (one acceptable version): \(question.answer)
        Learner's answer: \(userAnswer)

        Judge the learner's answer on meaning and correct use of the target word "\(question.word)",
        not on exact wording. Give a short (<20 word) feedback sentence in English.
        Return quality as: 5 if correct/natural, 3 if understandable but with real errors, 1 if wrong or blank.
        """
        let json = try await client.generateJSON(prompt: prompt, schema: schema)
        guard
            let data = json.data(using: .utf8),
            let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { throw GeminiError.badResponse(json) }

        let quality = (obj["quality"] as? Int) ?? Int(obj["quality"] as? String ?? "") ?? 1
        let feedback = (obj["feedback"] as? String) ?? ""
        return GradeResult(quality: min(5, max(1, quality)), feedback: feedback)
    }
}
