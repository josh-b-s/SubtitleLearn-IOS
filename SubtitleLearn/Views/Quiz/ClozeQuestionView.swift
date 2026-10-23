import SwiftUI

/// Level 3 body: the English sentence, its words as cards around a blank, a word bank, then pinyin and meaning options.
struct ClozeQuestionView: View {
    let question: ClozeQuestion
    @Binding var selection: String?
    @Binding var pinyin: String?
    @Binding var meaning: String?
    let isRevealed: Bool
    @State private var showingHidden: Set<Int> = []   // cards the learner tapped to see their hidden hints
    @ScaledMetric(relativeTo: .title) private var wordSize = ClozeWordCard.baseWordSize

    var body: some View {
        VStack(spacing: 20) {
            QuizPromptCard(alignment: .leading) {
                Text("Fill in the blank, then pick its pinyin and meaning")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(question.translation)
                    .font(.title3.weight(.semibold))

                FlowLayout(spacing: 8) {
                    ForEach(question.before) { card($0) }
                    blank
                    ForEach(question.after) { card($0) }
                }
                .padding(.top, 8)
            }

            VStack(spacing: 10) {
                ForEach(Array(question.choices.enumerated()), id: \.element) { index, choice in
                    OptionButton(
                        text: choice,
                        letter: OptionState.letter(index),
                        state: .resolve(choice: choice, answer: question.answer, selection: selection, revealed: isRevealed),
                        isLocked: isRevealed
                    ) { selection = choice }
                }
            }

            QuizColumnsView(
                first: question.pinyin, second: question.meaning,
                firstSelection: $pinyin, secondSelection: $meaning,
                isRevealed: isRevealed
            )
        }
    }

    private var blank: some View {
        let color: Color = isRevealed ? .successText : (selection == nil ? .secondary : .accentColor)
        let isOpen = selection == nil && !isRevealed
        return Text(isRevealed ? question.answer : (selection ?? "＿＿"))
            .font(.system(size: wordSize, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .overlay {
                RoundedRectangle(cornerRadius: ClozeWordCard.cornerRadius, style: .continuous)
                    .strokeBorder(isRevealed ? Color.green : Color.accentColor, style: StrokeStyle(lineWidth: 2, dash: isOpen ? [5] : []))
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Blank in the sentence")
            .accessibilityValue(isRevealed ? question.answer : (selection ?? "Empty"))
    }

    /// Words get a card. Punctuation stays plain text.
    @ViewBuilder
    private func card(_ token: WordToken) -> some View {
        if token.text.contains(where: \.isHanCharacter) {
            ClozeWordCard(token: token, showsHidden: showingHidden.contains(token.id)) {
                showingHidden.formSymmetricDifference([token.id])
            }
        } else {
            Text(token.text).font(.system(size: wordSize, weight: .medium))
        }
    }
}
