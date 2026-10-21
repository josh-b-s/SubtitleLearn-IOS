import SwiftUI

/// Pinned bar shown while recording: status, the hide-learned toggle, and a one-tap stop.
struct ListeningBar: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let hasTranscript: Bool
    @Binding var hideLearned: Bool
    let onStop: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "waveform")
                    .foregroundStyle(.red)
                    .symbolEffect(.variableColor.iterative, isActive: !reduceMotion)
                    .accessibilityHidden(true)
                Text(hasTranscript ? "Listening…" : "Listening, start speaking…")
                    .foregroundStyle(.secondary)
                .accessibilityAddTraits(.updatesFrequently)
                Spacer()
                if hasTranscript {
                    Toggle(isOn: $hideLearned) {
                        Label("Hide learned", systemImage: "eye.slash")
                    }
                    .toggleStyle(.button)
                    .controlSize(.small)
                    .accessibilityHint("Hides the pinyin and meaning of words you already know")
                }
            }

            Button(action: onStop) {
                Label("Stop recording", systemImage: "stop.fill")
                    .font(.title3.weight(.semibold))
                    .symbolEffect(.pulse, isActive: !reduceMotion)
                    .frame(maxWidth: .infinity, minHeight: 36)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 18))
            .controlSize(.large)
            .tint(.red)
            .accessibilityLabel("Stop recording")
            .accessibilityHint("Stops listening and keeps the transcript")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.bar)
    }
}
