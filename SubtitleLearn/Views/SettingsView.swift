import SwiftUI

struct SettingsView: View {
    @State private var settings = AppSettings.shared
    @State private var apiKeyDraft = AppSettings.shared.geminiAPIKey

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("Gemini API key", text: $apiKeyDraft)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onSubmit { settings.geminiAPIKey = apiKeyDraft }
                        .onChange(of: apiKeyDraft) { _, new in settings.geminiAPIKey = new }
                } header: {
                    Text("Quiz")
                } footer: {
                    Text("Used to generate quiz questions and grade free-text answers. Get a key at aistudio.google.com/apikey. Stored on-device only.")
                }

                Section {
                    Stepper("\(settings.questionsPerQuiz) questions per quiz", value: $settings.questionsPerQuiz, in: 3...20)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
