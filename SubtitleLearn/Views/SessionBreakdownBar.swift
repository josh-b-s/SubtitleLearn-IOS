import SwiftUI

/// Stacked bar and legend splitting a session's words into known, learning and new.
struct SessionBreakdownBar: View {
    let alreadyKnown: Int
    let learning: Int
    let newWords: Int

    static let knownColor = Color.green
    static let learningColor = Color.orange
    static let newColor = Color.blue

    @State private var revealed = false

    private var total: CGFloat { CGFloat(max(alreadyKnown + learning + newWords, 1)) }

    var body: some View {
        VStack(spacing: 14) {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    segment(alreadyKnown, Self.knownColor, width: geo.size.width)
                    segment(learning, Self.learningColor, width: geo.size.width)
                    segment(newWords, Self.newColor, width: geo.size.width)
                }
                .mask(alignment: .leading) {
                    Rectangle().frame(width: geo.size.width * (revealed ? 1 : 0))
                }
            }
            .frame(height: 28)
            .background(Color(.systemGray5))
            .clipShape(Capsule())

            HStack {
                legend(Self.knownColor, "Already known", alreadyKnown)
                legend(Self.learningColor, "Learning", learning)
                legend(Self.newColor, "New", newWords)
            }
        }
        .onAppear { withAnimation(.easeOut(duration: 0.8)) { revealed = true } }
    }

    private func segment(_ count: Int, _ color: Color, width: CGFloat) -> some View {
        Rectangle()
            .fill(color)
            .frame(width: width * CGFloat(count) / total, height: 28)
    }

    private func legend(_ color: Color, _ label: String, _ count: Int) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 0) {
                Text("\(count)").font(.subheadline.weight(.bold))
                Text(label).font(.caption).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
