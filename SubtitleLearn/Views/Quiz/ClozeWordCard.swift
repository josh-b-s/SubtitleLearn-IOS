import SwiftUI

/// One word of the cloze sentence. Pinyin and meaning follow the word's mastery level, and a tap shows the hidden ones.
struct ClozeWordCard: View {
    static let baseWordSize: CGFloat = 26
    static let cornerRadius: CGFloat = 14

    let token: WordToken
    let showsHidden: Bool
    let onTap: () -> Void

    @ScaledMetric(relativeTo: .title) private var wordSize = Self.baseWordSize
    @ScaledMetric(relativeTo: .body) private var maxWidth = 150

    private var pinyin: String? {
        token.pinyin.isEmpty || (token.hidePinyin && !showsHidden) ? nil : token.pinyin
    }

    private var meaning: String? {
        token.meanings.isEmpty || (token.hideMeaning && !showsHidden) ? nil : token.meanings.joined(separator: " · ")
    }

    private var hasHiddenHints: Bool {
        (token.hidePinyin && !token.pinyin.isEmpty) || (token.hideMeaning && !token.meanings.isEmpty)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text(token.text).font(.system(size: wordSize, weight: .semibold))
                if let pinyin {
                    Text(pinyin).font(.footnote).foregroundStyle(Color.accentColor)
                }
                if let meaning {
                    Text(meaning).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(maxWidth: maxWidth)
            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityHint(hasHiddenHints && !showsHidden ? "Shows its pinyin and meaning" : "")
    }
}
