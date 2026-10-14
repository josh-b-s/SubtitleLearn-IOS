import SwiftUI

/// Top card on the quiz home: how many words are due for review.
struct QuizDueBanner: View {
    let dueCount: Int
    let activeCount: Int

    private var title: String {
        dueCount > 0 ? "\(dueCount) Word\(dueCount == 1 ? "" : "s") Due" : "All caught up"
    }

    private var subtitle: String {
        dueCount > 0 ? "Ready for review today" : "\(activeCount) word\(activeCount == 1 ? "" : "s") still being learned"
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.title)
                .frame(width: 56, height: 56)
                .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.title2.weight(.bold))
                Text(subtitle).font(.subheadline).opacity(0.85)
            }
            Spacer()
        }
        .foregroundStyle(.white)
        .padding(16)
        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
