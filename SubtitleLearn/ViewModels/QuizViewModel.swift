import Foundation
import Observation
import SwiftData

enum QuizPhase {
    case idle
    case loading
    case answering
    case feedback(QuizFeedback)
    case finished(QuizSummary)
    case error(String)
}

@MainActor
@Observable
final class QuizViewModel {
    private(set) var phase: QuizPhase = .idle
    private(set) var note: String?

    var selectedChoice: String?
    var selectedPinyin: String?
    var selectedSecond: String?

    private(set) var total = 0
    private var queue: [QuizQuestion] = []
    private var answered: QuizQuestion?   // stays on screen while its feedback shows
    private var completed = 0
    private var record: QuizRecord?   // this run's history entry, created on the first answer

    // First-attempt tallies for the summary.
    private var attempted = 0
    private var correctFirstTry = 0
    private var leveledUp = 0
    private var mastered = 0

    var currentQuestion: QuizQuestion? { queue.first }

    var feedback: QuizFeedback? {
        if case .feedback(let feedback) = phase { feedback } else { nil }
    }

    /// The question on screen: the one just answered while feedback shows, otherwise the next one.
    var shownQuestion: QuizQuestion? { feedback == nil ? currentQuestion : answered }

    var hasMoreQuestions: Bool { !queue.isEmpty }
    var canSubmit: Bool { currentAnswer != nil }

    /// True while a quiz is underway (question or feedback showing).
    var isInProgress: Bool {
        switch phase {
        case .answering, .feedback: true
        default: false
        }
    }

    /// Total stays constant: a miss moves a question to the back, it doesn't add one.
    var progressIndex: Int {
        let index = feedback.map { $0.correct ? completed : completed + 1 } ?? completed + 1
        return min(max(index, 1), max(total, 1))
    }

    var progressFraction: Double { total == 0 ? 0 : Double(completed) / Double(total) }

    private var currentAnswer: QuizAnswer? {
        guard let question = currentQuestion else { return nil }
        switch question.kind {
        case .pair:
            guard let pinyin = selectedPinyin, let second = selectedSecond else { return nil }
            return .pair(pinyin: pinyin, second: second)
        case .cloze:
            guard let word = selectedChoice, let pinyin = selectedPinyin, let meaning = selectedSecond else { return nil }
            return .cloze(word: word, pinyin: pinyin, meaning: meaning)
        case .choice:
            return selectedChoice.map { QuizAnswer.choice($0) }
        }
    }

    /// `focus` limits the quiz to those words (used by the session summary review).
    func start(allWords: [SavedWord], focus: Set<String>? = nil) async {
        guard !allWords.isEmpty else {
            phase = .error("Save some words on the Translate tab first.")
            return
        }
        guard allWords.contains(where: { !$0.isMastered }) else {
            phase = .error("Every saved word is mastered. Save more words to keep learning.")
            return
        }

        phase = .loading
        let built = await QuizSessionBuilder(allWords: allWords, count: AppSettings.shared.questionsPerQuiz, focus: focus).build()
        guard !built.questions.isEmpty else {
            phase = .error("Couldn't build any questions. Try saving a few more words.")
            return
        }
        resetTallies()
        queue = built.questions
        total = built.questions.count
        note = built.note
        phase = .answering
    }

    func submit(allWords: [SavedWord], context: ModelContext) {
        guard case .answering = phase, let question = currentQuestion, let answer = currentAnswer else { return }
        let correct = QuizGrader.isCorrect(question, answer: answer)

        // Only the first attempt counts. Retries just have to be answered.
        var levelNote: String?
        if !question.isRetry, let word = allWords.first(where: { $0.word == question.word }) {
            let before = word.level
            word.record(correct: correct, questionLevel: question.level)
            context.insert(ReviewLog(word: word.word, correct: correct))
            levelNote = Self.levelNote(from: before, to: word.level)
            tally(correct: correct, before: before, after: word.level)
            addToHistory(question, correct: correct, context: context)
        }

        let asked = queue.removeFirst()
        answered = asked
        if correct {
            completed += 1
        } else {
            queue.append(asked.asRetry())
        }
        phase = .feedback(QuizFeedback(
            correct: correct,
            answerText: QuizGrader.answerText(for: asked),
            explanation: QuizGrader.explanation(for: asked),
            levelNote: levelNote
        ))
    }

    func next() {
        selectedChoice = nil
        selectedPinyin = nil
        selectedSecond = nil
        phase = queue.isEmpty
            ? .finished(QuizSummary(attempted: attempted, correctFirstTry: correctFirstTry, leveledUp: leveledUp, mastered: mastered))
            : .answering
    }

    func reset() {
        queue = []
        answered = nil
        total = 0
        selectedChoice = nil
        selectedPinyin = nil
        selectedSecond = nil
        note = nil
        resetTallies()
        phase = .idle
    }

    // MARK: - Helpers

    private func resetTallies() {
        record = nil
        completed = 0
        attempted = 0
        correctFirstTry = 0
        leveledUp = 0
        mastered = 0
    }

    private func tally(correct: Bool, before: Int, after: Int) {
        attempted += 1
        if correct { correctFirstTry += 1 }
        if after > before { leveledUp += 1 }
        if Mastery.isMastered(after) && !Mastery.isMastered(before) { mastered += 1 }
    }

    private func addToHistory(_ question: QuizQuestion, correct: Bool, context: ModelContext) {
        let item = QuizRecordItem(
            prompt: QuizGrader.promptText(for: question),
            answer: QuizGrader.answerText(for: question),
            correct: correct
        )
        if let record {
            record.items.append(item)
        } else {
            let created = QuizRecord(items: [item])
            context.insert(created)
            record = created
        }
    }

    private static func levelNote(from old: Int, to new: Int) -> String? {
        if new < old { return "Back to level \(new)." }
        guard new > old else { return nil }
        switch new {
        case 2: return "Level 2. Subtitles will now hide its meaning."
        case 3: return "Level 3. Subtitles will now hide its pinyin too."
        default: return "Mastered! It won't be quizzed again."
        }
    }
}
