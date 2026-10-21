import SwiftUI

/// Per-character meanings for the word detail sheet.
struct CharacterBreakdown: View {
    let glosses: [CharGloss]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CHARACTERS")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)

            ForEach(glosses) { gloss in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(gloss.char).font(.title2.weight(.semibold))
                    Text(gloss.pinyin).foregroundStyle(Color.accentColor)
                    Text(gloss.meaning).foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
