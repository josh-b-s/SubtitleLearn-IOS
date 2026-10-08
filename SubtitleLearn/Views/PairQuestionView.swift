import SwiftUI

/// Level 2 body: pinyin options on the left, meaning options on the right.
struct PairQuestionView: View {
    let question: PairQuestion
    @Binding var pinyin: String?
    @Binding var meaning: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PICK THE PINYIN AND THE MEANING")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(question.word)
                .font(.system(size: 52, weight: .bold))
                .frame(maxWidth: .infinity)

            HStack(alignment: .top, spacing: 12) {
                column("PINYIN", choices: question.pinyinChoices, selection: $pinyin)
                column("MEANING", choices: question.meaningChoices, selection: $meaning)
            }
        }
    }

    private func column(_ title: String, choices: [String], selection: Binding<String?>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            ForEach(choices, id: \.self) { choice in
                OptionButton(text: choice, isSelected: selection.wrappedValue == choice, font: .body) {
                    selection.wrappedValue = choice
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}
