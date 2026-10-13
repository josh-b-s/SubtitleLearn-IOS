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
    private var running = false   // any live session (mic or external audio)
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private var fileRequest: SFSpeechURLRecognitionRequest?

    // Shared with the audio tap thread, so guarded by `lock`.
    private let lock = NSLock()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var taskSerial = 0

    // Mic session state, set in start().
    private var continuous = false
    private var failureStreak = 0
    private var onUpdate: (@Sendable (String, Bool) -> Void)?
    private var onFailure: (@Sendable (Error) -> Void)?

    /// Use the downloaded on-device model when the device has one (works offline, no time limit).
    /// Set to false to force Apple's server recognition and compare accuracy.
    var preferOnDevice = true

    /// Audio session setup. Defaults suit dictation; Screen Share overrides them
    /// so other apps' audio keeps playing at full volume.
    var sessionMode: AVAudioSession.Mode = .measurement
    var sessionOptions: AVAudioSession.CategoryOptions = [.duckOthers, .defaultToSpeaker]

    /// Closes an utterance that grows past this many characters and starts a fresh recognition
    /// task. Without it, speech with no pauses makes every update slower. Off when nil.
    var maxSegmentCharacters: Int?

    var usesOnDevice: Bool { preferOnDevice && (recognizer?.supportsOnDeviceRecognition ?? false) }

    // MARK: - Permissions

    static func requestSpeechPermission() async throws {
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0) }
        }
        guard speechStatus == .authorized else { throw SpeechInputError.speechPermissionDenied }
    }

    static func requestPermissions() async throws {
        try await requestSpeechPermission()

        let micGranted = await AVAudioApplication.requestRecordPermission()
        guard micGranted else { throw SpeechInputError.microphonePermissionDenied }
    }

    // MARK: - Mic input

    /// `onUpdate` receives the full transcript of the current segment (not a delta).
    /// With `continuous` on, a finished segment is followed by a fresh recognition task
    /// while the mic keeps running, so live subtitles never stop at the recognizer's limits.
    func start(
        continuous: Bool = false,
        onUpdate: @escaping @Sendable (_ transcript: String, _ isFinal: Bool) -> Void,
        onFailure: @escaping @Sendable (Error) -> Void
    ) async throws {
        cancel()
        guard let recognizer, recognizer.isAvailable else { throw SpeechInputError.recognizerUnavailable }

        micInUse = true
        running = true
        self.continuous = continuous
        failureStreak = 0
        self.onUpdate = onUpdate
        self.onFailure = onFailure

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: sessionMode, options: sessionOptions)
            try session.setActive(true)

            let inputNode = audioEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)

            // installTap raises an uncatchable Obj-C exception on an invalid format,
            // so check before installing it.
            guard format.sampleRate > 0, format.channelCount > 0 else {
                throw SpeechInputError.noInputAudio
            }

            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
                self?.appendToCurrentRequest(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            cancel()
            throw error
        }

        beginTask()
    }

    // MARK: - External audio

    /// Recognition on audio supplied by the caller (for example from the broadcast extension).
    /// No microphone or audio session is touched. Feed audio with `appendExternal(_:)`.
    func startExternal(
        continuous: Bool = true,
        onUpdate: @escaping @Sendable (_ transcript: String, _ isFinal: Bool) -> Void,
        onFailure: @escaping @Sendable (Error) -> Void
    ) throws {
        cancel()
        guard let recognizer, recognizer.isAvailable else { throw SpeechInputError.recognizerUnavailable }

        running = true
        self.continuous = continuous
        failureStreak = 0
        self.onUpdate = onUpdate
        self.onFailure = onFailure
        beginTask()
    }

    func appendExternal(_ buffer: AVAudioPCMBuffer) {
        appendToCurrentRequest(buffer)
    }

    /// Stops the mic but lets the recognizer deliver its final result.
    func stop() {
        if micInUse {
            if audioEngine.isRunning { audioEngine.stop() }
            audioEngine.inputNode.removeTap(onBus: 0)
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            micInUse = false
        }
        running = false
        lock.lock()
        let current = request
        request = nil
        lock.unlock()
        current?.endAudio()
    }

    /// Stops everything immediately and discards any pending result.
    func cancel() {
        stop()
        lock.lock()
        taskSerial += 1
        let oldTask = task
        task = nil
        lock.unlock()
        oldTask?.cancel()
        fileRequest = nil
        onUpdate = nil
        onFailure = nil
    }

    // MARK: - Recognition task

    private func appendToCurrentRequest(_ buffer: AVAudioPCMBuffer) {
        lock.lock()
        let current = request
        lock.unlock()
        current?.append(buffer)
    }

    private func beginTask() {
        guard let recognizer else { return }

        let newRequest = SFSpeechAudioBufferRecognitionRequest()
        newRequest.shouldReportPartialResults = true
        newRequest.taskHint = .dictation
        newRequest.addsPunctuation = true
        if usesOnDevice { newRequest.requiresOnDeviceRecognition = true }

        lock.lock()
        taskSerial += 1
        let serial = taskSerial
        request = newRequest
        let oldTask = task
        lock.unlock()
        oldTask?.cancel()

        let newTask = recognizer.recognitionTask(with: newRequest) { [weak self] result, error in
            self?.handle(result: result, error: error, serial: serial)
        }
        lock.lock()
        task = newTask
        lock.unlock()
    }

    private func isCurrent(_ serial: Int) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return serial == taskSerial
    }

    private func handle(result: SFSpeechRecognitionResult?, error: Error?, serial: Int) {
        // Ignore late callbacks from tasks that were replaced or cancelled.
        guard isCurrent(serial) else { return }

        if let result {
            let text = result.bestTranscription.formattedString
            let overlong = !result.isFinal && continuous && running && text.count > (maxSegmentCharacters ?? .max)
            onUpdate?(text, result.isFinal || overlong)
            if overlong {
                beginTask()
                return
            }
        }
        let ended = (result?.isFinal ?? false) || error != nil
        guard ended else { return }

        guard continuous, running else {
            if let error { onFailure?(error) }
            return
        }

        if let error, !Self.isBenign(error) {
            failureStreak += 1
            if failureStreak >= 3 {
                let fail = onFailure
                cancel()
                fail?(error)
                return
            }
        } else {
            failureStreak = 0
        }

        // Drop mic audio until the next task starts, then roll over.
        lock.lock()
        request = nil
        lock.unlock()
        scheduleRestart(after: error == nil ? 0 : 0.5, serial: serial)
    }

    private func scheduleRestart(after delay: TimeInterval, serial: Int) {
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self, self.running, self.isCurrent(serial) else { return }
            self.beginTask()
        }
    }

    /// "No speech detected" just means silence, not a real failure.
    private static func isBenign(_ error: Error) -> Bool {
        let ns = error as NSError
        return ns.domain == "kAFAssistantErrorDomain" && ns.code == 1110
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

        let newTask = recognizer.recognitionTask(with: request) { result, error in
            if let result {
                onUpdate(result.bestTranscription.formattedString, result.isFinal)
            }
            if let error {
                onFailure(error)
            }
        }
        lock.lock()
        task = newTask
        lock.unlock()
    }
}
