import SwiftUI

/// Two buttons at the top of Vocabulary that open the Dictionary and Add Known Word screens.
struct VocabularyShortcuts: View {
    let onDictionary: () -> Void
    let onAddKnown: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onDictionary) {
                Label("Dictionary", systemImage: "character.book.closed")
                    .frame(maxWidth: .infinity)
            }
            Button(action: onAddKnown) {
                Label("Add known word", systemImage: "plus.circle")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }
}
