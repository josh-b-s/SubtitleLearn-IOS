import SwiftUI

/// Chip row: All plus one chip per mastery level group (nil means All), then a Due today toggle that combines with them.
struct MasteryFilterBar: View {
    @Binding var selection: MasteryFilter?
    @Binding var dueOnly: Bool

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip("All", isOn: selection == nil) { selection = nil }
                ForEach(MasteryFilter.allCases) { filter in
                    chip(filter.rawValue, isOn: selection == filter) { selection = filter }
                }
                chip("Due today", isOn: dueOnly) { dueOnly.toggle() }
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
