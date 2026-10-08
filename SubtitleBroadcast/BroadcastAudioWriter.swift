import AVFoundation
import CoreMedia

/// Converts system audio to 16 kHz mono Float32 and writes it as small chunk files
/// into the shared App Group folder for the app to pick up.
final class BroadcastAudioWriter {
    /// Chunks older than this many behind the newest are deleted, in case the app stops reading.
    private static let maxBacklog = 400

    private let targetFormat = AVAudioFormat(
        commonFormat: .pcmFormatFloat32,
        sampleRate: BroadcastShared.sampleRate,
        channels: 1,
        interleaved: false
    )!
    private var sourceFormat: AVAudioFormat?
    private var converter: AVAudioConverter?
    private var pending: [Float] = []
    private var sequence = 0

    init() {
        BroadcastShared.reset()
        BroadcastShared.setBroadcastActive(true)
    }

    func finish() {
        BroadcastShared.setBroadcastActive(false)
    }

    func write(_ sampleBuffer: CMSampleBuffer) {
        guard let description = sampleBuffer.formatDescription else { return }
        let format = AVAudioFormat(cmAudioFormatDescription: description)

        if sourceFormat == nil || sourceFormat != format {
            sourceFormat = format
            converter = AVAudioConverter(from: format, to: targetFormat)
        }

        let frames = AVAudioFrameCount(CMSampleBufferGetNumSamples(sampleBuffer))
        guard frames > 0, let converter,
              let input = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames) else { return }
        input.frameLength = frames

        let copied = CMSampleBufferCopyPCMDataIntoAudioBufferList(
            sampleBuffer, at: 0, frameCount: Int32(frames), into: input.mutableAudioBufferList
        )
        guard copied == noErr else { return }

        let ratio = targetFormat.sampleRate / format.sampleRate
        let capacity = AVAudioFrameCount(Double(frames) * ratio) + 32
        guard let output = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: capacity) else { return }

        var supplied = false
        var error: NSError?
        converter.convert(to: output, error: &error) { _, status in
            if supplied {
                status.pointee = .noDataNow
                return nil
            }
            supplied = true
            status.pointee = .haveData
            return input
        }
        guard error == nil, let channel = output.floatChannelData?[0] else { return }

        pending.append(contentsOf: UnsafeBufferPointer(start: channel, count: Int(output.frameLength)))
        flushChunks()
    }

    private func flushChunks() {
        let size = BroadcastShared.chunkSamples
        while pending.count >= size {
            let data = pending.withUnsafeBufferPointer { Data(buffer: UnsafeBufferPointer(rebasing: $0[0..<size])) }
            pending.removeFirst(size)
            sequence += 1
            if let url = BroadcastShared.chunkURL(sequence) {
                try? data.write(to: url, options: .atomic)
            }
            if sequence > Self.maxBacklog, let old = BroadcastShared.chunkURL(sequence - Self.maxBacklog) {
                try? FileManager.default.removeItem(at: old)
            }
        }
    }
}
