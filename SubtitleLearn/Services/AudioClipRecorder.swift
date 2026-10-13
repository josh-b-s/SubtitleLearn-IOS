import AVFoundation

/// Keeps the last few seconds of screen audio and snapshots them the first time a word shows up.
@MainActor
final class AudioClipRecorder {
    static let clipSeconds = 3
    static let maxClips = 50   // about 5 MB, oldest dropped first

    private let sampleRate = Int(BroadcastShared.sampleRate)
    private var ring: [Int16] = []
    private var order: [String] = []
    private(set) var clips: [String: [Int16]] = [:]

    func append(_ buffer: AVAudioPCMBuffer) {
        guard let channel = buffer.floatChannelData?[0] else { return }
        for index in 0..<Int(buffer.frameLength) {
            ring.append(Int16(max(-1, min(1, channel[index])) * Float(Int16.max)))
        }
        let excess = ring.count - sampleRate * Self.clipSeconds
        if excess > 0 { ring.removeFirst(excess) }
    }

    /// First occurrence wins. Words already captured this session keep their clip.
    func captureIfAbsent(_ words: [String]) {
        guard !ring.isEmpty else { return }
        for word in words where clips[word] == nil {
            clips[word] = ring
            order.append(word)
            if order.count > Self.maxClips { clips[order.removeFirst()] = nil }
        }
    }

    func reset() {
        ring = []
        order = []
        clips = [:]
    }
}
