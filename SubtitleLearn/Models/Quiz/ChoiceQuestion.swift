import Foundation

/// Level 1: pick the meaning of a word, or the word for a meaning.
struct ChoiceQuestion {
    enum Direction { case chineseToEnglish, englishToChinese }

    let direction: Direction
    let prompt: String   // the word or the meaning being asked about
    let hint: String     // pinyin under a Chinese prompt, empty otherwise
    let choices: [String]
    let answer: String
    var choicePinyin: [String: String] = [:]   // pinyin per choice, set when the choices are Chinese
}
