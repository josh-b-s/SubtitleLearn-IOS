import SwiftUI

/// Level 3 body: sentence with a blank, tappable words, and a word bank.
struct ClozeQuestionView: View {
    let question: ClozeQuestion
    @Binding var selection: String?
    @State private var tapped: WordToken?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("FILL IN THE BLANK")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 6) {
                ForEach(question.before) { tokenButton($0) }
                blank
                ForEach(question.after) { tokenButton($0) }
            }

            Text(question.translation)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            tokenInfo

            VStack(spacing: 10) {
                ForEach(question.choices, id: \.self) { choice in
                    OptionButton(text: choice, isSelected: selection == choice) { selection = choice }
                }
            }
        }
    }

    private var blank: some View {
        Text(selection ?? "＿＿")
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(selection == nil ? Color.secondary : Color.accentColor)
            .padding(.horizontal, 6)
            .overlay(alignment: .bottom) {
                Rectangle().frame(height: 2).foregroundStyle(Color.accentColor)
            }
    }

    private func tokenButton(_ token: WordToken) -> some View {
        Button { tapped = token } label: {
            Text(token.text).font(.system(size: 28, weight: .medium))
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
