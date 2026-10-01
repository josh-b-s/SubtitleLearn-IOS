import SwiftUI
import SwiftData

struct VocabularyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedWord.dateAdded, order: .reverse) private var words: [SavedWord]

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
                    List {
                        ForEach(words) { word in
                            HStack(alignment: .firstTextBaseline, spacing: 12) {
                                Text(word.word).font(.title2.weight(.semibold))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(word.pinyin).foregroundStyle(Color.accentColor)
                                    Text(word.meanings.isEmpty ? "No definition" : word.meanings.joined(separator: " · "))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if word.repetitions > 0 {
                                    Text(word.isDue ? "Due" : "Reviewed")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(word.isDue ? Color.orange : Color.secondary)
                                        .padding(.horizontal, 8).padding(.vertical, 4)
                                        .background(Capsule().fill((word.isDue ? Color.orange : Color.secondary).opacity(0.15)))
                                }
                            }
                        }
                        .onDelete { offsets in
                            offsets.forEach { modelContext.delete(words[$0]) }
                        }
                    }
                }
            }
            .navigationTitle("Vocabulary")
        }
    }
}
