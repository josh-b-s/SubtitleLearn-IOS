import SwiftUI

/// One row of the "most heard" list: word, pinyin, and a bar scaled to the top count.
struct SessionTopWordRow: View {
    let entry: SessionEntry
    let maxCount: Int

    var body: some View {
        HStack(spacing: 12) {
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
            .frame(width: 96, alignment: .leading)

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

            Text("×\(entry.count)")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(width: 36, alignment: .trailing)
        }
    }
}
