import SwiftUI

/// Speaks a word on tap.
struct SpeakButton: View {
    let word: String

    var body: some View {
        Button { Speaker.shared.speak(word, ignoringMuteSwitch: true) } label: {
            Image(systemName: "speaker.wave.3.fill")
                .font(.largeTitle)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
        }
        .buttonStyle(.bordered)
        .accessibilityLabel("Play pronunciation")
        .accessibilityHint("Speaks the word aloud")
    }
}
