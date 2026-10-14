import SwiftUI

struct SettingsView: View {
    @State private var settings = AppSettings.shared
    @State private var apiKeyDraft = AppSettings.shared.geminiAPIKey

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $settings.appearance) {
                        ForEach(AppearanceMode.allCases) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Toggle("On-device recognition", isOn: $settings.preferOnDeviceSpeech)
                } header: {
                    Text("Speech")
                } footer: {
                    Text("On: works offline with no time limit, but needs the Mandarin model and is less accurate. Off: Apple's servers, more accurate but needs internet. The Simulator doesn't support on-device, so turn this off there.")
                }

                Section {
                    Toggle("Hide hints for learned words", isOn: $settings.hideLearnedInPip)
                } header: {
                    Text("Subtitles")
                } footer: {
                    Text("Words past level 1 lose their meaning in the subtitles, and past level 2 their pinyin too. Look them up in the app if you need a reminder.")
                }

                Section {
                    SecureField("Gemini API key", text: $apiKeyDraft)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onSubmit { settings.geminiAPIKey = apiKeyDraft }
                        .onChange(of: apiKeyDraft) { _, new in settings.geminiAPIKey = new }
                } header: {
                    Text("Quiz")
                } footer: {
                    Text("Only used to write example sentences for level 3 questions, then cached. Levels 1 and 2 work without a key. Get a key at aistudio.google.com/apikey. Stored on-device only.")
                }

                Section {
                    Stepper("\(settings.questionsPerQuiz) questions per quiz", value: $settings.questionsPerQuiz, in: 3...20)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
