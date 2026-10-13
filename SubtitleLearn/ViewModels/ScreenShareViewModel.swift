import Foundation
import Observation

/// Runs the subtitle source (screen audio, mic or mock) and feeds the PiP word display.
@MainActor
@Observable
final class ScreenShareViewModel {
    enum Source: String, CaseIterable, Identifiable {
        case screen = "Screen audio"
        case microphone = "Mic"
        case mock = "Mock"
        var id: String { rawValue }
    }

    var source: Source = .screen
    var errorMessage: String?
    private(set) var isRunning = false
    private(set) var isWaitingForBroadcast = false
    /// Set when a session ends with words heard. The view shows the summary, then clears it.
    private(set) var endedSession: SessionResult?

    /// Longest unbroken speech kept in one subtitle. Longer is closed off and a new one starts.
    private static let maxSegmentCharacters = 40

    let subtitles = PipSubtitleModel()
    private let transcriber = SpeechTranscriber()
    private let mock = MockSubtitleFeeder()
    private let receiver = BroadcastAudioReceiver()
    private let tracker = SessionWordTracker()
    private let clipRecorder = AudioClipRecorder()
    @ObservationIgnored private var dictionary: ChineseDictionary?
    @ObservationIgnored private var runID = UUID()
    @ObservationIgnored private var isStarting = false

    /// For screen audio this only begins waiting; the view then opens the system broadcast picker.
    func start() async {
        guard !isRunning, !isWaitingForBroadcast, !isStarting else { return }
        isStarting = true
        defer { isStarting = false }

        guard let dictionary = await DictionaryLoader.shared.value else {
            errorMessage = "The dictionary couldn't be loaded."
            return
        }
        self.dictionary = dictionary
        subtitles.clear()
        tracker.reset()
        clipRecorder.reset()

        switch source {
        case .mock:
            mock.start(dictionary: dictionary, into: subtitles)
            isRunning = true
        case .microphone:
            await startMicrophone()
        case .screen:
            await waitForBroadcast()
        }
    }

    func stop() {
        guard isRunning || isWaitingForBroadcast else { return }
        let wasScreen = source == .screen
        tracker.flush()
        let heard = tracker.entries
        tracker.reset()
        if !heard.isEmpty { endedSession = SessionResult(entries: heard, clips: clipRecorder.clips) }
        clipRecorder.reset()
        runID = UUID()
        transcriber.cancel()
        mock.stop()
        receiver.stop(requestBroadcastEnd: wasScreen)
        subtitles.clear()
        isWaitingForBroadcast = false
        isRunning = false
    }

    func clearEndedSession() { endedSession = nil }

    // MARK: - Microphone

    private func startMicrophone() async {
        do {
            try await SpeechTranscriber.requestPermissions()
            let run = UUID()
            runID = run
            transcriber.preferOnDevice = AppSettings.shared.preferOnDeviceSpeech
            transcriber.maxSegmentCharacters = Self.maxSegmentCharacters
            // Keep the media's audio playing normally while we listen to it.
            transcriber.sessionMode = .default
            transcriber.sessionOptions = [.mixWithOthers, .defaultToSpeaker]
            try await transcriber.start(
                continuous: true,
                onUpdate: { [weak self] text, isFinal in
                    Task { @MainActor in self?.handle(text, isFinal: isFinal, run: run) }
                },
                onFailure: { [weak self] error in
                    Task { @MainActor in self?.handleFailure(error, run: run) }
                }
            )
            isRunning = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Screen audio (broadcast extension)

    private func waitForBroadcast() async {
        guard BroadcastShared.containerURL != nil else {
            errorMessage = "The App Group isn't set up. See SETUP.md, step 3."
            return
        }
        do {
            try await SpeechTranscriber.requestSpeechPermission()
        } catch {
            errorMessage = error.localizedDescription
            return
        }

        receiver.resetSharedFolder()
        isWaitingForBroadcast = true
        receiver.start(
            onStarted: { [weak self] in self?.broadcastDidStart() },
            onBuffer: { [weak self] buffer in
                self?.clipRecorder.append(buffer)
                self?.transcriber.appendExternal(buffer)
            },
            onEnded: { [weak self] in self?.stop() }
        )
    }

    private func broadcastDidStart() {
        guard isWaitingForBroadcast else { return }
        let run = UUID()
        runID = run
        transcriber.preferOnDevice = AppSettings.shared.preferOnDeviceSpeech
        transcriber.maxSegmentCharacters = Self.maxSegmentCharacters
        do {
            try transcriber.startExternal(
                continuous: true,
                onUpdate: { [weak self] text, isFinal in
                    Task { @MainActor in self?.handle(text, isFinal: isFinal, run: run) }
                },
                onFailure: { [weak self] error in
                    Task { @MainActor in self?.handleFailure(error, run: run) }
                }
            )
        } catch {
            errorMessage = error.localizedDescription
            stop()
            return
        }
        isWaitingForBroadcast = false
        isRunning = true
    }

    // MARK: - Results

    private func handle(_ text: String, isFinal: Bool, run: UUID) {
        guard run == runID, let dictionary else { return }
        let tokens = dictionary.tokens(for: text)
        tracker.update(tokens, isFinal: isFinal)
        clipRecorder.captureIfAbsent(tokens.filter { !$0.meanings.isEmpty }.map(\.text))
        subtitles.update(segment: tokens, isFinal: isFinal)
    }

    private func handleFailure(_ error: Error, run: UUID) {
        guard run == runID else { return }
        stop()
        errorMessage = "Speech recognition stopped: \(error.localizedDescription)"
    }
}
