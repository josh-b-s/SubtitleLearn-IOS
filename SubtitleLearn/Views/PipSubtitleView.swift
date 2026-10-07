import SwiftUI

/// The view rendered into the PiP window. Fixed size so the PiP aspect ratio stays stable.
struct PipSubtitleView: View {
    @ObservedObject var model: PipSubtitleModel

    static let size = CGSize(width: 320, height: 200)

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [Color(white: 0.92), Color(white: 0.82)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            if model.tokens.isEmpty {
                Text("Waiting for speech…")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(model.tokens) { PipWordCard(token: $0) }
                }
                .padding(12)
            }
        }
        .frame(width: Self.size.width, height: Self.size.height)
    }
}
