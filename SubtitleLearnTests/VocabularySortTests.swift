import Foundation
import Testing
@testable import SubtitleLearn

struct VocabularySortTests {
    private func word(_ text: String) -> SavedWord {
        SavedWord(word: text, pinyin: "", meanings: [])
    }

    @Test func recentlyReviewedLeadsWithLatestReviewAndEndsWithNeverReviewed() {
        let words = [word("a"), word("b"), word("c")]
        let logs = [
            ReviewLog(word: "a", correct: true, date: Date(timeIntervalSinceNow: -500)),
            ReviewLog(word: "a", correct: true, date: Date(timeIntervalSinceNow: -300)),
            ReviewLog(word: "b", correct: false, date: Date(timeIntervalSinceNow: -100))
        ]
        #expect(VocabularySort.recentlyReviewed.sorted(words, logs: logs).map(\.word) == ["b", "a", "c"])
    }

    @Test func mostMissedCountsOnlyWrongAnswers() {
        let words = [word("a"), word("b"), word("c")]
        let logs = [
            ReviewLog(word: "a", correct: false),
            ReviewLog(word: "b", correct: false),
            ReviewLog(word: "b", correct: false),
            ReviewLog(word: "c", correct: true)
        ]
        #expect(VocabularySort.mostMissed.sorted(words, logs: logs).map(\.word) == ["b", "a", "c"])
    }
}
