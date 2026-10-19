import Foundation

/// One question about one saved word, at the word's current level.
struct QuizQuestion: Identifiable {
    enum Kind {
        case choice(ChoiceQuestion)
        case pair(PairQuestion)
        case cloze(ClozeQuestion)
    }

    let id = UUID()
    let word: String      // the SavedWord.word this question reviews
    let level: Int        // difficulty actually asked, which can be below the word's level on fallback
    let kind: Kind
    var isRetry = false   // re-asked after a miss, never graded again
}
