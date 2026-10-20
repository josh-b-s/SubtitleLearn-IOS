import Foundation
import os

/// Keeps the latest session's transcript in one JSON file. Saving replaces the previous one.
enum SessionTranscriptStore {
    private static let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "SubtitleLearn", category: "transcript")
    private static let directory = URL.applicationSupportDirectory
    private static let fileURL = directory.appending(path: "session-transcript.json")

    static func load() -> SessionTranscript {
        guard let data = try? Data(contentsOf: fileURL) else { return SessionTranscript() }
        do {
            return try JSONDecoder().decode(SessionTranscript.self, from: data)
        } catch {
            log.error("Couldn't read transcript: \(error.localizedDescription)")
            return SessionTranscript()
        }
    }

    static func save(_ transcript: SessionTranscript) {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try JSONEncoder().encode(transcript).write(to: fileURL, options: .atomic)
        } catch {
            log.error("Couldn't save transcript: \(error.localizedDescription)")
        }
    }
}
