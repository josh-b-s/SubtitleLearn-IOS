import SwiftUI
import SwiftData

/// Quiz start screen: words due, past quizzes, and the button that starts a review.
struct QuizHomeView: View {
    let dueCount: Int
    let activeCount: Int
    let onStart: () -> Void

    @Query(sort: \QuizRecord.date, order: .reverse) private var records: [QuizRecord]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                QuizDueBanner(dueCount: dueCount, activeCount: activeCount)

                VStack(alignment: .leading, spacing: 12) {
                    Text("History").font(.title3.weight(.bold))
                    if records.isEmpty {
                        Text("Quizzes you take show up here.").foregroundStyle(.secondary)
                    } else {
                        ForEach(records) { record in
                            NavigationLink {
                                QuizHistoryDetailView(record: record)
                            } label: {
                                QuizHistoryCard(record: record)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            Button(action: onStart) {
                Text("Start Review Session").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }
}
