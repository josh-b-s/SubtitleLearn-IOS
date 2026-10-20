import Foundation

/// Level 3: a short sentence with the target word blanked out, plus its pinyin and meaning.
struct ClozeQuestion {
    let before: [WordToken]   // tokens left of the blank, tappable for pinyin and meaning
    let after: [WordToken]    // tokens right of the blank
    let translation: String   // English clue so only the target word fits
    let choices: [String]     // word bank
    let answer: String
    let pinyin: QuizColumn    // pinyin of the answer, so a lucky word guess isn't enough
    let meaning: QuizColumn
}
