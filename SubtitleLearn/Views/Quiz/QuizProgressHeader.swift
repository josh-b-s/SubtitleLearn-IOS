import SwiftUI

/// "4 / 10", percent complete and a bar, shown above each question.
struct QuizProgressHeader: View {
    let index: Int
    let total: Int
    let fraction: Double

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(index) / \(total)")
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
                Spacer()
                Text("\(Int((fraction * 100).rounded()))% Complete")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: fraction)
                .animation(.easeOut(duration: 0.25), value: fraction)
        }
    }
}
