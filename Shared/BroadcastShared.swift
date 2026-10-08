import Foundation

/// Constants and file helpers shared by the app and the broadcast extension.
/// Add this file to BOTH targets. The two processes talk through plain files
/// in an App Group folder: audio chunks, a "broadcast is live" marker, and a stop request.
enum BroadcastShared {
    /// Defaults to "group.<app bundle id>". Set this if you named your App Group differently.
    static let appGroupOverride: String? = nil

    /// Audio is converted to 16 kHz mono Float32 before it is written.
    static let sampleRate: Double = 16_000
    static let chunkSamples = 4_000   // 0.25 s per chunk file

    static var appGroupID: String {
        if let appGroupOverride { return appGroupOverride }
        let id = Bundle.main.bundleIdentifier ?? ""
        let isExtension = Bundle.main.bundleURL.pathExtension == "appex"
        let hostID = isExtension ? id.split(separator: ".").dropLast().joined(separator: ".") : id
        return "group." + hostID
    }

    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }

    static var audioDirectory: URL? { containerURL?.appendingPathComponent("audio", isDirectory: true) }
    private static var markerURL: URL? { containerURL?.appendingPathComponent("broadcast.active") }
    private static var stopURL: URL? { containerURL?.appendingPathComponent("broadcast.stop") }

    static func chunkURL(_ sequence: Int) -> URL? {
        audioDirectory?.appendingPathComponent(String(format: "chunk-%010d.pcm", sequence))
    }

    // MARK: - Broadcast state

    static var isBroadcastActive: Bool {
        guard let markerURL else { return false }
        return FileManager.default.fileExists(atPath: markerURL.path)
    }

    static func setBroadcastActive(_ active: Bool) {
        guard let markerURL else { return }
        if active {
            try? Data([1]).write(to: markerURL)
        } else {
            try? FileManager.default.removeItem(at: markerURL)
        }
    }

    /// App asks the extension to end the broadcast.
    static func requestStop() {
        guard let stopURL else { return }
        try? Data([1]).write(to: stopURL)
    }

    /// Extension checks for a stop request and clears it.
    static func consumeStopRequest() -> Bool {
        guard let stopURL, FileManager.default.fileExists(atPath: stopURL.path) else { return false }
        try? FileManager.default.removeItem(at: stopURL)
        return true
    }

    /// Clears leftovers from a previous session and recreates the audio folder.
    static func reset() {
        guard let audioDirectory else { return }
        try? FileManager.default.removeItem(at: audioDirectory)
        try? FileManager.default.createDirectory(at: audioDirectory, withIntermediateDirectories: true)
        setBroadcastActive(false)
        if let stopURL { try? FileManager.default.removeItem(at: stopURL) }
    }
}
