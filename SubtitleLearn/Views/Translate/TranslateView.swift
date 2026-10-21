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
                        if !viewModel.isListening {
                            inputCard
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
                    ListeningBar(
                        hasTranscript: !viewModel.tokens.isEmpty,
                        hideLearned: $settings.hideLearnedInTranslate
                    ) { viewModel.stopListening() }
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
        .task(id: viewModel.inputText) {
            // Speech updates translate directly, so only typed or pasted text is debounced.
            guard !viewModel.isListening else { return }
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            viewModel.translate()
        }
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

    // MARK: - Input

    private var inputCard: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Paste or type Chinese text…", text: $viewModel.inputText, axis: .vertical)
                .focused($inputFocused)
                .font(.title3)
                .lineLimit(1...6)
                .padding(.vertical, 10)

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
            .accessibilityHint("Starts the microphone and turns what you say into text")
        }
        .padding(.leading, 16)
        .padding(.trailing, 6)
        .padding(.vertical, 6)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // MARK: - Results

    @ViewBuilder
    private var breakdownSection: some View {
        if viewModel.dictionaryFailedToLoad {
            Text("The dictionary couldn't be loaded. Check that zh-en.tsv is included in the app target.")
                .font(.footnote)
                .foregroundStyle(Color.errorText)
        } else if !viewModel.isDictionaryReady {
            HStack(spacing: 8) {
                ProgressView()
                Text("Loading dictionary…").foregroundStyle(.secondary)
            }
        } else if viewModel.hasTranslated && viewModel.tokens.isEmpty {
            Text("No Chinese characters found.")
                .foregroundStyle(.secondary)
        } else if !viewModel.tokens.isEmpty {
            if !viewModel.isListening {
                HStack {
                    Text("INTERACTIVE BREAKDOWN")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                    Toggle(isOn: $settings.hideLearnedInTranslate) {
                        Label("Hide learned", systemImage: "eye.slash")
                            .frame(minHeight: 30)
                    }
                    .toggleStyle(.button)
                    .accessibilityHint("Hides the pinyin and meaning of words you already know")
                }
                .padding(.top, 4)
            }

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