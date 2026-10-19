import AVFoundation
import Observation

/// Plays a stored word clip.
@MainActor
@Observable
final class AudioClipPlayer: NSObject, AVAudioPlayerDelegate {
    private(set) var isPlaying = false
    private(set) var failed = false
    @ObservationIgnored private var player: AVAudioPlayer?

    func play(word: String) {
        guard !isPlaying, let url = AudioClipStore.url(for: word) else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio)
            try session.setActive(true)
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.delegate = self
            player = newPlayer
            failed = false
            isPlaying = newPlayer.play()
        } catch {
            failed = true
        }
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in self.isPlaying = false }
    }
}
