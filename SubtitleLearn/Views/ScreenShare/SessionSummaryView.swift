import SwiftUI

/// Shown after a screen share ends: what was heard, and a shortcut into a review quiz.
struct SessionSummaryView: View {
    let summary: SessionSummary
    let onReview: () -> Void
    let onDone: () -> Void

    private var maxCount: Int { summary.topWords.map(\.count).max() ?? 1 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("\(summary.total) unique word\(summary.total == 1 ? "" : "s") heard")
                        .foregroundStyle(.secondary)

                    card("WORD BREAKDOWN") {
                        SessionBreakdownBar(
                            alreadyKnown: summary.alreadyKnown,
                            learning: summary.learning,
                            newWords: summary.newWords
                        )
                    }

                    if !summary.topWords.isEmpty {
                        card("MOST HEARD") {
                            VStack(spacing: 10) {
                                ForEach(summary.topWords) { entry in
                                    SessionTopWordRow(entry: entry, maxCount: maxCount)
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Session complete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Done", action: onDone) }
            }
            .safeAreaInset(edge: .bottom) { reviewBar }
        }
    }

    @ViewBuilder
    private var reviewBar: some View {
        if !summary.topWords.isEmpty {
            VStack(spacing: 8) {
                Button(action: onReview) {
                    Text("Review \(summary.topWords.count) word\(summary.topWords.count == 1 ? "" : "s")")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 32)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 18))
                .controlSize(.large)
                .accessibilityHint("Starts a quiz on the words you heard most")

                if !summary.unsavedTopWords.isEmpty {
                    let count = summary.unsavedTopWords.count
                    Text("\(count) new word\(count == 1 ? "" : "s") will be saved to your vocabulary.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.bar)
        }
    }

    private func card<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
