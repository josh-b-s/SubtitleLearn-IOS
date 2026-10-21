import SwiftUI

/// Two buttons at the top of Vocabulary that open the Dictionary and Add Known Word screens.
struct VocabularyShortcuts: View {
    let onDictionary: () -> Void
    let onAddKnown: () -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            buttons(HStackLayout(spacing: 12))
            buttons(VStackLayout(spacing: 12))
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }

    private func buttons(_ layout: some Layout) -> some View {
        layout {
            Button(action: onDictionary) {
                Label("Dictionary", systemImage: "character.book.closed")
                    .frame(maxWidth: .infinity)
            }
            Button(action: onAddKnown) {
                Label("Add known word", systemImage: "plus.circle")
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
