import SwiftUI

/// Flame and day count. Grey when there is no streak.
struct StreakBadge: View {
    let days: Int

    var body: some View {
        Label("\(days) day\(days == 1 ? "" : "s")", systemImage: "flame.fill")
            .font(.subheadline.weight(.bold))
            .foregroundStyle(days > 0 ? Color.white : Color.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(days > 0 ? Color.orange : Color(.systemGray5), in: Capsule())
    }
}
