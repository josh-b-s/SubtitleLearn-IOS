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

    /// Manual override from the detail sheet. Clears the streak so the new level starts fresh.
    func setLevel(_ newLevel: Int) {
        let wasMastered = isMastered
        level = min(max(newLevel, 1), Mastery.masteredLevel)
        levelStreak = 0
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
