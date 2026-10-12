import SwiftUI

/// Selectable answer row shared by every question type.
struct OptionButton: View {
    let text: String
    let isSelected: Bool
    var font: Font = .title3
    let action: () -> Void

    private let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(text)
                    .font(font)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.accentColor : Color(.tertiaryLabel))
            }
            .padding(14)
            .background(shape.fill(isSelected ? Color.accentColor.opacity(0.15) : Color(.secondarySystemGroupedBackground)))
            .overlay(shape.strokeBorder(isSelected ? Color.accentColor : Color(.separator), lineWidth: isSelected ? 2 : 1))
            .shadow(color: .black.opacity(isSelected ? 0 : 0.06), radius: 3, y: 2)
            .contentShape(shape)
        }
        .buttonStyle(PressableButtonStyle())
        .foregroundStyle(.primary)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}
