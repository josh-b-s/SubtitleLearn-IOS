import SwiftUI
import SwiftData

/// Pick any dictionary word and add it to Vocabulary at the level you already know it.
struct AddKnownWordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var savedWords: [SavedWord]

    @State private var viewModel = DictionarySearchViewModel()
    @State private var query = ""
    @State private var refresh = 0
    @State private var selected: DictionaryMatch?
    @State private var level = 3
    @State private var showingForm = false

    private var savedSet: Set<String> { Set(savedWords.map(\.word)) }

    var body: some View {
        DictionaryResultsList(
            viewModel: viewModel,
            query: query,
            savedWords: savedSet,
            selectedWord: selected?.word,
            onSelect: select,
            onAddCustom: { showingForm = true }
        )
        .navigationTitle("Add known word")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, prompt: "Search word, pinyin or meaning…")
        .task(id: "\(query)|\(refresh)") { await viewModel.search(query) }
        .safeAreaInset(edge: .bottom) {
            if let selected { gradePanel(selected) }
        }
        .sheet(isPresented: $showingForm) {
            CustomWordForm(initialWord: query.filter(\.isHanCharacter), onSaved: { refresh += 1 })
        }
    }

    private func existing(_ match: DictionaryMatch) -> SavedWord? {
        savedWords.first { $0.word == match.word }
    }

    private func select(_ match: DictionaryMatch) {
        selected = match
        level = existing(match)?.level ?? 3
    }

    private func gradePanel(_ match: DictionaryMatch) -> some View {
        let saved = existing(match)
        return VStack(spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(match.word).font(.title2.weight(.bold))
                Text(match.entry.pinyin).foregroundStyle(Color.accentColor)
                Spacer()
                Button { selected = nil } label: { Image(systemName: "xmark.circle.fill") }
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Clear selection")
            }

            MasteryPicker(level: $level)

            Button {
                KnownWordAdder.add(match, level: level, existing: saved, into: modelContext)
                dismiss()
            } label: {
                Text(saved == nil ? "Add to Vocabulary" : "Update level")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 32)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 18))
            .controlSize(.large)
        }
        .padding(16)
        .background(.bar)
    }
}
