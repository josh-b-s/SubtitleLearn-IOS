import SwiftUI
import SwiftData

struct TranslateView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var savedWords: [SavedWord]

    @State private var viewModel = TranslateViewModel()
    @State private var settings = AppSettings.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedToken: WordToken?
    @FocusState private var inputFocused: Bool

    private var savedSet: Set<String> { Set(savedWords.map(\.word)) }

    private var levelsByWord: [String: Int] {
        Dictionary(savedWords.map { ($0.word, $0.level) }, uniquingKeysWith: { first, _ in first })
    }

    /// Cards as shown: learned words lose their hints when the toggle is on.
    private var displayTokens: [WordToken] {
        settings.hideLearnedInTranslate
            ? MasteryRedactor.apply(to: viewModel.tokens, levels: levelsByWord)
            : viewModel.tokens
    }

    private var speechErrorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.speechErrorMessage != nil },
            set: { if !$0 { viewModel.speechErrorMessage = nil } }
        )
    }

    private static let bottomID = "bottom"
    @ScaledMetric private var micSize = 44

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if viewModel.isListening {
                            listeningHint
                        } else {
                            inputCard
                            translateButton
                            #if DEBUG
                            Button("Test speech with sample audio") { viewModel.transcribeSample() }
                                .font(.footnote)
                            Button("Simulate live transcript (no speech service)") { viewModel.simulateLiveTranscript() }
                                .font(.footnote)
                            #endif
                        }
                        breakdownSection
                        Color.clear.frame(height: 1).id(Self.bottomID)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)
                // Follow the live transcript while recording.
                .onChange(of: viewModel.inputText) { _, _ in
                    guard viewModel.isListening else { return }
                    DispatchQueue.main.async {
                        withAnimation(.easeOut(duration: 0.15)) {
                            proxy.scrollTo(Self.bottomID, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Translate")
            .safeAreaInset(edge: .bottom) {
                if viewModel.isListening {
                    StopRecordingBar { viewModel.stopListening() }
                }
            }
        }
        .sheet(item: $selectedToken) { token in
            WordDetailSheet(token: token, isSaved: savedSet.contains(token.text), level: savedWord(for: token)?.levelBinding) {
                toggleSaved(token)
                selectedToken = nil
            }
        }
        .task { await viewModel.loadDictionary() }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { viewModel.stopListening() }
        }
        .onDisappear { viewModel.stopListening() }
        .alert("Speech input", isPresented: speechErrorBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.speechErrorMessage ?? "")
        }
    }

    private var listeningHint: some View {
        HStack(spacing: 8) {
            Image(systemName: "waveform").foregroundStyle(.red).symbolEffect(.variableColor.iterative)
            Text(viewModel.tokens.isEmpty ? "Listening, start speaking…" : "Listening…")
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
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
                    inputFocused = false
                    Task { await viewModel.startListening() }
                } label: {
                    Image(systemName: "mic.fill")
                        .font(.title3)
                        .frame(width: micSize, height: micSize)
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
            HStack {
                Text("INTERACTIVE BREAKDOWN")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Toggle(isOn: $settings.hideLearnedInTranslate) {
                    Label("Hide learned", systemImage: "eye.slash")
                }
                .toggleStyle(.button)
                .controlSize(.small)
            }
            .padding(.top, 4)

            FlowLayout(spacing: 12) {
                ForEach(displayTokens) { token in
                    WordCard(token: token, isSaved: savedSet.contains(token.text))
                        .onTapGesture { selectedToken = token }
                }
            }
            .sensoryFeedback(.selection, trigger: savedWords.count)
        }
    }

    private func savedWord(for token: WordToken) -> SavedWord? {
        savedWords.first { $0.word == token.text }
    }

    private func toggleSaved(_ token: WordToken) {
        if let existing = savedWords.first(where: { $0.word == token.text }) {
            modelContext.delete(existing)
        } else {
            modelContext.insert(SavedWord(word: token.text, pinyin: token.pinyin, meanings: token.meanings))
        }
    }
}