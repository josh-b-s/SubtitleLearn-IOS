import ReplayKit

/// Broadcast Upload Extension entry point. Only system audio is used; video is ignored.
final class SampleHandler: RPBroadcastSampleHandler {
    private var writer: BroadcastAudioWriter?
    private var lastStopCheck = Date()

    override func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
        writer = BroadcastAudioWriter()
    }

    override func broadcastFinished() {
        writer?.finish()
        writer = nil
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        checkForStopRequest()
        guard sampleBufferType == .audioApp else { return }
        writer?.write(sampleBuffer)
    }

    /// The app can end the broadcast by dropping a stop file in the shared folder.
    private func checkForStopRequest() {
        let now = Date()
        guard now.timeIntervalSince(lastStopCheck) > 1 else { return }
        lastStopCheck = now
        guard BroadcastShared.consumeStopRequest() else { return }

        writer?.finish()
        finishBroadcastWithError(NSError(
            domain: "SubtitleLearn",
            code: 0,
            userInfo: [NSLocalizedFailureReasonErrorKey: "Live subtitles stopped."]
        ))
    }
}
