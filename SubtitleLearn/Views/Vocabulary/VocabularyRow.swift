import SwiftUI

/// One saved word: status dot, word, pinyin, meanings, chevron.
struct VocabularyRow: View {
    let word: SavedWord

    private var status: MasteryStatus { MasteryStatus(level: word.level) }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: status.symbol)
                .font(.footnote)
                .foregroundStyle(status.color)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(word.word).font(.title3.weight(.semibold))
                    Text(word.pinyin).font(.subheadline).foregroundStyle(.secondary)
                }
                Text(word.meanings.isEmpty ? "No definition" : word.meanings.joined(separator: " · "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityValue(status.rawValue)
        .accessibilityHint("Opens the word details")
    }
}
