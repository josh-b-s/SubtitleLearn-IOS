import Foundation

/// SM-2 spaced repetition, ported from the Android app's SrsStore.review().
/// Quality: 1 = no idea, 3 = roughly right, 5 = got it (same 3 buttons as Android).
enum SpacedRepetition {
    struct State {
        var repetitions: Int
        var easeFactor: Double
        var intervalDays: Int
    }

    static func next(_ state: State, quality: Int) -> State {
        var reps = state.repetitions
        var ef = state.easeFactor
        var interval = state.intervalDays

        if quality < 3 {
            reps = 0
            interval = 1
        } else {
            switch reps {
            case 0: interval = 1
            case 1: interval = 6
            default: interval = max(1, Int((Double(interval) * ef).rounded()))
            }
            reps += 1
        }
        let q = Double(quality)
        ef = max(1.3, ef + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)))

        return State(repetitions: reps, easeFactor: ef, intervalDays: interval)
    }
}

extension SavedWord {
    var isDue: Bool { dueDate <= Calendar.current.startOfDay(for: .now).addingTimeInterval(86_400) }

    /// Applies one SM-2 review and updates dueDate. Call inside a modelContext so it saves.
    func review(quality: Int) {
        let next = SpacedRepetition.next(
            .init(repetitions: repetitions, easeFactor: easeFactor, intervalDays: intervalDays),
            quality: quality
        )
        repetitions = next.repetitions
        easeFactor = next.easeFactor
        intervalDays = next.intervalDays
        dueDate = Calendar.current.date(byAdding: .day, value: next.intervalDays, to: .now) ?? .now
    }
}
