import SwiftUI

/// Compact word card sized for the small PiP window.
/// Colors are explicit because the PiP image is rendered outside the app's theme.
struct PipWordCard: View {
    let token: WordToken

    private static let blue = Color(red: 0, green: 0.478, blue: 1)

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(token.text)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.black)
            if !token.pinyin.isEmpty && !token.hidePinyin {
                Text(token.pinyin)
                    .font(.system(size: 12))
                    .foregroundStyle(Self.blue)
            }
            if !token.meanings.isEmpty && !token.hideMeaning {
                Text(token.meanings.prefix(2).joined(separator: " · "))
                    .font(.system(size: 11))
                    .foregroundStyle(Color.gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: 92, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
