import SwiftUI
import SwiftData

@main
struct SubtitleLearnApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SavedWord.self)
    }
}
