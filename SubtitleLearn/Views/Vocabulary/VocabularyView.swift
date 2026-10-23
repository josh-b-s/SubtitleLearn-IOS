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
    @State private var pendingDelete: [SavedWord] = []
    @State private var isSelecting = false
    @State private var picked: Set<SavedWord.ID> = []

    private enum Route: Hashable { case dictionary, addKnown }

    private var filtered: [SavedWord] {
        let matching = words.filter { word in
            (filter?.matches(level: word.level) ?? true)
                && (!dueOnly || (!word.isMastered && word.isDue))
                && word.matches(query)
        }
        return settings.vocabularySort.sorted(matching, logs: reviewLogs)
    }

    /// Checked words that are still in the filtered list, so a search can't leave hidden words queued for deletion.
    private var pickedWords: [SavedWord] { filtered.filter { picked.contains($0.id) } }

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
                if isSelecting {
                    ToolbarItem(placement: .topBarLeading) { Button("Cancel", action: endSelecting) }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(pickedWords.isEmpty ? "Delete" : "Delete (\(pickedWords.count))", role: .destructive) {
                            pendingDelete = pickedWords
                        }
                        .disabled(pickedWords.isEmpty)
                    }
                } else {
                    if !words.isEmpty { ToolbarItem(placement: .topBarLeading) { Button("Select") { isSelecting = true } } }
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button { route = .dictionary } label: {
                            Label("Dictionary", systemImage: "character.book.closed")
                        }
                        Button { route = .addKnown } label: {
                            Label("Add known word", systemImage: "plus")
                        }
                    }
                }
            }
            .searchable(text: $query, prompt: "Search vocabulary…")
        }
        .sheet(item: $selected) { word in
            WordDetailSheet(token: word.token, isSaved: true, progress: word.progressBinding) {
                modelContext.delete(word)
                selected = nil
            }
        }
    }

    private var deleteTitle: String {
        pendingDelete.count == 1 ? "Delete this word?" : "Delete \(pendingDelete.count) words?"
    }

    private func tap(_ word: SavedWord) {
        guard isSelecting else { selected = word; return }
        if picked.contains(word.id) { picked.remove(word.id) } else { picked.insert(word.id) }
    }

    private func delete(_ doomed: [SavedWord]) {
        doomed.forEach(modelContext.delete)
        endSelecting()
    }

    private func endSelecting() {
        isSelecting = false
        picked = []
    }

    private var sortMenu: some View {
        Menu {
            Picker("Sort by", selection: $settings.vocabularySort) {
                ForEach(VocabularySort.allCases) { Text($0.rawValue).tag($0) }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.subheadline.weight(.semibold))
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color(.secondarySystemGroupedBackground)))
        }
        .accessibilityLabel("Sort")
        .accessibilityValue(settings.vocabularySort.rawValue)
        .accessibilityHint("Changes the order of the word list")
    }

    private var list: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                MasteryFilterBar(selection: $filter, dueOnly: $dueOnly)
                sortMenu
                    .padding(.trailing, 16)
            }
            .padding(.top, 8)
            .padding(.bottom, 2)
            .background(Color(.systemGroupedBackground))

            List {
                ForEach(filtered) { word in
                    Button { tap(word) } label: {
                        VocabularyRow(word: word, isPicked: isSelecting ? picked.contains(word.id) : nil)
                    }
                    .buttonStyle(.plain)
                    .deleteDisabled(isSelecting)
                }
                .onDelete { offsets in
                    let current = filtered
                    pendingDelete = offsets.map { current[$0] }
                }
            }
            .contentMargins(.top, 8, for: .scrollContent)
            .alert(
                deleteTitle,
                isPresented: Binding(get: { !pendingDelete.isEmpty }, set: { if !$0 { pendingDelete = [] } }),
                presenting: pendingDelete.isEmpty ? nil : pendingDelete
            ) { doomed in
                Button("Delete", role: .destructive) { delete(doomed) }
                Button("Cancel", role: .cancel) {}
            } message: { _ in
                Text("Their level and review history are deleted too.")
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
