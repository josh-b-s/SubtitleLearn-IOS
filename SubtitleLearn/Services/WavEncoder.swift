import Foundation

/// Wraps 16-bit mono PCM in a WAV header so AVAudioPlayer can play it.
enum WavEncoder {
    static func data(from samples: [Int16], sampleRate: Int) -> Data {
        let dataSize = samples.count * 2
        var data = Data()
        data.append(contentsOf: Array("RIFF".utf8))
        data.append(le32(36 + dataSize))
        data.append(contentsOf: Array("WAVEfmt ".utf8))
        data.append(le32(16))              // fmt chunk size
        data.append(le16(1))               // PCM
        data.append(le16(1))               // mono
        data.append(le32(sampleRate))
        data.append(le32(sampleRate * 2))  // byte rate
        data.append(le16(2))               // block align
        data.append(le16(16))              // bits per sample
        data.append(contentsOf: Array("data".utf8))
        data.append(le32(dataSize))
        for sample in samples { data.append(le16(Int(UInt16(bitPattern: sample)))) }
        return data
    }

    private static func le16(_ value: Int) -> Data {
        Data([UInt8(value & 0xFF), UInt8((value >> 8) & 0xFF)])
    }

    private static func le32(_ value: Int) -> Data {
        Data([UInt8(value & 0xFF), UInt8((value >> 8) & 0xFF), UInt8((value >> 16) & 0xFF), UInt8((value >> 24) & 0xFF)])
    }
}
