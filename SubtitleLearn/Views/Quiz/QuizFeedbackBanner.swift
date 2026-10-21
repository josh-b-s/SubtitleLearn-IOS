import SwiftUI

/// Result of the answer just given, shown above the Next button.
struct QuizFeedbackBanner: View {
    let feedback: QuizFeedback

    private var tint: Color { feedback.correct ? .green : .red }
    private var textTint: Color { feedback.correct ? .successText : .errorText }

    private var message: String {
        feedback.correct ? "Correct! \(feedback.explanation)" : "Not quite. Answer: \(feedback.answerText)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(message, systemImage: feedback.correct ? "checkmark" : "xmark")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(textTint)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            if !feedback.correct {
                Text("You'll see this one again at the end.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if let note = feedback.levelNote {
                Text(note)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.accentColor)
            }
        }
        .accessibilityElement(children: .combine)
        // The banner appears without moving VoiceOver focus, so say the result out loud.
        .onAppear { AccessibilityNotification.Announcement(spokenResult).post() }
    }

    private var spokenResult: String {
        [message, feedback.correct ? nil : "You'll see this one again at the end.", feedback.levelNote]
            .compactMap { $0 }
            .joined(separator: ". ")
    }
}
