import Testing
@testable import SubtitleLearn

@MainActor
struct SessionWordTrackerTests {
    private func token(_ text: String, meanings: [String] = ["m"]) -> WordToken {
        WordToken(id: 0, text: text, pinyin: "p", meanings: meanings)
    }

    @Test func partialResultsAreNotCounted() {
        let tracker = SessionWordTracker()
        tracker.update([token("你好")], isFinal: false)
        #expect(tracker.entries.isEmpty)
    }

    @Test func finalResultCountsEachWordOnce() {
        let tracker = SessionWordTracker()
        tracker.update([token("你好")], isFinal: false)
        tracker.update([token("你好"), token("朋友")], isFinal: true)
        #expect(tracker.entries.count == 2)
        #expect(tracker.entries.allSatisfy { $0.count == 1 })
    }

    @Test func repeatedWordIncrementsCount() {
        let tracker = SessionWordTracker()
        tracker.update([token("你好")], isFinal: true)
        tracker.update([token("你好")], isFinal: true)
        #expect(tracker.entries.first?.count == 2)
    }

    @Test func wordsWithoutMeaningsAreSkipped() {
        let tracker = SessionWordTracker()
        tracker.update([token("嗯", meanings: [])], isFinal: true)
        #expect(tracker.entries.isEmpty)
    }

    @Test func flushCountsUnfinishedUtterance() {
        let tracker = SessionWordTracker()
        tracker.update([token("你好")], isFinal: false)
        tracker.flush()
        #expect(tracker.entries.count == 1)
    }

    @Test func resetClearsEverything() {
        let tracker = SessionWordTracker()
        tracker.update([token("你好")], isFinal: true)
        tracker.update([token("朋友")], isFinal: false)
        tracker.reset()
        tracker.flush()
        #expect(tracker.entries.isEmpty)
    }
}
