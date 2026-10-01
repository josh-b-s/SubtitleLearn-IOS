import Foundation
import SwiftData
import Observation

enum QuizPhase {
    case idle
    case loading
    case answering
    case grading
    case feedback(GradeResult)
    case finished(reviewed: Int)
    case error(String)
}

@MainActor
@Observable
final class QuizViewModel {
    private(set) var questions: [QuizQuestion] = []
    private(set) var currentIndex = 0
    private(set) var phase: QuizPhase = .idle
    var userAnswer = ""
    var selectedChoice: String?

    var currentQuestion: QuizQuestion? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }
    var progressText: String { "\(min(currentIndex + 1, questions.count)) / \(questions.count)" }

    private var reviewedCount = 0

    /// Picks due words first (or all saved words if none are due yet), generates
    /// a quiz for them, and starts answering.
    func start(allWords: [SavedWord], modelContext: ModelContext) async {
        guard !allWords.isEmpty else {
            phase = .error("Save some words on the Translate tab first.")
            return
        }
        let settings = AppSettings.shared
        guard !settings.geminiAPIKey.isEmpty else {
            phase = .error("Add a Gemini API key in Settings first.")
            return
        }

        phase = .loading
        let due = allWords.filter(\.isDue)
        let pool = (due.isEmpty ? allWords : due).shuffled()
        let picked = Array(pool.prefix(settings.questionsPerQuiz))

        do {
            let client = GeminiClient(apiKey: settings.geminiAPIKey)
            let generated = try await QuizGenerator(client: client).makeQuiz(for: picked)
            guard !generated.isEmpty else {
                phase = .error("Gemini didn't return any questions. Try again.")
                return
            }
            questions = generated
            currentIndex = 0
            reviewedCount = 0
            userAnswer = ""
            selectedChoice = nil
            phase = .answering
        } catch {
            phase = .error(error.localizedDescription)
        }
    }

    func submit(allWords: [SavedWord], modelContext: ModelContext) async {
        guard let question = currentQuestion else { return }

        if question.type.isLocallyGradable {
            let given = (question.type == .multipleChoice ? (selectedChoice ?? "") : userAnswer)
            let correct = given.trimmingCharacters(in: .whitespacesAndNewlines)
                .caseInsensitiveCompare(question.answer.trimmingCharacters(in: .whitespacesAndNewlines)) == .orderedSame
            let result = GradeResult(quality: correct ? 5 : 1, feedback: correct ? "Correct!" : "The answer was \(question.answer).")
            applyGrade(result, word: question.word, allWords: allWords)
            return
        }

        guard !userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        phase = .grading
        do {
            let client = GeminiClient(apiKey: AppSettings.shared.geminiAPIKey)
            let result = try await AnswerGrader(client: client).grade(question: question, userAnswer: userAnswer)
            applyGrade(result, word: question.word, allWords: allWords)
        } catch {
            phase = .error(error.localizedDescription)
        }
    }

    private func applyGrade(_ result: GradeResult, word: String, allWords: [SavedWord]) {
        if let match = allWords.first(where: { $0.word == word }) {
            match.review(quality: result.quality)
            reviewedCount += 1
        }
        phase = .feedback(result)
    }

    func next() {
        userAnswer = ""
        selectedChoice = nil
        currentIndex += 1
        phase = currentIndex < questions.count ? .answering : .finished(reviewed: reviewedCount)
    }

    func reset() {
        questions = []
        currentIndex = 0
        reviewedCount = 0
        userAnswer = ""
        selectedChoice = nil
        phase = .idle
    }
}
