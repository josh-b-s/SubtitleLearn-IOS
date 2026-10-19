import Testing
@testable import SubtitleLearn

struct MasteryTests {
    @Test func firstCorrectAnswerBuildsStreak() {
        let next = Mastery.next(.init(level: 1, streak: 0), correct: true)
        #expect(next == .init(level: 1, streak: 1))
    }

    @Test func secondCorrectInARowPromotes() {
        let next = Mastery.next(.init(level: 1, streak: 1), correct: true)
        #expect(next == .init(level: 2, streak: 0))
    }

    @Test func missDropsOneLevelAndClearsStreak() {
        let next = Mastery.next(.init(level: 3, streak: 1), correct: false)
        #expect(next == .init(level: 2, streak: 0))
    }

    @Test func missAtLevelOneStaysAtLevelOne() {
        let next = Mastery.next(.init(level: 1, streak: 1), correct: false)
        #expect(next == .init(level: 1, streak: 0))
    }

    @Test func passingLevelThreeMastersTheWord() {
        let next = Mastery.next(.init(level: 3, streak: 1), correct: true)
        #expect(next.level == Mastery.masteredLevel)
    }

    @Test(arguments: [true, false])
    func masteredWordNeverChanges(correct: Bool) {
        let state = Mastery.State(level: 4, streak: 0)
        #expect(Mastery.next(state, correct: correct) == state)
    }

    @Test func wrongAnswerAlwaysScoresOne() {
        for level in 1...3 { #expect(Mastery.quality(level: level, correct: false) == 1) }
    }

    @Test func correctQualityRisesWithLevel() {
        #expect(Mastery.quality(level: 1, correct: true) == 3)
        #expect(Mastery.quality(level: 2, correct: true) == 4)
        #expect(Mastery.quality(level: 3, correct: true) == 5)
    }

    @Test func hintsHideAsLevelRises() {
        #expect(Mastery.showsMeaning(at: 1))
        #expect(!Mastery.showsMeaning(at: 2))
        #expect(Mastery.showsPinyin(at: 2))
        #expect(!Mastery.showsPinyin(at: 3))
    }

    @Test func statusGroupsLevels() {
        #expect(MasteryStatus(level: 1) == .new)
        #expect(MasteryStatus(level: 2) == .learning)
        #expect(MasteryStatus(level: 3) == .learning)
        #expect(MasteryStatus(level: 4) == .mastered)
    }
}
