import SwiftUI
import SwiftData

struct VocabularyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedWord.dateAdded, order: .reverse) private var words: [SavedWord]

    @State private var query = ""
    @State private var filter: MasteryStatus?
    @State private var selected: SavedWord?
    @State private var route: Route?

    private enum Route: Hashable { case dictionary, addKnown }

    private var filtered: [SavedWord] {
        words.filter { word in
            (filter == nil || MasteryStatus(level: word.level) == filter) && word.matches(query)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VocabularyShortcuts(
                    onDictionary: { route = .dictionary },
                    onAddKnown: { route = .addKnown }
                )
                if words.isEmpty {
                    ContentUnavailableView(
                        "No saved words yet",
                        systemImage: "bookmark",
                        description: Text("Tap a word on the Translate tab, or use the buttons above to add one.")
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    list
                }
            }
            .navigationDestination(item: $route) { route in
                switch route {
                case .dictionary: DictionaryView()
                case .addKnown: AddKnownWordView()
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
            MasteryFilterBar(selection: $filter)
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            ForEach(filtered) { word in
                Button { selected = word } label: { VocabularyRow(word: word) }
                    .buttonStyle(.plain)
            }
            .onDelete { offsets in
                let current = filtered
                offsets.forEach { modelContext.delete(current[$0]) }
            }
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
