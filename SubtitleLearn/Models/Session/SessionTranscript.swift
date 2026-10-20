import Foundation

/// The Chinese text heard in one screen share session, one entry per finished utterance.
struct SessionTranscript: Codable, Equatable {
    var startedAt = Date()
    var lines: [String] = []
}
