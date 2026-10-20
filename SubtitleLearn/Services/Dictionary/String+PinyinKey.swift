import Foundation

extension String {
    /// Lowercase, no tone marks, no spaces, so "xi huan", "xihuan" and "xǐhuan" compare equal.
    var pinyinKey: String {
        folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .filter { !$0.isWhitespace }
    }
}
