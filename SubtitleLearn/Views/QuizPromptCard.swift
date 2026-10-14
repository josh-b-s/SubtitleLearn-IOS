import SwiftUI

/// Rounded card that holds the question prompt.
struct QuizPromptCard<Content: View>: View {
    var alignment: HorizontalAlignment = .center
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: alignment, spacing: 8) { content() }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: alignment == .center ? .center : .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }
}
