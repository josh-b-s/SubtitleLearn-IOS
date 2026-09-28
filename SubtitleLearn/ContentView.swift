import SwiftUI

struct ContentView: View {
    @State private var selection: Tab = .translate

    enum Tab { case screenShare, translate, vocabulary, quiz, settings }

    var body: some View {
        TabView(selection: $selection) {
            ScreenShareView()
                .tabItem { Label("Screen Share", systemImage: "airplayvideo") }
                .tag(Tab.screenShare)

            TranslateView()
                .tabItem { Label("Translate", systemImage: "arrow.left.arrow.right") }
                .tag(Tab.translate)

            VocabularyView()
                .tabItem { Label("Vocabulary", systemImage: "bookmark") }
                .tag(Tab.vocabulary)

            QuizView()
                .tabItem { Label("Quiz", systemImage: "brain") }
                .tag(Tab.quiz)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SavedWord.self, inMemory: true)
}
