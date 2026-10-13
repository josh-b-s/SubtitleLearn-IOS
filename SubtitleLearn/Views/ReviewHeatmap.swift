import SwiftUI

/// Calendar-style grid of review counts for the last 90 days. One column per week.
struct ReviewHeatmap: View {
    /// Reviews per day, keyed by start of day.
    let counts: [Date: Int]

    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: .now)

    private var firstDay: Date {
        calendar.date(byAdding: .day, value: -(StatsCalculator.heatmapDays - 1), to: today) ?? today
    }

    private func weekStart(of date: Date) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
    }

    private var columns: Int {
        let weeks = calendar.dateComponents([.weekOfYear], from: weekStart(of: firstDay), to: weekStart(of: today)).weekOfYear ?? 12
        return weeks + 1
    }

    private var maxCount: Int { max(counts.values.max() ?? 1, 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Grid(horizontalSpacing: 3, verticalSpacing: 3) {
                ForEach(0..<7, id: \.self) { row in
                    GridRow {
                        ForEach(0..<columns, id: \.self) { column in
                            cell(row: row, column: column)
                        }
                    }
                }
            }
            Text("Each square is one day. Darker means more reviews.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func cell(row: Int, column: Int) -> some View {
        let origin = weekStart(of: firstDay)
        let date = calendar.date(byAdding: .day, value: column * 7 + row, to: origin) ?? origin
        if date < firstDay || date > today {
            Color.clear.aspectRatio(1, contentMode: .fit)
        } else {
            let count = counts[date] ?? 0
            RoundedRectangle(cornerRadius: 2)
                .fill(count == 0 ? Color(.systemGray5) : Color.blue.opacity(0.25 + 0.75 * Double(count) / Double(maxCount)))
                .aspectRatio(1, contentMode: .fit)
        }
    }
}
