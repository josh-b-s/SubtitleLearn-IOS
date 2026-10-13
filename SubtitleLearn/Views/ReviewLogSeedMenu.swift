#if DEBUG
import SwiftUI
import SwiftData

/// Debug only: fills the review log with fake history so the stats screen has something to show.
struct ReviewLogSeedMenu: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Menu {
            Button("Seed test data") { ReviewLogSeeder.seed(into: modelContext) }
            Button("Clear test data", role: .destructive) { ReviewLogSeeder.clear(from: modelContext) }
        } label: {
            Image(systemName: "ladybug")
        }
    }
}
#endif
