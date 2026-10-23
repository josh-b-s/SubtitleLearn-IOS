import Foundation

/// What the learner picked.
enum QuizAnswer {
    case choice(String)
    case pair(first: String, second: String)
    case cloze(word: String, pinyin: String, meaning: String)
}
