import Foundation

/// Parses the bundled dictionary once and shares it between screens.
enum DictionaryLoader {
    private static let base = Task.detached(priority: .userInitiated) {
        try? ChineseDictionary.loadBundled()
    }

    /// Bundled dictionary plus the user's custom words. Custom words are read on each access
    /// so a word added a moment ago is already included.
    static var shared: Task<ChineseDictionary?, Never> {
        Task {
            let loaded = await base.value
            return loaded?.withCustom(CustomDictionaryStore.load())
        }
    }
}
