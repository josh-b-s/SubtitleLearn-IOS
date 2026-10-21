import SwiftUI

/// One dictionary hit: word, pinyin, meanings, with badges for custom and saved words.
struct DictionaryResultRow: View {
    let match: DictionaryMatch
    let isSaved: Bool
    var isSelected = false

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(match.word).font(.title3.weight(.semibold))
                    Text(match.entry.pinyin).font(.subheadline).foregroundStyle(.secondary)
                    if match.isCustom {
                        Text("Custom")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.15), in: Capsule())
                            .foregroundStyle(Color.accentColor)
                    }
                }
                Text(match.entry.meanings.joined(separator: " · "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.accentColor)
            } else if isSaved {
                Image(systemName: "bookmark.fill").font(.footnote).foregroundStyle(Color.accentColor)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityValue([isSaved ? "Saved" : nil, isSelected ? "Selected" : nil].compactMap { $0 }.joined(separator: ", "))
    }
}
