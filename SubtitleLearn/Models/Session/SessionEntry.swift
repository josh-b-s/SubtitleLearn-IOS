import Foundation

/// A word heard during a screen share session and how many times.
struct SessionEntry: Equatable, Identifiable {
    let token: WordToken
    var count: Int

    var id: String { token.text }
}
