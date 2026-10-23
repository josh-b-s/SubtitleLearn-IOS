import SwiftUI

/// Level 2 and listening body: two columns of options, one pick from each.
struct PairQuestionView: View {
    let question: PairQuestion
    @Binding var first: String?
    @Binding var second: String?
    let isRevealed: Bool

    @ScaledMetric(relativeTo: .largeTitle) private var wordSize = 52
    @ScaledMetric(relativeTo: .title) private var meaningSize = 28

    var body: some View {
        VStack(spacing: 20) {
            QuizPromptCard {
                prompt
                Text("Pick the \(question.first.title.lowercased()) and the \(question.second.title.lowercased())")
                    .font(.headline)
                    .padding(.top, 4)
            }

            QuizColumnsView(
                first: question.first, second: question.second,
                firstSelection: $first, secondSelection: $second,
                isRevealed: isRevealed
            )
        }
    }

    @ViewBuilder private var prompt: some View {
        switch question.prompt {
        case .word:
            Text(question.word)
                .font(.system(size: wordSize, weight: .bold))
        case .meaning:
            Text(question.meaning)
                .font(.system(size: meaningSize, weight: .bold))
                .multilineTextAlignment(.center)
        case .audio:
            SpeakButton(word: question.word)
                .task { Speaker.shared.speak(question.word, ignoringMuteSwitch: false) }
        }
    }
}
