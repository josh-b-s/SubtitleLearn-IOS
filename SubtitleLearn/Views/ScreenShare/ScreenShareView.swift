import SwiftUI
import SwiftData

/// Screen Share tab: live subtitles from audio, shown in a Picture in Picture window.
struct ScreenShareView: View {
    /// Called with the words to quiz when the user taps Review on the session summary.
    let onReview: ([String]) -> Void

    @Environment(\.modelContext) private var modelContext
    @Query private var words: [SavedWord]
    @State private var summary: SessionSummary?
    @State private var viewModel = ScreenShareViewModel()
    @StateObject private var pip = PipController()
    @State private var pickerTrigger = 0
    @State private var showTranscript = false

    private let extensionID = BroadcastPickerButton.embeddedExtensionBundleID

    private var levelsByWord: [String: Int] {
        Dictionary(words.map { ($0.word, $0.level) }, uniquingKeysWith: { first, _ in first })
    }

    private var isActive: Bool { viewModel.isRunning || viewModel.isWaitingForBroadcast }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    mockMedia
                    sourcePicker
                    pipButton
                    if viewModel.isRunning && !pip.isActive { showPipButton }
                    Text(helpText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Screen Share")
            .toolbar {
                if !viewModel.transcript.lines.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showTranscript = true } label: {
                            Label("Transcript", systemImage: "text.alignleft")
                        }
                    }
                }
            }
        }
        .overlay { PipLayerHost(layer: pip.displayLayer) }
        .onAppear {
            pip.setContent(
                PipSubtitleView(model: viewModel.subtitles)
                    .frame(width: PipSubtitleView.pipSize.width, height: PipSubtitleView.pipSize.height)
            )
        }
        .onChange(of: levelsByWord, initial: true) { _, levels in
            viewModel.subtitles.levels = levels
        }
        // PiP follows the session: opens when it starts, closes when it ends or fails.
        // Closing the window by hand leaves the session running.
        .onChange(of: viewModel.isRunning) { _, running in
            if running { pip.present() } else { pip.stop() }
        }
        .onChange(of: viewModel.endedSession) { _, session in
            guard let session else { return }
            summary = SessionSummaryBuilder.build(from: session.entries, saved: words)
            if let summary { SessionClipSaver.save(session, summary: summary, saved: words) }
            viewModel.clearEndedSession()
        }
        .sheet(item: $summary) { item in
            SessionSummaryView(summary: item, onReview: { startReview(item) }, onDone: { summary = nil })
        }
        .sheet(isPresented: $showTranscript) {
            TranscriptView(lines: viewModel.transcript.lines)
        }
        .alert("Screen Share", isPresented: errorBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func startReview(_ item: SessionSummary) {
        SessionReviewSaver.saveUnsaved(from: item, into: modelContext)
        summary = nil
        onReview(item.topWords.map(\.token.text))
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    /// Stand-in for the media being watched, with the same panel the PiP shows.
    private var mockMedia: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(red: 0.06, green: 0.1, blue: 0.2), .black, Color(red: 0.45, green: 0.25, blue: 0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            Text("Preview")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.5))
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(12)
            PipSubtitleView(model: viewModel.subtitles)
                .frame(height: PipSubtitleView.pipSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal, 12)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 420)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var sourcePicker: some View {
        Picker("Audio source", selection: $viewModel.source) {
            ForEach(ScreenShareViewModel.Source.allCases) { Text($0.rawValue).tag($0) }
        }
        .pickerStyle(.segmented)
        .disabled(isActive)
    }

    private var pipButton: some View {
        Button {
            if isActive {
                viewModel.stop()
            } else {
                Task {
                    await viewModel.start()
                    if viewModel.isWaitingForBroadcast { pickerTrigger += 1 }
                }
            }
        } label: {
            Label(buttonTitle, systemImage: isActive ? "stop.fill" : "pip.enter")
                .font(.title3.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 32)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 18))
        .controlSize(.large)
        .tint(isActive ? .red : .accentColor)
        .disabled(!canStart)
        .background {
            BroadcastPickerButton(extensionBundleID: extensionID, trigger: pickerTrigger)
                .frame(width: 1, height: 1)
                .opacity(0.011)
        }
    }

    private var showPipButton: some View {
        Button { pip.present() } label: {
            Label("Show PiP", systemImage: "pip.enter")
                .frame(maxWidth: .infinity, minHeight: 28)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: 18))
        .controlSize(.large)
    }

    private var canStart: Bool {
        guard PipController.isSupported else { return false }
        return isActive || viewModel.source != .screen || extensionID != nil
    }

    private var buttonTitle: String {
        if viewModel.isWaitingForBroadcast { return "Waiting for broadcast (tap to cancel)" }
        if viewModel.isRunning { return "Stop" }
        return viewModel.source == .screen ? "Share screen audio" : "Start live subtitles"
    }

    private var helpText: String {
        guard PipController.isSupported else {
            return "Picture in Picture isn't supported on this device or simulator."
        }
        switch viewModel.source {
        case .screen:
            return extensionID == nil
                ? "The broadcast extension isn't in this build yet. See SETUP.md."
                : "Tap the button, then \"Start Broadcast\" in the system sheet. Subtitles appear in a floating window for audio from any app, such as a video you play."
        case .microphone:
            return "Listens through the microphone, so it hears media playing out loud (not through headphones). Start it, then press Home and play something in Chinese."
        case .mock:
            return "Streams sample sentences, no audio needed. Use it to check the PiP window itself."
        }
    }
}
