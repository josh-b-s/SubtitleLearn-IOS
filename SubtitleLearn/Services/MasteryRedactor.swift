import Foundation

/// Flags subtitle tokens whose meaning or pinyin the learner has outgrown.
enum MasteryRedactor {
    static func apply(to tokens: [WordToken], levels: [String: Int]) -> [WordToken] {
        tokens.map { token in
            guard let level = levels[token.text] else { return token }
            var flagged = token
            flagged.hideMeaning = !Mastery.showsMeaning(at: level)
            flagged.hidePinyin = !Mastery.showsPinyin(at: level)
            return flagged
        }
    }
}
