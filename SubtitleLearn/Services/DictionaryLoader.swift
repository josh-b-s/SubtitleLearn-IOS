import Foundation

/// Parses the bundled dictionary once and shares it between screens.
enum DictionaryLoader {
    static let shared: Task<ChineseDictionary?, Never> = Task.detached(priority: .userInitiated) {
        try? ChineseDictionary.loadBundled()
    }
}
