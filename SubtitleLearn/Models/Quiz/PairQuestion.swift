import Foundation

/// Level 2 and the level 3 listening question: pick two parts that both belong to one word.
struct PairQuestion {
    enum Prompt { case word, meaning, audio }

    let prompt: Prompt
    let word: String      // the word being asked about, spoken for audio prompts
    let pinyin: String    // its pinyin, for the feedback line
    let meaning: String   // shown as the prompt for .meaning
    let first: QuizColumn     // the pinyin, or the word for the listening question
    let second: QuizColumn    // the meaning, or the word when the prompt is the meaning
}
