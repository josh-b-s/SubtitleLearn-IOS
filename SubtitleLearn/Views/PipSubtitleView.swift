import SwiftUI

/// The view rendered into the PiP window. The PiP size is set by the caller, see `pipSize`.
struct PipSubtitleView: View {
    @ObservedObject var model: PipSubtitleModel

    /// Phone-width, wide aspect so iOS opens the PiP window as wide as it allows.
    static let pipSize = CGSize(width: UIScreen.main.bounds.width, height: 180)

    /// Rows of cards that fit in the panel.
    static let maxRows = 2

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [Color(white: 0.92), Color(white: 0.82)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            if model.lines.isEmpty {
                Text("Listening…")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                SubtitleLineLayout(spacing: 8, maxRows: Self.maxRows) {
                    ForEach(model.lines) { line in
                        ForEach(line.tokens) { token in
                            PipWordCard(token: token)
                                .layoutValue(key: LineStartKey.self, value: token.id == 0)
                        }
                    }
                }
                .clipped()
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }
}
