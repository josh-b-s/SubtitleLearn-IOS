import SwiftUI

/// Picks the right body for the question kind and shows its level.
struct QuizQuestionView: View {
    let question: QuizQuestion
    @Binding var selectedChoice: String?
    @Binding var selectedPinyin: String?
    @Binding var selectedMeaning: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            switch question.kind {
            case .choice(let q): ChoiceQuestionView(question: q, selection: $selectedChoice)
            case .pair(let q): PairQuestionView(question: q, pinyin: $selectedPinyin, meaning: $selectedMeaning)
            case .cloze(let q): ClozeQuestionView(question: q, selection: $selectedChoice)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text("LEVEL \(question.level)")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.accentColor)
            if question.isRetry {
                Text("TRY AGAIN")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.orange)
            }
        }
    }
}
