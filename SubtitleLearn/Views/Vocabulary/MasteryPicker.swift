import SwiftUI

/// Manual mastery control for the word detail sheet and the add-known-word form.
/// The slider moves in half levels, so 2.5 means level 2 with one pass done.
struct MasteryPicker: View {
    @Binding var progress: Double
    @State private var draft: Double?
    @State private var isDragging = false

    private var shown: Double { draft ?? progress }
    private var summary: String { Mastery.summary(forScore: shown) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("MASTERY")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Text(summary)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .accessibilityHidden(true)
            }

            Slider(
                value: sliderValue,
                in: 1...Double(Mastery.masteredLevel),
                step: Mastery.scoreStep,
                onEditingChanged: editingChanged
            ) {
                Text("Mastery")
            } minimumValueLabel: {
                Text("1")
            } maximumValueLabel: {
                Image(systemName: "checkmark.circle")
            }
            .accessibilityValue(summary)
            .accessibilityHint(caption)

            Text(caption)
                .accessibilityHidden(true)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    /// A drag only saves on release, so passing the mastered end doesn't stamp a mastered date on the way.
    private var sliderValue: Binding<Double> {
        Binding(
            get: { shown },
            set: { value in
                // Adjusting without a drag (VoiceOver) has no release to wait for.
                if isDragging { draft = value } else { progress = value }
            }
        )
    }

    private func editingChanged(_ editing: Bool) {
        isDragging = editing
        guard !editing, let value = draft else { return }
        progress = value
        draft = nil
    }

    private var caption: String {
        switch Mastery.state(forScore: shown).level {
        case 1: "Subtitles show its meaning and pinyin."
        case 2: "Subtitles hide its meaning."
        case 3: "Subtitles hide its meaning and pinyin."
        default: "Hidden in subtitles and never quizzed."
        }
    }
}
