import SwiftUI

/// Mastered words as a share of saved words.
struct CoverageBar: View {
    let mastered: Int
    let saved: Int
    let fraction: Double

    @State private var shown = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(mastered) mastered of \(saved) saved")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int((fraction * 100).rounded()))%")
                    .font(.subheadline.weight(.bold))
            }
            GeometryReader { geo in
                Capsule()
                    .fill(Color(.systemGray5))
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(Color.green)
                            .frame(width: geo.size.width * (shown ? fraction : 0))
                    }
            }
            .frame(height: 12)
        }
        .onAppear { withAnimation(.easeOut(duration: 0.8)) { shown = true } }
    }
}
