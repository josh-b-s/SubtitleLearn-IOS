import SwiftUI

/// Every question from one quiz with its right answer and a mark for the first try.
struct QuizHistoryDetailView: View {
    let record: QuizRecord

    var body: some View {
        List {
            Section("\(record.correctCount) of \(record.items.count) right on the first try") {
                ForEach(Array(record.items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: item.correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(item.correct ? Color.green : Color.red)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.prompt).font(.headline)
                            Text("Answer: \(item.answer)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(record.date.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
    }
}
