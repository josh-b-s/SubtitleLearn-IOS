import Foundation

/// One short WAV clip per word on disk, named after the word's Unicode scalars.
enum AudioClipStore {
    private static var directory: URL? {
        guard let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        let folder = base.appendingPathComponent("AudioClips", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    static func url(for word: String) -> URL? {
        directory?.appendingPathComponent(fileName(for: word))
    }

    static func hasClip(for word: String) -> Bool {
        guard let url = url(for: word) else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }

    /// Makes the folder hold clips for exactly `keep`. Existing clips stay (first occurrence wins),
    /// words in `keep` without one get theirs from `newClips`, everything else is deleted.
    static func sync(newClips: [String: [Int16]], keeping keep: Set<String>, sampleRate: Int) {
        guard let directory else { return }
        let keepNames = Set(keep.map(fileName(for:)))

        let existing = (try? FileManager.default.contentsOfDirectory(atPath: directory.path)) ?? []
        for name in existing where !keepNames.contains(name) {
            try? FileManager.default.removeItem(at: directory.appendingPathComponent(name))
        }

        for word in keep {
            guard let samples = newClips[word], !hasClip(for: word), let url = url(for: word) else { continue }
            try? WavEncoder.data(from: samples, sampleRate: sampleRate).write(to: url, options: .atomic)
        }
    }

    private static func fileName(for word: String) -> String {
        word.unicodeScalars.map { String($0.value, radix: 16) }.joined(separator: "-") + ".wav"
    }
}
