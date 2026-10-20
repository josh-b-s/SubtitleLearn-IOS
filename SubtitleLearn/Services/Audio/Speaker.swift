import AVFoundation

/// Speaks Chinese text with the system voice. One shared synthesizer so taps never overlap.
@MainActor
final class Speaker {
    static let shared = Speaker()
    private let synthesizer = AVSpeechSynthesizer()

    /// A tap should always be heard. Autoplay passes false so it stays quiet when the phone is on silent.
    func speak(_ text: String, ignoringMuteSwitch: Bool) {
        // Speech still plays if this fails, it just follows the mute switch either way.
        let session = AVAudioSession.sharedInstance()
        if ignoringMuteSwitch {
            try? session.setCategory(.playback, mode: .spokenAudio)
        } else {
            try? session.setCategory(.ambient, mode: .default)
        }
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        synthesizer.speak(utterance)
    }
}
