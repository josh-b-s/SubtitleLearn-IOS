import SwiftUI

/// Bottom sheet shown when a word card is tapped.
struct WordDetailSheet: View {
    let token: WordToken
    let isSaved: Bool
    let onToggleSave: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Text(token.text)
                    .font(.system(size: 52, weight: .bold))
                if !token.pinyin.isEmpty {
                    Text(token.pinyin)
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.top, 28)
            .padding(.bottom, 20)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("MEANINGS")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                if token.meanings.isEmpty {
                    Text("No definition").foregroundStyle(.secondary)
                } else {
                    ForEach(Array(token.meanings.enumerated()), id: \.offset) { index, meaning in
                        Text("\(index + 1). \(meaning)").font(.title3)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 20)

            Spacer(minLength: 20)

            Button(action: onToggleSave) {
                Text(isSaved ? "Remove from Vocabulary" : "Save to Vocabulary")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 36)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 18))
            .controlSize(.large)
            .tint(isSaved ? .red : .accentColor)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 24)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
    }
}
