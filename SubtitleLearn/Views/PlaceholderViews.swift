import SwiftUI

struct ScreenShareView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Screen Share", systemImage: "airplayvideo",
                                   description: Text("Live subtitles in Picture-in-Picture are coming in a later stage."))
                .navigationTitle("Screen Share")
        }
    }
}

struct QuizView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Quiz", systemImage: "brain",
                                   description: Text("AI-generated quizzes and spaced repetition are coming in a later stage."))
                .navigationTitle("Quiz")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("Settings coming soon.").foregroundStyle(.secondary)
            }
            .navigationTitle("Settings")
        }
    }
}
