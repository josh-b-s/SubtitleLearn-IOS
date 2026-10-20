import SwiftUI

/// Two columns of answer options side by side, stacked once text is too large for two narrow columns.
struct QuizColumnsView: View {
    let first: QuizColumn
    let second: QuizColumn
    @Binding var firstSelection: String?
    @Binding var secondSelection: String?
    let isRevealed: Bool

    @Environment(\.dynamicTypeSize) private var typeSize

    private var layout: AnyLayout {
        typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 12))
    }

    var body: some View {
        layout {
            column(first, selection: $firstSelection)
            column(second, selection: $secondSelection)
        }
    }

    private func column(_ column: QuizColumn, selection: Binding<String?>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(column.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            ForEach(column.choices, id: \.self) { choice in
                OptionButton(
                    text: choice,
                    state: .resolve(choice: choice, answer: column.answer, selection: selection.wrappedValue, revealed: isRevealed),
                    font: .body,
                    isLocked: isRevealed
                ) {
                    selection.wrappedValue = choice
                    if let word = column.spoken[choice] { Speaker.shared.speak(word, ignoringMuteSwitch: true) }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}
