import Foundation

/// Pure level rules. Levels 1 to 3 are quizzed, level 4 is mastered and never quizzed again.
enum Mastery {
    static let masteredLevel = 4
    static let passesNeeded = 2

    struct State: Equatable {
        var level: Int
        var streak: Int
    }

    /// Half-levels lost on a miss. One step is one correct answer, so 1 means a miss undoes the last pass.
    static let missPenalty = 1

    /// Promote after `passesNeeded` correct answers in a row, lose `missPenalty` steps on a miss.
    static func next(_ state: State, correct: Bool) -> State {
        guard state.level < masteredLevel else { return state }
        guard correct else { return stateAtStep(step(of: state) - missPenalty) }

        let streak = state.streak + 1
        if streak >= passesNeeded { return State(level: state.level + 1, streak: 0) }
        return State(level: state.level, streak: streak)
    }

    /// Distance between neighbouring scores: one pass.
    static var scoreStep: Double { 1 / Double(passesNeeded) }

    /// Level plus progress through it: level 2 with one pass is 2.5.
    static func score(level: Int, streak: Int) -> Double {
        Double(level) + Double(streak) * scoreStep
    }

    /// The level and streak a score stands for, snapped to the nearest step.
    static func state(forScore score: Double) -> State {
        stateAtStep(Int(((score - 1) / scoreStep).rounded()))
    }

    /// "Level 2.5", or "Mastered" at the top.
    static func summary(forScore score: Double) -> String {
        let result = state(forScore: score)
        return isMastered(result.level) ? "Mastered" : "Level \(label(level: result.level, streak: result.streak))"
    }

    static func label(level: Int, streak: Int) -> String {
        score(level: level, streak: streak).formatted(.number.precision(.fractionLength(0...1)))
    }

    private static func step(of state: State) -> Int { (state.level - 1) * passesNeeded + state.streak }

    private static func stateAtStep(_ step: Int) -> State {
        let clamped = min(max(step, 0), (masteredLevel - 1) * passesNeeded)
        return State(level: clamped / passesNeeded + 1, streak: clamped % passesNeeded)
    }

    /// SM-2 quality. Easier levels earn less so a lucky guess can't stretch the interval.
    static func quality(level: Int, correct: Bool) -> Int {
        guard correct else { return 1 }
        switch level {
        case 1: return 3
        case 2: return 4
        default: return 5
        }
    }

    static func isMastered(_ level: Int) -> Bool { level >= masteredLevel }

    /// Hints shown in subtitles: meaning goes after level 1, pinyin after level 2.
    static func showsMeaning(at level: Int) -> Bool { level < 2 }
    static func showsPinyin(at level: Int) -> Bool { level < 3 }
}
