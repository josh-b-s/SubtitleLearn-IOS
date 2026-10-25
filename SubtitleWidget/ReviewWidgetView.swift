import SwiftUI

struct ReviewWidgetView: View {
    let entry: ReviewEntry

    private var dueCaption: String {
        entry.dueCount == 0 ? "All caught up" : "word\(entry.dueCount == 1 ? "" : "s")"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Due today")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("\(entry.dueCount)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
            Text(dueCaption)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
            Label(streakText, systemImage: "flame.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(entry.streak > 0 ? Color.orange : Color.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var streakText: String {
        entry.streak > 0 ? "\(entry.streak) day streak" : "No streak"
    }
}
