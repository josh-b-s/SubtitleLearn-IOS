import SwiftUI

/// Search states and results shared by the Dictionary and Add Known Word screens.
struct DictionaryResultsList: View {
    let viewModel: DictionarySearchViewModel
    let query: String
    let savedWords: Set<String>
    var selectedWord: String? = nil
    let onSelect: (DictionaryMatch) -> Void
    let onAddCustom: () -> Void

    private var trimmedQuery: String { query.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        if trimmedQuery.isEmpty {
            ContentUnavailableView(
                "Search the dictionary",
                systemImage: "magnifyingglass",
                description: Text("Find a word by its Chinese characters, pinyin or English meaning.")
            )
        } else if viewModel.isSearching && viewModel.results.isEmpty {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.results.isEmpty {
            ContentUnavailableView {
                Label("No matches", systemImage: "magnifyingglass")
            } description: {
                Text("Nothing found for \"\(trimmedQuery)\". You can add it yourself.")
            } actions: {
                Button("Add as custom word", action: onAddCustom)
            }
        } else {
            List(viewModel.results) { match in
                Button { onSelect(match) } label: {
                    DictionaryResultRow(
                        match: match,
                        isSaved: savedWords.contains(match.word),
                        isSelected: selectedWord == match.word
                    )
                }
                .buttonStyle(.plain)
                .accessibilityHint("Opens the word details")
            }
        }
    }
}
