import SwiftUI

/// One row of the "most heard" list: word, pinyin, and a bar scaled to the top count.
struct SessionTopWordRow: View {
    let entry: SessionEntry
    let maxCount: Int

    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric private var wordWidth = 96
    @ScaledMetric private var countWidth = 36

    var body: some View {
        if typeSize.isAccessibilitySize {
            // The fixed word column would leave no room for the bar, so stack instead.
            VStack(alignment: .leading, spacing: 6) {
                word
                HStack(spacing: 12) {
                    bar
                    count
                }
            }
        } else {
            HStack(spacing: 12) {
                word.frame(width: wordWidth, alignment: .leading)
                bar
                count
            }
        }
    }

    private var word: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(entry.token.text)
                .font(.title3.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(entry.token.pinyin)
                .font(.caption)
                .foregroundStyle(Color.accentColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private var bar: some View {
        GeometryReader { geo in
            Capsule()
                .fill(Color(.systemGray5))
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: geo.size.width * CGFloat(entry.count) / CGFloat(max(maxCount, 1)))
                }
        }
        .frame(height: 14)
    }

    private var count: some View {
        Text("×\(entry.count)")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(minWidth: countWidth, alignment: .trailing)
    }
}
