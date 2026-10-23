import SwiftUI

/// One saved word: mastery badge, word, pinyin, meanings, chevron.
struct VocabularyRow: View {
    let word: SavedWord
    var isPicked: Bool? = nil   // set while choosing words to delete; nil otherwise

    @ScaledMetric(relativeTo: .body) private var badgeSize = 32

    private var status: MasteryStatus { MasteryStatus(level: word.level) }

    var body: some View {
        HStack(spacing: 12) {
            if let isPicked {
                Image(systemName: isPicked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isPicked ? Color.accentColor : Color.secondary)
                    .accessibilityHidden(true)
            }

            badge

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
            if isPicked == nil {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityValue(status == .mastered ? status.rawValue : "\(status.rawValue), level \(word.masteryLabel)")
        .accessibilityAddTraits(isPicked == true ? .isSelected : [])
        .accessibilityHint(isPicked == nil ? "Opens the word details" : "Selects this word for deletion")
    }

    /// The number is the level plus progress through it, such as 2.5. Mastered words show a check instead.
    private var badge: some View {
        ZStack {
            Circle().strokeBorder(status.color, lineWidth: 2)
            if status == .mastered {
                Image(systemName: "checkmark")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(Color.successText)
            } else {
                Text(word.masteryLabel)
                    .font(.footnote.weight(.bold))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(width: badgeSize, height: badgeSize)
        .accessibilityHidden(true)
    }
}
