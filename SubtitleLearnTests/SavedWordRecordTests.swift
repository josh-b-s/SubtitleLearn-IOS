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

    @Test func easierFallbackQuestionOnlyAffectsSchedule() {
        let w = word(level: 3, streak: 1)
        w.record(correct: false, questionLevel: 1)
        #expect(w.level == 3)
        #expect(w.levelStreak == 1)
        #expect(w.repetitions == 0)
        #expect(w.intervalDays == 1)
    }

    @Test func setLevelClampsToValidRange() {
        let w = word()
        w.setLevel(9)
        #expect(w.level == Mastery.masteredLevel)
        w.setLevel(-2)
        #expect(w.level == 1)
    }

    @Test func setLevelClearsStreak() {
        let w = word(level: 2, streak: 1)
        w.setLevel(3)
        #expect(w.levelStreak == 0)
    }

    @Test func masteredFlagFollowsLevel() {
        #expect(!word(level: 3).isMastered)
        #expect(word(level: 4).isMastered)
    }
}
