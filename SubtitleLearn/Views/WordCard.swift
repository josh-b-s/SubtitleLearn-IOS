import SwiftUI

struct WordCard: View {
    let token: WordToken
    let isSaved: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(token.text)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.primary)

            if !token.pinyin.isEmpty {
                Text(token.pinyin)
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
            }

            Text(token.meanings.isEmpty ? "No definition" : token.meanings.joined(separator: " · "))
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: 240, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(isSaved ? Color.accentColor : .clear, lineWidth: 2)
        )
        .overlay(alignment: .topTrailing) {
            if isSaved {
                Image(systemName: "bookmark.fill")
                    .font(.caption)
                    .foregroundStyle(Color.accentColor)
                    .padding(10)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityHint("Double tap for details and to save")
        .accessibilityAddTraits(isSaved ? .isSelected : [])
    }
}
