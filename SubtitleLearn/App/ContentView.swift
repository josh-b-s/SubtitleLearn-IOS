import SwiftUI

struct ContentView: View {
    @State private var selection: Tab = .translate
    @State private var pendingReview: [String]?
    @State private var settings = AppSettings.shared

    enum Tab { case screenShare, translate, vocabulary, quiz, settings }

    var body: some View {
        TabView(selection: $selection) {
            ScreenShareView(onReview: { words in
                pendingReview = words
                selection = .quiz
            })
                .tabItem { Label("Screen Share", systemImage: "airplayvideo") }
                .tag(Tab.screenShare)

            TranslateView()
                .tabItem { Label("Translate", systemImage: "arrow.left.arrow.right") }
                .tag(Tab.translate)

            VocabularyView()
                .tabItem { Label("Vocabulary", systemImage: "bookmark") }
                .tag(Tab.vocabulary)

            QuizView(pendingReview: $pendingReview)
                .tabItem { Label("Quiz", systemImage: "brain") }
                .tag(Tab.quiz)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
        .preferredColorScheme(settings.appearance.colorScheme)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SavedWord.self, inMemory: true)
}
