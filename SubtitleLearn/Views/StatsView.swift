import SwiftUI
import SwiftData

/// Progress screen: streak, review numbers, mastery coverage, words learned and activity.
struct StatsView: View {
    @Query private var logs: [ReviewLog]
    @Query private var words: [SavedWord]
    @State private var period: StatsPeriod = .month

    private var snapshot: StatsSnapshot {
        StatsCalculator.snapshot(logs: logs, saved: words, period: period)
    }

    var body: some View {
        let stats = snapshot
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Progress").font(.title2.weight(.bold))
                    Spacer()
                    StreakBadge(days: stats.streak)
                }

                Picker("Period", selection: $period) {
                    ForEach(StatsPeriod.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)

                HStack(spacing: 12) {
                    StatCard(value: "\(stats.wordsSaved)", label: "Words saved")
                    StatCard(value: "\(stats.reviews)", label: "Reviews")
                    StatCard(
                        value: stats.retention.map { "\(Int(($0 * 100).rounded()))%" } ?? "n/a",
                        label: "Retention",
                        accent: retentionColor(stats.retention)
                    )
                }

                StatsSectionCard(title: "Mastery") {
                    CoverageBar(mastered: stats.masteredCount, saved: stats.wordsSaved, fraction: stats.masteredFraction)
                }

                StatsSectionCard(title: "Words learned") {
                    WeeklyLearnedChart(weeks: stats.weekly, total: stats.learnedTotal, gainedThisWeek: stats.learnedThisWeek)
                }

                StatsSectionCard(title: "Review activity (90 days)") {
                    ReviewHeatmap(counts: stats.dailyCounts)
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
        #if DEBUG
        .toolbar { ToolbarItem(placement: .topBarTrailing) { ReviewLogSeedMenu() } }
        #endif
    }

    private func retentionColor(_ retention: Double?) -> Color? {
        guard let retention else { return nil }
        if retention >= 0.85 { return .green }
        if retention >= 0.70 { return .orange }
        return .red
    }
}
