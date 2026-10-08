import SwiftUI

/// Chip row: All plus one chip per mastery status. nil means All.
struct MasteryFilterBar: View {
    @Binding var selection: MasteryStatus?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip("All", isOn: selection == nil) { selection = nil }
                ForEach(MasteryStatus.allCases) { status in
                    chip(status.rawValue, isOn: selection == status) { selection = status }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func chip(_ title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundStyle(isOn ? Color.white : Color.primary)
                .background(Capsule().fill(isOn ? Color.accentColor : Color(.secondarySystemGroupedBackground)))
        }
    }
}
