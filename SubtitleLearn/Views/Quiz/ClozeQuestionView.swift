import SwiftUI

/// Level 3 body: sentence with a blank, tappable words, and a word bank.
struct ClozeQuestionView: View {
    let question: ClozeQuestion
    @Binding var selection: String?
    let isRevealed: Bool
    @State private var tapped: WordToken?
    @ScaledMetric(relativeTo: .title) private var tokenSize = 28

    var body: some View {
        VStack(spacing: 20) {
            QuizPromptCard(alignment: .leading) {
                Text("Fill in the blank")
                    .font(.headline)

                FlowLayout(spacing: 6) {
                    ForEach(question.before) { tokenButton($0) }
                    blank
                    ForEach(question.after) { tokenButton($0) }
                }
                .padding(.top, 4)

                Text(question.translation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                tokenInfo
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
        }
    }

    private var blank: some View {
        let color: Color = isRevealed ? .green : (selection == nil ? .secondary : .accentColor)
        return Text(isRevealed ? question.answer : (selection ?? "＿＿"))
            .font(.system(size: tokenSize, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .overlay(alignment: .bottom) {
                Rectangle().frame(height: 2).foregroundStyle(isRevealed ? Color.green : Color.accentColor)
            }
    }

    private func tokenButton(_ token: WordToken) -> some View {
        Button { tapped = token } label: {
            Text(token.text).font(.system(size: tokenSize, weight: .medium))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var tokenInfo: some View {
        if let token = tapped {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(token.text)  \(token.pinyin)").foregroundStyle(Color.accentColor)
                Text(token.meanings.isEmpty ? "No definition" : token.meanings.joined(separator: " · "))
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
        } else {
            Text("Tap a word for its pinyin and meaning")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
    }
}
