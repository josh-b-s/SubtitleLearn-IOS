import SwiftUI

/// Picks the right body for the question kind and shows its level.
struct QuizQuestionView: View {
    let question: QuizQuestion
    @Binding var selectedChoice: String?
    @Binding var selectedPinyin: String?
    @Binding var selectedMeaning: String?
    let isRevealed: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            switch question.kind {
            case .choice(let q):
                ChoiceQuestionView(question: q, selection: $selectedChoice, isRevealed: isRevealed)
                if hasClip(for: q) { ReplayClipButton(word: question.word) }
            case .pair(let q): PairQuestionView(question: q, pinyin: $selectedPinyin, meaning: $selectedMeaning, isRevealed: isRevealed)
            case .cloze(let q): ClozeQuestionView(question: q, selection: $selectedChoice, isRevealed: isRevealed)
            }
        }
    }

    /// Only level 1 words keep clips, and only when hearing the word doesn't give away the answer.
    private func hasClip(for choice: ChoiceQuestion) -> Bool {
        question.level == 1
            && choice.direction == .chineseToEnglish
            && AudioClipStore.hasClip(for: question.word)
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
