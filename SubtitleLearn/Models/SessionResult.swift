import Foundation

/// Everything heard in one finished session. The id makes each session distinct for onChange.
struct SessionResult: Equatable, Identifiable {
    let id = UUID()
    let entries: [SessionEntry]
}
