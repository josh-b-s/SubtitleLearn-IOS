import Testing
@testable import SubtitleLearn

struct SpacedRepetitionTests {
    private let fresh = SpacedRepetition.State(repetitions: 0, easeFactor: 2.5, intervalDays: 0)

    @Test func firstSuccessIsDueTomorrow() {
        let next = SpacedRepetition.next(fresh, quality: 5)
        #expect(next.repetitions == 1)
        #expect(next.intervalDays == 1)
    }

    @Test func secondSuccessWaitsSixDays() {
        let first = SpacedRepetition.next(fresh, quality: 5)
        #expect(SpacedRepetition.next(first, quality: 5).intervalDays == 6)
    }

    @Test func laterIntervalsScaleByEaseFactor() {
        let state = SpacedRepetition.State(repetitions: 2, easeFactor: 2.6, intervalDays: 6)
        #expect(SpacedRepetition.next(state, quality: 5).intervalDays == 16)
    }

    @Test func failureResetsRepetitionsAndReviewsTomorrow() {
        let state = SpacedRepetition.State(repetitions: 5, easeFactor: 2.5, intervalDays: 30)
        let next = SpacedRepetition.next(state, quality: 1)
        #expect(next.repetitions == 0)
        #expect(next.intervalDays == 1)
    }

    @Test func easeFactorFollowsQuality() {
        let perfect = SpacedRepetition.next(fresh, quality: 5)
        let middling = SpacedRepetition.next(fresh, quality: 3)
        #expect(abs(perfect.easeFactor - 2.6) < 0.0001)
        #expect(abs(middling.easeFactor - 2.36) < 0.0001)
    }

    @Test func easeFactorNeverDropsBelowFloor() {
        let state = SpacedRepetition.State(repetitions: 0, easeFactor: 1.3, intervalDays: 0)
        #expect(SpacedRepetition.next(state, quality: 1).easeFactor == 1.3)
    }
}
