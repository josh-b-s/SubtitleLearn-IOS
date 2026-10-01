import Foundation
import Observation
import Speech

@MainActor
@Observable
final class TranslateViewModel {
    var inputText = ""
    private(set) var tokens: [WordToken] = []
    private(set) var hasTranslated = false
    private(set) var isDictionaryReady = false
    private(set) var dictionaryFailedToLoad = false

    // Speech input
    private(set) var isListening = false
    var speechErrorMessage: String?

    private var dictionary: ChineseDictionary?
    private let transcriber = SpeechTranscriber()
    private var listeningSession = UUID()
    private var textBeforeListening = ""

    var canTranslate: Bool {
        isDictionaryReady && !isListening && !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Dictionary

    func loadDictionary() async {
        guard dictionary == nil else { return }
        let loaded = await Task.detached(priority: .userInitiated) {
            try? ChineseDictionary.loadBundled()
        }.value
        dictionary = loaded
        isDictionaryReady = loaded != nil
        dictionaryFailedToLoad = loaded == nil
    }

    func translate() {
        guard let dictionary else { return }
        tokens = dictionary.tokens(for: inputText)
        hasTranslated = true
    }

    // MARK: - Speech input

    func toggleListening() async {
        if isListening {
            stopListening()
        } else {
            await startListening()
        }
    }

    func startListening() async {
        guard !isListening else { return }
        do {
            try await SpeechTranscriber.requestPermissions()

            let session = UUID()
            listeningSession = session
            textBeforeListening = inputText.trimmingCharacters(in: .whitespacesAndNewlines)

            try await transcriber.start(
                onUpdate: { [weak self] transcript, isFinal in
                    Task { @MainActor in
                        self?.handleTranscript(transcript, isFinal: isFinal, session: session)
                    }
                },
                onFailure: { [weak self] error in
                    Task { @MainActor in
                        self?.handleSpeechFailure(error, session: session)
                    }
                }
            )
            isListening = true
        } catch {
            speechErrorMessage = error.localizedDescription
        }
    }

    /// Debug helper: runs recognition on a bundled sample (sample.aiff / .m4a / .wav / .mp3)
    /// so the speech pipeline can be tested without a microphone.
    func transcribeSample() {
        guard !isListening else { return }
        let url = ["aiff", "m4a", "wav", "mp3", "caf"]
            .compactMap { Bundle.main.url(forResource: "sample", withExtension: $0) }
            .first
        guard let url else {
            speechErrorMessage = "No sample audio found. Add sample.aiff (or .m4a/.wav) to the app target."
            return
        }
        Task {
            do {
                let auth: SFSpeechRecognizerAuthorizationStatus = await withCheckedContinuation { continuation in
                    SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0) }
                }
                guard auth == .authorized else { throw SpeechInputError.speechPermissionDenied }

                let session = UUID()
                listeningSession = session
                textBeforeListening = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                try transcriber.transcribeFile(
                    at: url,
                    onUpdate: { [weak self] transcript, isFinal in
                        Task { @MainActor in
                            self?.handleTranscript(transcript, isFinal: isFinal, session: session)
                        }
                    },
                    onFailure: { [weak self] error in
                        Task { @MainActor in
                            self?.handleSpeechFailure(error, session: session)
                        }
                    }
                )
                isListening = true
            } catch {
                speechErrorMessage = error.localizedDescription
            }
        }
    }

    func stopListening() {
        guard isListening else { return }
        transcriber.stop()      // the final transcript can still arrive after this
        isListening = false
    }

    private func handleTranscript(_ transcript: String, isFinal: Bool, session: UUID) {
        // Ignore late callbacks from an earlier listening session.
        guard session == listeningSession else { return }

        // The recognizer returns the whole transcript so far, so replace rather than append.
        inputText = textBeforeListening + transcript
        translate()

        if isFinal { stopListening() }
    }

    private func handleSpeechFailure(_ error: Error, session: UUID) {
        guard session == listeningSession, isListening else { return }
        stopListening()
        speechErrorMessage = "Speech recognition stopped: \(error.localizedDescription)"
    }
}
