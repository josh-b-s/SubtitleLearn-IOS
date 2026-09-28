import Foundation
import Observation

@MainActor
@Observable
final class TranslateViewModel {
    var inputText = ""
    private(set) var tokens: [WordToken] = []
    private(set) var hasTranslated = false
    private(set) var isDictionaryReady = false
    private(set) var dictionaryFailedToLoad = false

    private var dictionary: ChineseDictionary?

    var canTranslate: Bool {
        isDictionaryReady && !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func loadDictionary() async {
        guard dictionary == nil else { return }
        let loaded = await Task.detached(priority: .userInitiated) {
            try? ChineseDictionary.loadBundled()
        }.value
        dictionary = loaded
        isDictionaryReady = loaded != nil
        dictionaryFailedToLoad = loaded == nil
    }

    func translate() {
        guard let dictionary else { return }
        tokens = dictionary.tokens(for: inputText)
        hasTranslated = true
    }
}
