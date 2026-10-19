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

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Word", text: $word)
                        .autocorrectionDisabled()
                    TextField("Pinyin (optional)", text: $pinyin)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Meaning", text: $meaning)
                        .textInputAutocapitalization(.never)
                } footer: {
                    Text("Chinese characters only. Separate several meanings with a slash. Pinyin is filled in for you if you leave it blank. Adding an existing word replaces it.")
                }
            }
            .navigationTitle("Custom word")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        CustomDictionaryStore.add(word: cleanWord, pinyin: pinyin, meaning: meaning)
                        onSaved()
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
