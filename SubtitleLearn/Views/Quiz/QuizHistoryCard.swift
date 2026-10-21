import SwiftUI

/// One past quiz: score ring, how it went, and when.
struct QuizHistoryCard: View {
    let record: QuizRecord

    @ScaledMetric private var ringSize = 52

    private var fraction: Double {
        record.items.isEmpty ? 0 : Double(record.correctCount) / Double(record.items.count)
    }

    private var summary: String {
        let missed = record.items.count - record.correctCount
        return missed == 0 ? "\(record.correctCount) correct" : "\(record.correctCount) correct, \(missed) to review again"
    }

    var body: some View {
        HStack(spacing: 16) {
            ring
            VStack(alignment: .leading, spacing: 2) {
                Text(summary)
                Text(record.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(record.date.formatted(date: .abbreviated, time: .shortened))
        .accessibilityValue("\(Int((fraction * 100).rounded())) percent. \(summary)")
    }

    private var ring: some View {
        ZStack {
            Circle().stroke(Color(.systemGray5), lineWidth: 5)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int((fraction * 100).rounded()))%")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.accentColor)
        }
        .frame(width: ringSize, height: ringSize)
    }
}
