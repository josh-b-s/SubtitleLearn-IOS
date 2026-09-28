import SwiftUI
import SwiftData

struct TranslateView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var savedWords: [SavedWord]

    @State private var viewModel = TranslateViewModel()
    @State private var showMicComingSoon = false
    @FocusState private var inputFocused: Bool

    private var savedSet: Set<String> { Set(savedWords.map(\.word)) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    inputCard
                    translateButton
                    breakdownSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("SubtitleLearn")
        }
        .task { await viewModel.loadDictionary() }
        .alert("Microphone input", isPresented: $showMicComingSoon) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Live speech transcription is coming in the next stage.")
        }
    }

    // MARK: - Input

    private var inputCard: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.inputText)
                    .focused($inputFocused)
                    .scrollContentBackground(.hidden)
                    .font(.title3)
                    .frame(minHeight: 110)

                if viewModel.inputText.isEmpty {
                    Text("Paste or type Chinese text…")
                        .font(.title3)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
            }

            HStack {
                Text("Mandarin Chinese")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    showMicComingSoon = true
                } label: {
                    Image(systemName: "mic.fill")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGroupedBackground), in: Circle())
                }
                .accessibilityLabel("Speak Chinese")
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var translateButton: some View {
        Button {
            inputFocused = false
            viewModel.translate()
        } label: {
            Text("Translate")
                .font(.title3.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 32)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 18))
        .controlSize(.large)
        .disabled(!viewModel.canTranslate)
    }

    // MARK: - Results

    @ViewBuilder
    private var breakdownSection: some View {
        if viewModel.dictionaryFailedToLoad {
            Text("The dictionary couldn't be loaded. Check that zh-en.tsv is included in the app target.")
                .font(.footnote)
                .foregroundStyle(.red)
        } else if !viewModel.isDictionaryReady {
            HStack(spacing: 8) {
                ProgressView()
                Text("Loading dictionary…").foregroundStyle(.secondary)
            }
        } else if viewModel.hasTranslated && viewModel.tokens.isEmpty {
            Text("No Chinese characters found.")
                .foregroundStyle(.secondary)
        } else if !viewModel.tokens.isEmpty {
            Text("INTERACTIVE BREAKDOWN")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.top, 4)

            FlowLayout(spacing: 12) {
                ForEach(viewModel.tokens) { token in
                    WordCard(token: token, isSaved: savedSet.contains(token.text))
                        .onTapGesture { toggleSaved(token) }
                }
            }
            .sensoryFeedback(.selection, trigger: savedWords.count)
        }
    }

    private func toggleSaved(_ token: WordToken) {
        if let existing = savedWords.first(where: { $0.word == token.text }) {
            modelContext.delete(existing)
        } else {
            modelContext.insert(SavedWord(word: token.text, pinyin: token.pinyin, meanings: token.meanings))
        }
    }
}
