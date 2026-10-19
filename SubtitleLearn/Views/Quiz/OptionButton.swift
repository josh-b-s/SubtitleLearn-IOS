import SwiftUI

enum OptionState: Equatable {
    case idle, selected, correct, wrong

    /// Before the answer is revealed only the pick is marked. After, the right one is green and a wrong pick red.
    static func resolve(choice: String, answer: String, selection: String?, revealed: Bool) -> OptionState {
        if revealed {
            if choice == answer { return .correct }
            return choice == selection ? .wrong : .idle
        }
        return choice == selection ? .selected : .idle
    }

    static func letter(_ index: Int) -> String {
        String(Character(UnicodeScalar(UInt8(65 + index))))
    }
}

/// Answer row shared by every question type.
struct OptionButton: View {
    let text: String
    var letter: String?
    var subtitle: String?
    let state: OptionState
    var font: Font = .title3
    var isLocked = false
    let action: () -> Void

    private let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)

    private var tint: Color {
        switch state {
        case .idle: Color(.separator)
        case .selected: .accentColor
        case .correct: .green
        case .wrong: .red
        }
    }

    private var fill: Color {
        switch state {
        case .idle: Color(.secondarySystemGroupedBackground)
        case .selected: Color.accentColor.opacity(0.15)
        case .correct: Color.green.opacity(0.12)
        case .wrong: Color.red.opacity(0.12)
        }
    }

    private var icon: String? {
        switch state {
        case .idle: nil
        case .selected, .correct: "checkmark.circle.fill"
        case .wrong: "xmark.circle.fill"
        }
    }

    private var textColor: Color {
        state == .correct || state == .wrong ? tint : .primary
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let letter {
                    Text(letter)
                        .font(.headline)
                        .foregroundStyle(state == .idle ? Color.secondary : tint)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(text)
                        .font(font)
                        .foregroundStyle(textColor)
                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(state == .correct || state == .wrong ? tint.opacity(0.8) : Color.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if let icon {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(tint)
                }
            }
            .padding(14)
            .background(shape.fill(fill))
            .overlay(shape.strokeBorder(tint, lineWidth: state == .idle ? 1 : 2))
            .shadow(color: .black.opacity(state == .idle ? 0.06 : 0), radius: 3, y: 2)
            .contentShape(shape)
        }
        .buttonStyle(PressableButtonStyle())
        .allowsHitTesting(!isLocked)
        .sensoryFeedback(.selection, trigger: state == .selected)
    }
}
