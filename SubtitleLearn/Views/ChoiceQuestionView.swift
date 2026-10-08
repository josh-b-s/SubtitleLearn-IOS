import SwiftUI

/// Level 1 body.
struct ChoiceQuestionView: View {
    let question: ChoiceQuestion
    @Binding var selection: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question.direction == .chineseToEnglish ? "WHAT DOES THIS MEAN?" : "WHICH WORD MEANS THIS?")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text(question.prompt)
                    .font(.system(size: question.direction == .chineseToEnglish ? 48 : 28, weight: .bold))
                if !question.hint.isEmpty {
                    Text(question.hint)
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                }
            }

            VStack(spacing: 10) {
                ForEach(question.choices, id: \.self) { choice in
                    OptionButton(text: choice, isSelected: selection == choice) { selection = choice }
                }
            }
        }
    }
}
