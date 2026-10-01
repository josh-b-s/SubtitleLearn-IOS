import Foundation
import Speech
import AVFoundation

enum SpeechInputError: LocalizedError {
    case speechPermissionDenied
    case microphonePermissionDenied
    case recognizerUnavailable
    case noInputAudio

    var errorDescription: String? {
        switch self {
        case .speechPermissionDenied:
            "Speech recognition permission is off. Enable it in Settings > Privacy & Security > Speech Recognition."
        case .microphonePermissionDenied:
            "Microphone permission is off. Enable it in Settings > Privacy & Security > Microphone."
        case .recognizerUnavailable:
            "Mandarin speech recognition isn't available right now. Check your connection or try again later."
        case .noInputAudio:
            "No microphone input was found."
        }
    }
}

/// Wraps AVAudioEngine (mic capture) and SFSpeechRecognizer (Apple's built-in recognition).
///
/// Deliberately NOT @MainActor: the audio tap callback runs on a realtime audio thread,
/// and a main-actor-isolated closure there crashes at runtime. Results are handed back
/// through @Sendable callbacks and the caller hops to the main actor.
final class SpeechTranscriber: @unchecked Sendable {
    // Lazy so file-based testing never touches the audio hardware at all.
    private lazy var audioEngine = AVAudioEngine()
    private var micInUse = false
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var fileRequest: SFSpeechURLRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    /// Use the downloaded on-device model when the device has one (works offline, no time limit).
    /// Set to false to force Apple's server recognition and compare accuracy.
    var preferOnDevice = true

    var usesOnDevice: Bool { preferOnDevice && (recognizer?.supportsOnDeviceRecognition ?? false) }

    // MARK: - Permissions

    static func requestPermissions() async throws {
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0) }
        }
        guard speechStatus == .authorized else { throw SpeechInputError.speechPermissionDenied }

        let micGranted = await AVAudioApplication.requestRecordPermission()
        guard micGranted else { throw SpeechInputError.microphonePermissionDenied }
    }

    // MARK: - Start / stop

    /// `onUpdate` is called with the full transcript so far (not a delta) on every partial result.
    func start(
        onUpdate: @escaping @Sendable (_ transcript: String, _ isFinal: Bool) -> Void,
        onFailure: @escaping @Sendable (Error) -> Void
    ) async throws {
        cancel()

        guard let recognizer, recognizer.isAvailable else { throw SpeechInputError.recognizerUnavailable }

        micInUse = true

        // .playAndRecord is what most working AVAudioEngine + Speech setups use —
        // .record alone is less common and less well exercised on Simulator.
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.taskHint = .dictation
        request.addsPunctuation = true
        if usesOnDevice { request.requiresOnDeviceRecognition = true }
        self.request = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        print("SpeechTranscriber: input format = \(format.sampleRate) Hz, \(format.channelCount) ch")

        // installTap crashes the process (an uncatchable Obj-C exception) if the format
        // is invalid, so this check MUST happen before installTap, not just around
        // audioEngine.start() — the crash happens earlier than that.
        guard format.sampleRate > 0, format.channelCount > 0 else {
            cancel()
            throw SpeechInputError.noInputAudio
        }

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("SpeechTranscriber: audioEngine.start() failed — \(error)")
            cancel()
            throw SpeechInputError.noInputAudio
        }

        task = recognizer.recognitionTask(with: request) { result, error in
            if let result {
                onUpdate(result.bestTranscription.formattedString, result.isFinal)
            }
            if let error {
                onFailure(error)
            }
        }
    }

    /// Stops the mic but lets the recognizer deliver its final result.
    func stop() {
        if micInUse {
            if audioEngine.isRunning { audioEngine.stop() }
            audioEngine.inputNode.removeTap(onBus: 0)
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            micInUse = false
        }
        request?.endAudio()
        request = nil
    }

    /// Stops everything immediately and discards any pending result.
    func cancel() {
        stop()
        task?.cancel()
        task = nil
        fileRequest = nil
    }

    // MARK: - File input (testing without a microphone)

    /// Runs the same recognizer on a bundled audio file instead of the mic.
    /// Never touches AVAudioEngine or AVAudioSession, so it works even when the
    /// Simulator's audio hardware is broken. Callbacks match `start(...)`.
    func transcribeFile(
        at url: URL,
        onUpdate: @escaping @Sendable (_ transcript: String, _ isFinal: Bool) -> Void,
        onFailure: @escaping @Sendable (Error) -> Void
    ) throws {
        cancel()
        guard let recognizer, recognizer.isAvailable else { throw SpeechInputError.recognizerUnavailable }

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = true
        request.addsPunctuation = true
        if usesOnDevice { request.requiresOnDeviceRecognition = true }
        fileRequest = request

        task = recognizer.recognitionTask(with: request) { result, error in
            if let result {
                onUpdate(result.bestTranscription.formattedString, result.isFinal)
            }
            if let error {
                onFailure(error)
            }
        }
    }
}
