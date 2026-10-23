import Foundation

extension SavedWord {
    var isMastered: Bool { Mastery.isMastered(level) }

    /// Level plus progress through it, such as "2.5".
    var masteryLabel: String { Mastery.label(level: level, streak: levelStreak) }
    var masteryScore: Double { Mastery.score(level: level, streak: levelStreak) }

    /// Records one graded answer: SM-2 schedule plus mastery level.
    /// A question easier than the word's level (a fallback) only affects the schedule.
    func record(correct: Bool, questionLevel: Int) {
        review(quality: Mastery.quality(level: questionLevel, correct: correct))
        guard questionLevel == level else { return }

        let wasMastered = isMastered
        let next = Mastery.next(.init(level: level, streak: levelStreak), correct: correct)
        level = next.level
        levelStreak = next.streak
        stampMastery(wasMastered: wasMastered)
    }

    /// Manual override from the mastery slider: sets level and streak together from a score such as 2.5.
    func setProgress(_ score: Double) {
        let wasMastered = isMastered
        let state = Mastery.state(forScore: score)
        level = state.level
        levelStreak = state.streak
        stampMastery(wasMastered: wasMastered)
    }

    /// Feeds the mastered line on the stats chart.
    private func stampMastery(wasMastered: Bool) {
        if isMastered && !wasMastered {
            masteredDate = .now
        } else if !isMastered {
            masteredDate = nil
        }
    }
}
