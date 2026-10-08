import SwiftUI
import SwiftData

struct VocabularyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedWord.dateAdded, order: .reverse) private var words: [SavedWord]

    @State private var query = ""
    @State private var filter: MasteryStatus?
    @State private var selected: SavedWord?

    private var filtered: [SavedWord] {
        words.filter { word in
            (filter == nil || MasteryStatus(level: word.level) == filter) && word.matches(query)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if words.isEmpty {
                    ContentUnavailableView(
                        "No saved words yet",
                        systemImage: "bookmark",
                        description: Text("Tap a word on the Translate tab to save it here.")
                    )
                } else {
                    list
                }
            }
            .navigationTitle("Vocabulary")
            .toolbar {
                if !words.isEmpty { ToolbarItem(placement: .topBarTrailing) { EditButton() } }
            }
            .searchable(text: $query, prompt: "Search vocabulary…")
        }
        .sheet(item: $selected) { word in
            WordDetailSheet(token: word.token, isSaved: true, level: word.levelBinding) {
                modelContext.delete(word)
                selected = nil
            }
        }
    }

    private var list: some View {
        List {
            ForEach(filtered) { word in
                Button { selected = word } label: { VocabularyRow(word: word) }
                    .buttonStyle(.plain)
            }
            .onDelete { offsets in
                let current = filtered
                offsets.forEach { modelContext.delete(current[$0]) }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            MasteryFilterBar(selection: $filter)
                .padding(.vertical, 8)
                .background(.bar)
        }
        .overlay {
            if filtered.isEmpty {
                ContentUnavailableView(
                    "No words found",
                    systemImage: "magnifyingglass",
                    description: Text(query.isEmpty ? "No words at this stage yet." : "No matches for \"\(query)\".")
                )
            }
        }
    }
}
