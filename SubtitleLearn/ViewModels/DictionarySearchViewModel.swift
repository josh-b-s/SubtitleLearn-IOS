import Foundation
import Observation

/// Debounced dictionary search shared by the Dictionary and Add Known Word screens.
@MainActor
@Observable
final class DictionarySearchViewModel {
    private(set) var results: [DictionaryMatch] = []
    private(set) var isSearching = false

    /// Call from `.task(id:)` so a new query cancels the previous one.
    func search(_ query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            results = []
            isSearching = false
            return
        }

        isSearching = true
        try? await Task.sleep(for: .milliseconds(250))
        guard !Task.isCancelled, let dictionary = await DictionaryLoader.shared.value else { return }

        let found = await Task.detached(priority: .userInitiated) { dictionary.search(trimmed) }.value
        guard !Task.isCancelled else { return }
        results = found
        isSearching = false
    }
}
