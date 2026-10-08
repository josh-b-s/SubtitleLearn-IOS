import Foundation
import Combine

/// One utterance, shown on its own line.
struct PipLine: Identifiable {
    let id: Int
    let tokens: [WordToken]
}

/// Holds the lines shown in the PiP window. The view shows the newest rows.
/// ObservableObject (not @Observable) so ImageRenderer reliably re-renders.
@MainActor
final class PipSubtitleModel: ObservableObject {
    /// Cap on cards kept; the oldest whole lines are dropped past it.
    static let maxTokens = 40

    @Published private(set) var lines: [PipLine] = []

    private var committed: [PipLine] = []
    private var nextID = 0

    /// `segment` is the current (possibly partial) utterance. When `isFinal`,
    /// it becomes a finished line and the next utterance starts a new one.
    func update(segment: [WordToken], isFinal: Bool) {
        guard !segment.isEmpty else {
            lines = committed
            return
        }
        let indexed = segment.enumerated().map { index, token in
            WordToken(id: index, text: token.text, pinyin: token.pinyin, meanings: token.meanings)
        }
        lines = committed + [PipLine(id: nextID, tokens: indexed)]
        if isFinal {
            committed = trimmed(lines)
            lines = committed
            nextID += 1
        }
    }

    func clear() {
        committed = []
        lines = []
    }

    private func trimmed(_ all: [PipLine]) -> [PipLine] {
        var result = all
        while result.count > 1, result.reduce(0, { $0 + $1.tokens.count }) > Self.maxTokens {
            result.removeFirst()
        }
        return result
    }
}
