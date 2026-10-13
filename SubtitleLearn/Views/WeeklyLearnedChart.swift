import SwiftUI
import Charts

/// Running total of words learned over the last 12 weeks.
struct WeeklyLearnedChart: View {
    let weeks: [WeeklyLearned]
    let total: Int
    let gainedThisWeek: Int

    var body: some View {
        if total == 0 {
            Text("Not enough data yet")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 160)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(total)")
                            .font(.title.weight(.bold))
                            .foregroundStyle(Color.accentColor)
                        Text("total words learned")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if gainedThisWeek > 0 {
                        Text("+\(gainedThisWeek) this week")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.green)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
                    }
                }
                chart
            }
        }
    }

    private var chart: some View {
        Chart(weeks) { week in
            AreaMark(
                x: .value("Week", week.weekStart, unit: .weekOfYear),
                y: .value("Words", week.total)
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.accentColor.opacity(0.3), Color.accentColor.opacity(0.02)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            LineMark(
                x: .value("Week", week.weekStart, unit: .weekOfYear),
                y: .value("Words", week.total)
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(Color.accentColor)
            .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))

            if week.id == weeks.last?.id {
                PointMark(
                    x: .value("Week", week.weekStart, unit: .weekOfYear),
                    y: .value("Words", week.total)
                )
                .foregroundStyle(Color.accentColor)
            }
        }
        .chartYScale(domain: 0...max(total, 1))
        .chartXAxis {
            AxisMarks(values: .stride(by: .weekOfYear, count: 4)) {
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .frame(height: 160)
    }
}
