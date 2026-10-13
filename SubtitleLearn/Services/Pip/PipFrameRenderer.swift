import SwiftUI
import AVFoundation
import Combine
import os

private let logger = Logger(subsystem: "SubtitleLearn", category: "Pip")

/// Draws a SwiftUI view into an AVSampleBufferDisplayLayer each time the view changes.
@MainActor
final class PipFrameRenderer {
    private static let framesPerSecond = 10.0

    private let layer: AVSampleBufferDisplayLayer
    private let renderer: ImageRenderer<AnyView>
    private let scale = UIScreen.main.scale
    private var subscription: AnyCancellable?

    init(content: AnyView, layer: AVSampleBufferDisplayLayer) {
        self.layer = layer
        renderer = ImageRenderer(content: content)
        subscription = renderer.objectWillChange
            .throttle(for: .seconds(1 / Self.framesPerSecond), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] _ in self?.render() }
        render()
    }

    private func render() {
        var pixels: CVPixelBuffer?
        renderer.render { size, draw in
            let width = Int(size.width * scale)
            let height = Int(size.height * scale)
            guard width > 0, height > 0 else { return }

            let attributes = [
                kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
                kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!,
                kCVPixelBufferIOSurfacePropertiesKey: [:] as CFDictionary,
            ] as CFDictionary
            let status = CVPixelBufferCreate(
                kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attributes, &pixels
            )
            guard status == kCVReturnSuccess, let buffer = pixels else {
                logger.error("pixel buffer failed, status \(status)")
                return
            }

            CVPixelBufferLockBaseAddress(buffer, [])
            defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
            guard let context = CGContext(
                data: CVPixelBufferGetBaseAddress(buffer),
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
            ) else {
                logger.error("bitmap context failed")
                return
            }
            context.scaleBy(x: scale, y: scale)
            draw(context)
        }

        guard let pixels else { return }
        do {
            let sample = try Self.sampleBuffer(for: pixels)
            if layer.status == .failed { layer.flush() }
            layer.enqueue(sample)
        } catch {
            logger.error("sample buffer failed: \(error.localizedDescription)")
        }
    }

    private static func sampleBuffer(for pixels: CVPixelBuffer) throws -> CMSampleBuffer {
        var format: CMVideoFormatDescription?
        let status = CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault, imageBuffer: pixels, formatDescriptionOut: &format
        )
        guard status == noErr, let format else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
        let now = CMTime(seconds: CACurrentMediaTime(), preferredTimescale: 120)
        let timing = CMSampleTimingInfo(
            duration: CMTime(seconds: 1, preferredTimescale: 60),
            presentationTimeStamp: now,
            decodeTimeStamp: now
        )
        return try CMSampleBuffer(imageBuffer: pixels, formatDescription: format, sampleTiming: timing)
    }
}
