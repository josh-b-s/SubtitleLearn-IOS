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
    private let audioEngine = AVAudioEngine()
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private var request: SFSpeechAudioBufferRecognitionRequest?
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
    ) throws {
        cancel()

        guard let recognizer, recognizer.isAvailable else { throw SpeechInputError.recognizerUnavailable }

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.taskHint = .dictation
        request.addsPunctuation = true
        if usesOnDevice { request.requiresOnDeviceRecognition = true }
        self.request = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        guard format.sampleRate > 0 else {
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
            cancel()
            throw error
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
        if audioEngine.isRunning { audioEngine.stop() }
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        request = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    /// Stops everything immediately and discards any pending result.
    func cancel() {
        stop()
        task?.cancel()
        task = nil
    }
}
