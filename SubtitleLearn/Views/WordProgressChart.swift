import SwiftUI
import Charts

/// Words learned, saved and mastered over the last 12 weeks. The menu narrows it to one line.
struct WordProgressChart: View {
    let weeks: [WeeklyProgress]
    let gainedThisWeek: Int

    /// Nil shows every line.
    @State private var selection: ProgressSeries?

    private var shown: [ProgressSeries] { selection.map { [$0] } ?? ProgressSeries.allCases }

    private var hasData: Bool {
        guard let latest = weeks.last else { return false }
        return ProgressSeries.allCases.contains { latest.value(for: $0) > 0 }
    }

    var body: some View {
        if hasData {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    totals
                    Spacer()
                    picker
                }
                if shown.contains(.learned) && gainedThisWeek > 0 {
                    Text("+\(gainedThisWeek) learned this week")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
                }
                chart
            }
        } else {
            Text("Not enough data yet")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 160)
        }
    }

    private var totals: some View {
        HStack(spacing: 16) {
            ForEach(shown) { series in
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(weeks.last?.value(for: series) ?? 0)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(series.color)
                    Text(series.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var picker: some View {
        Picker("Show", selection: $selection) {
            Text("All").tag(ProgressSeries?.none)
            ForEach(ProgressSeries.allCases) { series in
                Text(series.label).tag(Optional(series))
            }
        }
        .pickerStyle(.menu)
    }

    private var chart: some View {
        Chart {
            ForEach(shown) { series in
                ForEach(weeks) { week in
                    LineMark(
                        x: .value("Week", week.weekStart, unit: .weekOfYear),
                        y: .value("Words", week.value(for: series)),
                        series: .value("Series", series.label)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(by: .value("Series", series.label))
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                }
                if let last = weeks.last {
                    PointMark(
                        x: .value("Week", last.weekStart, unit: .weekOfYear),
                        y: .value("Words", last.value(for: series))
                    )
                    .foregroundStyle(by: .value("Series", series.label))
                }
            }
        }
        .chartForegroundStyleScale(domain: shown.map(\.label), range: shown.map(\.color))
        .chartYScale(domain: 0...max(peak, 1))
        .chartLegend(shown.count > 1 ? .visible : .hidden)
        .chartXAxis {
            AxisMarks(values: .stride(by: .weekOfYear, count: 4)) {
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .frame(height: 180)
    }

    /// Totals only grow, so the latest week holds each line's highest point.
    private var peak: Int {
        shown.map { weeks.last?.value(for: $0) ?? 0 }.max() ?? 0
    }
}
