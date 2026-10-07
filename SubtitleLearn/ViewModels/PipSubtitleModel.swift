import Foundation
import Combine

/// Feeds a mock subtitle stream to the PiP view: words of a sentence appear
/// one by one, then the sentence clears and the next one starts.
/// ObservableObject (not @Observable) so ImageRenderer reliably re-renders.
@MainActor
final class PipSubtitleModel: ObservableObject {
    @Published private(set) var tokens: [WordToken] = []

    private var task: Task<Void, Never>?
    private let sentences = [
        "我喜欢学习中文",
        "今天天气很好",
        "我们一起去公园玩",
        "你想喝什么",
        "这部电影很有意思"
    ]

    func start() {
        guard task == nil else { return }
        task = Task {
            guard let dictionary = await DictionaryLoader.shared.value else { return }
            var index = 0
            while !Task.isCancelled {
                let words = dictionary.tokens(for: sentences[index % sentences.count])
                for count in words.indices {
                    guard !Task.isCancelled else { return }
                    tokens = Array(words.prefix(count + 1))
                    try? await Task.sleep(for: .milliseconds(700))
                }
                try? await Task.sleep(for: .seconds(2))
                tokens = []
                index += 1
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        tokens = []
    }
}
