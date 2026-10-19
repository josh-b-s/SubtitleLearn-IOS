import Foundation

/// Pure level rules. Levels 1 to 3 are quizzed, level 4 is mastered and never quizzed again.
enum Mastery {
    static let masteredLevel = 4
    static let passesNeeded = 2

    struct State: Equatable {
        var level: Int
        var streak: Int
    }

    /// Promote after `passesNeeded` correct answers in a row, drop one level on a miss.
    static func next(_ state: State, correct: Bool) -> State {
        guard state.level < masteredLevel else { return state }
        guard correct else { return State(level: max(1, state.level - 1), streak: 0) }

        let streak = state.streak + 1
        if streak >= passesNeeded { return State(level: state.level + 1, streak: 0) }
        return State(level: state.level, streak: streak)
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
