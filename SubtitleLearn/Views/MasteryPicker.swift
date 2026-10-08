import SwiftUI

/// Manual mastery level control for the word detail sheet.
struct MasteryPicker: View {
    @Binding var level: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MASTERY")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Picker("Mastery", selection: $level) {
                Text("1").tag(1)
                Text("2").tag(2)
                Text("3").tag(3)
                Text("Mastered").tag(Mastery.masteredLevel)
            }
            .pickerStyle(.segmented)

            Text(caption)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var caption: String {
        switch level {
        case 1: "Subtitles show its meaning and pinyin."
        case 2: "Subtitles hide its meaning."
        case 3: "Subtitles hide its meaning and pinyin."
        default: "Hidden in subtitles and never quizzed."
        }
    }
}
