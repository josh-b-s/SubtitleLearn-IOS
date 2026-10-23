import Testing
@testable import SubtitleLearn

struct SavedWordRecordTests {
    private func word(level: Int = 1, streak: Int = 0) -> SavedWord {
        let word = SavedWord(word: "你好", pinyin: "nǐhǎo", meanings: ["hello"])
        word.level = level
        word.levelStreak = streak
        return word
    }

    @Test func matchingQuestionLevelCanPromote() {
        let w = word(level: 1, streak: 1)
        w.record(correct: true, questionLevel: 1)
        #expect(w.level == 2)
        #expect(w.levelStreak == 0)
    }

    @Test func missLosesHalfALevel() {
        let w = word(level: 3, streak: 0)
        w.record(correct: false, questionLevel: 3)
        #expect(w.masteryLabel == "2.5")
    }

    @Test func easierFallbackQuestionOnlyAffectsSchedule() {
        let w = word(level: 3, streak: 1)
        w.record(correct: false, questionLevel: 1)
        #expect(w.level == 3)
        #expect(w.levelStreak == 1)
        #expect(w.repetitions == 0)
        #expect(w.intervalDays == 1)
    }

    @Test func setProgressClampsToValidRange() {
        let w = word()
        w.setProgress(9)
        #expect(w.level == Mastery.masteredLevel)
        w.setProgress(-2)
        #expect(w.level == 1)
        #expect(w.levelStreak == 0)
    }

    @Test func setProgressSetsLevelAndStreak() {
        let w = word(level: 1, streak: 1)
        w.setProgress(2.5)
        #expect(w.level == 2)
        #expect(w.levelStreak == 1)
        w.setProgress(3)
        #expect(w.levelStreak == 0)
    }

    @Test func masteredFlagFollowsLevel() {
        #expect(!word(level: 3).isMastered)
        #expect(word(level: 4).isMastered)
    }

    @Test func masteredDateIsSetOnMasteryAndClearedWhenItDrops() {
        let w = word()
        w.setProgress(Double(Mastery.masteredLevel))
        #expect(w.masteredDate != nil)
        w.setProgress(2)
        #expect(w.masteredDate == nil)
    }
}
