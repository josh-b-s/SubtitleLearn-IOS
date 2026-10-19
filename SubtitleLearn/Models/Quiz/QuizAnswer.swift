import Foundation

/// What the learner picked. Cloze questions use `.choice`.
enum QuizAnswer {
    case choice(String)
    case pair(pinyin: String, meaning: String)
}
