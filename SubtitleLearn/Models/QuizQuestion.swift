import Foundation

enum QuizQuestionType: String, Codable {
    case fillBlank = "fill_blank"
    case translateToChinese = "translate_to_chinese"
    case translateToEnglish = "translate_to_english"
    case multipleChoice = "multiple_choice"
    case sentenceCorrection = "sentence_correction"

    /// Local exact-match grading is reliable for these; the rest need the AI grader.
    var isLocallyGradable: Bool { self == .fillBlank || self == .multipleChoice }
}

/// One AI-generated quiz question, targeting a single saved word.
struct QuizQuestion: Codable, Identifiable {
    var id: UUID = UUID()
    let type: QuizQuestionType
    let word: String          // the SavedWord.word this question reviews
    let prompt: String        // shown to the user (sentence with a blank, a sentence to translate, etc.)
    let answer: String        // the expected/correct answer
    let choices: [String]?    // only for .multipleChoice

    enum CodingKeys: String, CodingKey { case type, word, prompt, answer, choices }
}

/// Result of grading one answer: feeds directly into the SM-2 quality scale (1 / 3 / 5).
struct GradeResult {
    let quality: Int
    let feedback: String
}
