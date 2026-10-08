import Foundation

extension SavedWord {
    /// Lets saved words open the same detail sheet as translated words.
    var token: WordToken {
        WordToken(id: 0, text: word, pinyin: pinyin, meanings: meanings)
    }
}
