import SwiftUI
import SwiftData

struct VocabularyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var words: [SavedWord]
    @Query private var reviewLogs: [ReviewLog]
    @State private var settings = AppSettings.shared

    @State private var query = ""
    @State private var filter: MasteryFilter?
    @State private var dueOnly = false
    @State private var selected: SavedWord?
    @State private var route: Route?

    private enum Route: Hashable { case dictionary, addKnown }

    private var filtered: [SavedWord] {
        let matching = words.filter { word in
            (filter?.matches(level: word.level) ?? true)
                && (!dueOnly || (!word.isMastered && word.isDue))
                && word.matches(query)
        }
        return settings.vocabularySort.sorted(matching, logs: reviewLogs)
    }

    private var emptyDescription: String {
        if !query.isEmpty { return "No matches for \"\(query)\"." }
        return dueOnly ? "Nothing is due for review today." : "No words at this stage yet."
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

    private var sortMenu: some View {
        Menu {
            Picker("Sort by", selection: $settings.vocabularySort) {
                ForEach(VocabularySort.allCases) { Text($0.rawValue).tag($0) }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.subheadline.weight(.semibold))
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color(.secondarySystemGroupedBackground)))
        }
        .accessibilityLabel("Sort")
    }

    private var list: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                MasteryFilterBar(selection: $filter, dueOnly: $dueOnly)
                sortMenu
                    .padding(.trailing, 16)
            }
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
                        description: Text(emptyDescription)
                    )
                }
            }
        }
    }
}