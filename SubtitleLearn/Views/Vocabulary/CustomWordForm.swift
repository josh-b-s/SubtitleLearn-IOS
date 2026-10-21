import SwiftUI

/// Form for adding a word to the user's own dictionary.
struct CustomWordForm: View {
    let onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var word: String
    @State private var pinyin = ""
    @State private var meaning = ""

    init(initialWord: String = "", onSaved: @escaping () -> Void) {
        _word = State(initialValue: initialWord)
        self.onSaved = onSaved
    }

    private var cleanWord: String { word.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var isValid: Bool {
        !cleanWord.isEmpty
            && cleanWord.allSatisfy(\.isHanCharacter)
            && !CustomDictionaryStore.parseMeanings(meaning).isEmpty
    }

    /// Shown as soon as an entry is wrong, so the disabled Add button is never a mystery.
    private var validationMessage: String? {
        if !cleanWord.isEmpty && !cleanWord.allSatisfy(\.isHanCharacter) {
            return "The word can only use Chinese characters."
        }
        if !meaning.isEmpty && CustomDictionaryStore.parseMeanings(meaning).isEmpty {
            return "Enter at least one meaning."
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Word", text: $word)
                        .autocorrectionDisabled()
                        .accessibilityHint("Chinese characters only")
                    TextField("Pinyin (optional)", text: $pinyin)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityHint("Filled in for you if left blank")
                    TextField("Meaning", text: $meaning)
                        .textInputAutocapitalization(.never)
                        .accessibilityHint("Separate several meanings with a slash")
                    if let validationMessage {
                        Label(validationMessage, systemImage: "exclamationmark.triangle.fill")
                            .font(.footnote)
                            .foregroundStyle(Color.errorText)
                            .accessibilityLabel("Error: \(validationMessage)")
                    }
                } footer: {
                    Text("Chinese characters only. Separate several meanings with a slash. Pinyin is filled in for you if you leave it blank. Adding an existing word replaces it.")
                }
            }
            .navigationTitle("Custom word")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: validationMessage) { _, message in
                if let message { AccessibilityNotification.Announcement(message).post() }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        CustomDictionaryStore.add(word: cleanWord, pinyin: pinyin, meaning: meaning)
                        onSaved()
                        dismiss()
                    }
                    .disabled(!isValid)
                    .accessibilityHint(isValid ? "" : "Enter a Chinese word and a meaning first")
                }
            }
        }
        .presentationDetents([.medium])
    }
}
