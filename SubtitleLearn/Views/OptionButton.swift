import SwiftUI

/// Selectable answer row shared by every question type.
struct OptionButton: View {
    let text: String
    let isSelected: Bool
    var font: Font = .title3
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(font)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSelected ? Color.accentColor.opacity(0.15) : Color(.secondarySystemGroupedBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 2)
                )
        }
        .foregroundStyle(.primary)
    }
}
