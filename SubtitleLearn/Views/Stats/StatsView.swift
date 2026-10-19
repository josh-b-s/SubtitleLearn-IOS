import SwiftUI
import SwiftData

/// Progress screen: streak, review accuracy, word progress over time and activity.
struct StatsView: View {
    @Query private var logs: [ReviewLog]
    @Query private var words: [SavedWord]
    @State private var period: StatsPeriod = .month
    @Environment(\.dynamicTypeSize) private var typeSize

    private var statCardLayout: AnyLayout {
        typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))
    }

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

                StatsSectionCard(title: "Words over time") {
                    WordProgressChart(weeks: stats.weekly, gainedThisWeek: stats.learnedThisWeek)
                }
                
                statCardLayout {
                    StatCard(value: "\(stats.reviews)", label: "Reviews")
                    StatCard(
                        value: stats.accuracy.map { "\(Int(($0 * 100).rounded()))%" } ?? "n/a",
                        label: "Accuracy",
                        detail: stats.reviews == 0 ? nil : "\(stats.correct) of \(stats.reviews) correct",
                        accent: accuracyColor(stats.accuracy)
                    )
                }
                .fixedSize(horizontal: false, vertical: true)   // lets the shorter card stretch to match

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

    private func accuracyColor(_ accuracy: Double?) -> Color? {
        guard let accuracy else { return nil }
        if accuracy >= 0.85 { return .green }
        if accuracy >= 0.70 { return .orange }
        return .red
    }
}
