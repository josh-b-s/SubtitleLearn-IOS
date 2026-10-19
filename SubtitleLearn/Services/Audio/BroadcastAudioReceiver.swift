import AVFoundation

/// Polls the shared folder for audio chunks from the broadcast extension.
@MainActor
final class BroadcastAudioReceiver {
    private var task: Task<Void, Never>?
    private let format = AVAudioFormat(
        commonFormat: .pcmFormatFloat32,
        sampleRate: BroadcastShared.sampleRate,
        channels: 1,
        interleaved: false
    )!

    func resetSharedFolder() {
        BroadcastShared.reset()
    }

    /// `onStarted` fires when the extension reports the broadcast is live,
    /// `onEnded` when it goes away (user stopped it from Control Center, say).
    func start(
        onStarted: @escaping @MainActor () -> Void,
        onBuffer: @escaping @MainActor (AVAudioPCMBuffer) -> Void,
        onEnded: @escaping @MainActor () -> Void
    ) {
        task?.cancel()
        task = Task {
            var sawBroadcast = false
            while !Task.isCancelled {
                let active = BroadcastShared.isBroadcastActive
                if active, !sawBroadcast {
                    sawBroadcast = true
                    onStarted()
                }
                if sawBroadcast { drain(into: onBuffer) }
                if sawBroadcast, !active {
                    onEnded()
                    return
                }
                try? await Task.sleep(for: .milliseconds(150))
            }
        }
    }

    func stop(requestBroadcastEnd: Bool) {
        task?.cancel()
        task = nil
        if requestBroadcastEnd, BroadcastShared.isBroadcastActive {
            BroadcastShared.requestStop()
        }
    }

    private func drain(into onBuffer: @MainActor (AVAudioPCMBuffer) -> Void) {
        guard let directory = BroadcastShared.audioDirectory,
              let names = try? FileManager.default.contentsOfDirectory(atPath: directory.path) else { return }

        // Zero-padded names sort in write order. Temp files from atomic writes don't end in .pcm.
        for name in names.filter({ $0.hasSuffix(".pcm") }).sorted() {
            let url = directory.appendingPathComponent(name)
            defer { try? FileManager.default.removeItem(at: url) }
            guard let data = try? Data(contentsOf: url), let buffer = makeBuffer(from: data) else { continue }
            onBuffer(buffer)
        }
    }

    private func makeBuffer(from data: Data) -> AVAudioPCMBuffer? {
        let frames = data.count / MemoryLayout<Float>.size
        guard frames > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frames)),
              let channel = buffer.floatChannelData?[0] else { return nil }
        buffer.frameLength = AVAudioFrameCount(frames)
        data.withUnsafeBytes { raw in
            if let base = raw.baseAddress { memcpy(channel, base, frames * MemoryLayout<Float>.size) }
        }
        return buffer
    }
}
