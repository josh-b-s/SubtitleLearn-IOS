import SwiftUI
import SwiftData

/// What a screen share session heard, line by line. Tap a word to look it up or save it.
struct TranscriptView: View {
    let lines: [String]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var savedWords: [SavedWord]
    @State private var dictionary: ChineseDictionary?
    @State private var selectedToken: WordToken?

    private var savedSet: Set<String> { Set(savedWords.map(\.word)) }

    var body: some View {
        NavigationStack {
            Group {
                if lines.isEmpty {
                    ContentUnavailableView("No transcript yet", systemImage: "text.alignleft",
                                           description: Text("Lines appear here as they are heard."))
                } else if let dictionary {
                    transcript(dictionary)
                } else {
                    ProgressView()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Transcript")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
        .task { dictionary = await DictionaryLoader.shared.value }
        .sheet(item: $selectedToken) { token in
            WordDetailSheet(token: token, isSaved: savedSet.contains(token.text), level: savedWord(for: token)?.levelBinding) {
                toggleSaved(token)
                selectedToken = nil
            }
        }
    }

    private func transcript(_ dictionary: ChineseDictionary) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(lines.indices, id: \.self) { index in
                    FlowLayout(spacing: 12) {
                        ForEach(dictionary.tokens(for: lines[index])) { token in
                            WordCard(token: token, isSaved: savedSet.contains(token.text))
                                .onTapGesture { selectedToken = token }
                        }
                    }
                }
            }
            .padding(16)
        }
        .defaultScrollAnchor(.bottom)
        .sensoryFeedback(.selection, trigger: savedWords.count)
    }

    private func savedWord(for token: WordToken) -> SavedWord? {
        savedWords.first { $0.word == token.text }
    }

    private func toggleSaved(_ token: WordToken) {
        if let existing = savedWord(for: token) {
            modelContext.delete(existing)
        } else {
            modelContext.insert(SavedWord(word: token.text, pinyin: token.pinyin, meanings: token.meanings))
        }
    }
}
