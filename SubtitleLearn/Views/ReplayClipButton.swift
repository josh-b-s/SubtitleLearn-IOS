import SwiftUI

/// Plays the clip of the word as it was heard in a screen share.
struct ReplayClipButton: View {
    let word: String
    @State private var player = AudioClipPlayer()

    var body: some View {
        Button { player.play(word: word) } label: {
            Label(label, systemImage: player.isPlaying ? "speaker.wave.2.fill" : "play.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .disabled(player.isPlaying)
    }

    private var label: String {
        if player.failed { return "Can't play clip" }
        return player.isPlaying ? "Playing…" : "Replay audio"
    }
}
