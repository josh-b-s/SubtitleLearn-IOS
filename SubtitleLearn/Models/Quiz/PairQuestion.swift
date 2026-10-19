import Foundation

/// Level 2: pick the pinyin and the meaning that both belong to one word.
struct PairQuestion {
    let word: String
    let pinyinChoices: [String]
    let meaningChoices: [String]
    let pinyinAnswer: String
    let meaningAnswer: String
}
