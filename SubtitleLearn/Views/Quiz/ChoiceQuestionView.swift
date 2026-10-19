import SwiftUI

/// Level 1 body.
struct ChoiceQuestionView: View {
    let question: ChoiceQuestion
    @Binding var selection: String?
    let isRevealed: Bool

    @ScaledMetric(relativeTo: .largeTitle) private var chineseSize = 48
    @ScaledMetric(relativeTo: .title) private var englishSize = 28

    var body: some View {
        VStack(spacing: 20) {
            QuizPromptCard {
                Text(question.prompt)
                    .font(.system(size: question.direction == .chineseToEnglish ? chineseSize : englishSize, weight: .bold))
                    .multilineTextAlignment(.center)
                if !question.hint.isEmpty {
                    Text(question.hint)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                Text(question.direction == .chineseToEnglish ? "What does this mean?" : "Which word means this?")
                    .font(.headline)
                    .padding(.top, 4)
            }

            VStack(spacing: 10) {
                ForEach(Array(question.choices.enumerated()), id: \.element) { index, choice in
                    OptionButton(
                        text: choice,
                        letter: OptionState.letter(index),
                        subtitle: question.choicePinyin[choice],
                        state: .resolve(choice: choice, answer: question.answer, selection: selection, revealed: isRevealed),
                        isLocked: isRevealed
                    ) { selection = choice }
                }
            }
        }
    }
}
