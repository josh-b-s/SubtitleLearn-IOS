import Foundation

/// Everything heard in one finished session. The id makes each session distinct for onChange.
struct SessionResult: Equatable, Identifiable {
    let id = UUID()
    let entries: [SessionEntry]
    /// Short screen audio snapshot per word, 16-bit mono. Empty for mic and mock sessions.
    let clips: [String: [Int16]]

    static func == (lhs: SessionResult, rhs: SessionResult) -> Bool { lhs.id == rhs.id }
}
