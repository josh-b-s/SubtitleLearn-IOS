import SwiftUI

/// Pinned bar shown while recording. Always visible so stopping is one tap.
struct StopRecordingBar: View {
    let onStop: () -> Void

    var body: some View {
        Button(action: onStop) {
            Label("Stop recording", systemImage: "stop.fill")
                .font(.title3.weight(.semibold))
                .symbolEffect(.pulse)
                .frame(maxWidth: .infinity, minHeight: 36)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 18))
        .controlSize(.large)
        .tint(.red)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.bar)
        .accessibilityLabel("Stop recording")
    }
}
