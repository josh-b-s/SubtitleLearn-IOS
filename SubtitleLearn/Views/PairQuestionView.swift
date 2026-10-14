import SwiftUI

/// Level 2 body: pinyin options on the left, meaning options on the right.
struct PairQuestionView: View {
    let question: PairQuestion
    @Binding var pinyin: String?
    @Binding var meaning: String?
    let isRevealed: Bool

    var body: some View {
        VStack(spacing: 20) {
            QuizPromptCard {
                Text(question.word)
                    .font(.system(size: 52, weight: .bold))
                Text("Pick the pinyin and the meaning")
                    .font(.headline)
                    .padding(.top, 4)
            }

            HStack(alignment: .top, spacing: 12) {
                column("PINYIN", choices: question.pinyinChoices, answer: question.pinyinAnswer, selection: $pinyin)
                column("MEANING", choices: question.meaningChoices, answer: question.meaningAnswer, selection: $meaning)
            }
        }
    }

    private func column(_ title: String, choices: [String], answer: String, selection: Binding<String?>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            ForEach(choices, id: \.self) { choice in
                OptionButton(
                    text: choice,
                    state: .resolve(choice: choice, answer: answer, selection: selection.wrappedValue, revealed: isRevealed),
                    font: .body,
                    isLocked: isRevealed
                ) { selection.wrappedValue = choice }
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}
