import SwiftUI
import SwiftData

/// Search the whole dictionary, open a word, save it, or add your own words.
struct DictionaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var savedWords: [SavedWord]

    @State private var viewModel = DictionarySearchViewModel()
    @State private var query = ""
    @State private var refresh = 0
    @State private var selected: DictionaryMatch?
    @State private var showingForm = false

    private var savedSet: Set<String> { Set(savedWords.map(\.word)) }

    var body: some View {
        DictionaryResultsList(
            viewModel: viewModel,
            query: query,
            savedWords: savedSet,
            onSelect: { selected = $0 },
            onAddCustom: { showingForm = true }
        )
        .navigationTitle("Dictionary")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, prompt: "Search word or meaning…")
        .task(id: "\(query)|\(refresh)") { await viewModel.search(query) }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingForm = true } label: { Image(systemName: "plus") }
                    .accessibilityLabel("Add custom word")
            }
        }
        .sheet(isPresented: $showingForm) {
            CustomWordForm(initialWord: query.filter(\.isHanCharacter), onSaved: { refresh += 1 })
        }
        .sheet(item: $selected) { match in
            let saved = savedWords.first { $0.word == match.word }
            WordDetailSheet(token: match.token, isSaved: saved != nil, level: saved?.levelBinding) {
                toggleSaved(match, existing: saved)
                selected = nil
            }
        }
    }

    private func toggleSaved(_ match: DictionaryMatch, existing: SavedWord?) {
        if let existing {
            modelContext.delete(existing)
        } else {
            modelContext.insert(SavedWord(word: match.word, pinyin: match.entry.pinyin, meanings: match.entry.meanings))
        }
    }
}
