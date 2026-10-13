import AVKit
import SwiftUI
import os

private let logger = Logger(subsystem: "SubtitleLearn", category: "Pip")

/// Picture in Picture window that shows a SwiftUI view.
///
/// `present()` keeps trying until iOS opens the window. The first attempt often lands while
/// the app is inactive (as the broadcast sheet closes) and iOS rejects it.
@MainActor
final class PipController: NSObject, ObservableObject {
    static var isSupported: Bool { AVPictureInPictureController.isPictureInPictureSupported() }

    private static let retryInterval: Duration = .seconds(1)

    @Published private(set) var isActive = false

    /// PiP only starts while this layer is in the view tree, see `PipLayerHost`.
    let displayLayer = AVSampleBufferDisplayLayer()

    private var pip: AVPictureInPictureController?
    private var frames: PipFrameRenderer?
    private var retryTask: Task<Void, Never>?
    private var isStarting = false

    override init() {
        super.init()
        configureAudioSession()
        displayLayer.frame.size = CGSize(width: 300, height: 100)
        displayLayer.videoGravity = .resizeAspect

        let source = AVPictureInPictureController.ContentSource(
            sampleBufferDisplayLayer: displayLayer,
            playbackDelegate: self
        )
        let controller = AVPictureInPictureController(contentSource: source)
        controller.requiresLinearPlayback = true
        controller.delegate = self
        pip = controller
    }

    /// Sets the view shown in the window. Only the first call has an effect.
    func setContent(_ content: some View) {
        guard frames == nil else { return }
        frames = PipFrameRenderer(content: AnyView(content), layer: displayLayer)
    }

    /// Opens the window, retrying every second until iOS accepts it. Safe to call repeatedly.
    func present() {
        guard !isActive else { return }
        retryTask?.cancel()
        retryTask = Task { [weak self] in
            while let self, !Task.isCancelled, !self.isActive {
                self.attemptStart()
                try? await Task.sleep(for: Self.retryInterval)
            }
        }
    }

    /// Closes the window, stops retrying and releases the audio session.
    func stop() {
        retryTask?.cancel()
        retryTask = nil
        isStarting = false
        pip?.stopPictureInPicture()
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            logger.notice("audio session not released: \(error.localizedDescription)")
        }
    }

    private func attemptStart() {
        guard let pip, !pip.isPictureInPictureActive, !isStarting else { return }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            logger.error("audio session not activated: \(error.localizedDescription)")
        }
        pip.invalidatePlaybackState()
        guard pip.isPictureInPicturePossible else { return }
        pip.startPictureInPicture()
    }

    /// PiP needs an active audio session. Mixing keeps the watched video's audio playing.
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        guard session.category == .soloAmbient || session.mode == .default else { return }
        do {
            try session.setCategory(.playback, mode: .moviePlayback, options: .mixWithOthers)
        } catch {
            logger.error("audio category not set: \(error.localizedDescription)")
        }
    }
}

extension PipController: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ controller: AVPictureInPictureController) {
        isStarting = true
    }

    func pictureInPictureControllerDidStartPictureInPicture(_ controller: AVPictureInPictureController) {
        isStarting = false
        isActive = true
        retryTask?.cancel()
        retryTask = nil
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ controller: AVPictureInPictureController) {
        isActive = false
    }

    func pictureInPictureController(
        _ controller: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        isStarting = false
        logger.error("PiP failed to start: \(error.localizedDescription)")
    }

    func pictureInPictureController(
        _ controller: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        completionHandler(true)
    }

    func pictureInPictureControllerShouldProhibitBackgroundAudioPlayback(_ controller: AVPictureInPictureController) -> Bool {
        false
    }
}

extension PipController: AVPictureInPictureSampleBufferPlaybackDelegate {
    func pictureInPictureController(_ controller: AVPictureInPictureController, setPlaying playing: Bool) {}

    func pictureInPictureControllerIsPlaybackPaused(_ controller: AVPictureInPictureController) -> Bool { false }

    /// A fixed range plus linear playback hides the skip buttons and the live label.
    func pictureInPictureControllerTimeRangeForPlayback(_ controller: AVPictureInPictureController) -> CMTimeRange {
        CMTimeRange(start: CMTime(value: 1, timescale: 1), end: CMTime(value: 2, timescale: 1))
    }

    func pictureInPictureController(
        _ controller: AVPictureInPictureController,
        didTransitionToRenderSize newRenderSize: CMVideoDimensions
    ) {}

    func pictureInPictureController(_ controller: AVPictureInPictureController, skipByInterval skipInterval: CMTime) async {}
}
