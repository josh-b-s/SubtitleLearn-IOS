import SwiftUI

/// GitHub-style grid of review counts for the last 90 days. One column per week, one row per weekday.
struct ReviewHeatmap: View {
    /// Reviews per day, keyed by start of day.
    let counts: [Date: Int]

    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: .now)
    private let levels = 4
    private let labelWidth: CGFloat = 30

    private var firstDay: Date {
        calendar.date(byAdding: .day, value: -(StatsCalculator.heatmapDays - 1), to: today) ?? today
    }

    private var origin: Date { weekStart(of: firstDay) }

    private func weekStart(of date: Date) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
    }

    private var columns: Int {
        let weeks = calendar.dateComponents([.weekOfYear], from: origin, to: weekStart(of: today)).weekOfYear ?? 12
        return weeks + 1
    }

    private var maxCount: Int { max(counts.values.max() ?? 1, 1) }

    private var activeDays: Int { counts.values.filter { $0 > 0 }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Grid(horizontalSpacing: 3, verticalSpacing: 3) {
                GridRow {
                    Color.clear.frame(width: labelWidth, height: 12)
                    ForEach(0..<columns, id: \.self) { monthLabel(column: $0) }
                }
                ForEach(0..<7, id: \.self) { row in
                    GridRow {
                        weekdayLabel(row)
                        ForEach(0..<columns, id: \.self) { cell(row: row, column: $0) }
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Review activity, last \(StatsCalculator.heatmapDays) days: \(activeDays) days with reviews")

            legend
        }
    }

    private func columnDate(_ column: Int) -> Date {
        calendar.date(byAdding: .day, value: column * 7, to: origin) ?? origin
    }

    /// Label the first column of each month. The partial first column only counts if the next one is the same month.
    private func showsMonth(_ column: Int) -> Bool {
        let month = calendar.component(.month, from: columnDate(column))
        if column == 0 { return calendar.component(.month, from: columnDate(1)) == month }
        return month != calendar.component(.month, from: columnDate(column - 1))
    }

    private func monthLabel(column: Int) -> some View {
        Color.clear
            .frame(height: 12)
            .overlay(alignment: .leading) {
                if showsMonth(column) {
                    Text(columnDate(column).formatted(.dateTime.month(.abbreviated)))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .fixedSize()
                }
            }
    }

    /// Every other row, so a Monday-first week shows Mon, Wed, Fri.
    private func weekdayLabel(_ row: Int) -> some View {
        let symbols = calendar.shortWeekdaySymbols
        return Text(row.isMultiple(of: 2) ? symbols[(calendar.firstWeekday - 1 + row) % 7] : "")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .frame(width: labelWidth, alignment: .leading)
    }

    @ViewBuilder
    private func cell(row: Int, column: Int) -> some View {
        let date = calendar.date(byAdding: .day, value: column * 7 + row, to: origin) ?? origin
        if date < firstDay || date > today {
            Color.clear.aspectRatio(1, contentMode: .fit)
        } else {
            RoundedRectangle(cornerRadius: 2)
                .fill(color(level: level(for: counts[date] ?? 0)))
                .aspectRatio(1, contentMode: .fit)
        }
    }

    private var legend: some View {
        HStack(spacing: 4) {
            Spacer()
            Text("Less")
            ForEach(0...levels, id: \.self) { level in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color(level: level))
                    .frame(width: 10, height: 10)
            }
            Text("More")
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
    }

    /// 0 for no reviews, then 1...levels scaled against the busiest day.
    private func level(for count: Int) -> Int {
        guard count > 0 else { return 0 }
        return min(levels, max(1, Int((Double(count) / Double(maxCount) * Double(levels)).rounded(.up))))
    }

    private func color(level: Int) -> Color {
        level == 0 ? Color(.systemGray5) : Color.blue.opacity(Double(level) / Double(levels))
    }
}