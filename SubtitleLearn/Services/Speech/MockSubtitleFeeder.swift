import Foundation

/// Fake subtitle source for testing PiP when no microphone is available.
@MainActor
final class MockSubtitleFeeder {
    private var task: Task<Void, Never>?
    private let sentences = [
        "我喜欢学习中文",
        "今天天气很好",
        "我们一起去公园玩",
        "你想喝什么",
        "这部电影很有意思"
    ]

    func start(dictionary: ChineseDictionary, into model: PipSubtitleModel) {
        guard task == nil else { return }
        task = Task {
            var index = 0
            while !Task.isCancelled {
                let words = dictionary.tokens(for: sentences[index % sentences.count])
                for count in words.indices {
                    guard !Task.isCancelled else { return }
                    model.update(segment: Array(words.prefix(count + 1)), isFinal: false)
                    try? await Task.sleep(for: .milliseconds(700))
                }
                model.update(segment: words, isFinal: true)
                try? await Task.sleep(for: .seconds(1.5))
                index += 1
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }
}
