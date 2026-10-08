import SwiftUI

/// Result of one answer, with the right answer on a miss and any level change.
struct QuizFeedbackView: View {
    let feedback: QuizFeedback
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: feedback.correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(feedback.correct ? Color.green : Color.red)

            Text(feedback.correct ? "Correct!" : "Not quite")
                .font(.title2.weight(.semibold))

            if !feedback.correct {
                Text("Answer: \(feedback.answerText)")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                Text("You'll see this one again at the end.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let note = feedback.levelNote {
                Text(note)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.accentColor)
                    .multilineTextAlignment(.center)
            }

            Button("Continue", action: onContinue)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .padding(20)
        .frame(maxHeight: .infinity)
    }
}
