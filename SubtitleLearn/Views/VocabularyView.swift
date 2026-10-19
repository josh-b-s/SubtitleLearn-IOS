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
                if words.isEmpty {
                    ContentUnavailableView(
                        "No saved words yet",
                        systemImage: "bookmark",
                        description: Text("Tap a word on the Translate tab, or tap + to add a word you already know.")
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
                if !words.isEmpty { ToolbarItem(placement: .topBarLeading) { EditButton() } }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { route = .dictionary } label: {
                        Label("Dictionary", systemImage: "character.book.closed")
                    }
                    Button { route = .addKnown } label: {
                        Label("Add known word", systemImage: "plus")
                    }
                }
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
        VStack(spacing: 0) {
            MasteryFilterBar(selection: $filter)
                .padding(.vertical, 8)
                .background(Color(.systemGroupedBackground))

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
}