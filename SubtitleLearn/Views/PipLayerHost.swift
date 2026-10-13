import SwiftUI
import AVFoundation

/// Puts the PiP display layer into the view tree. iOS refuses to start PiP otherwise.
/// The view is invisible and parked off screen.
struct PipLayerHost: View {
    let layer: AVSampleBufferDisplayLayer

    var body: some View {
        LayerView(layer: layer)
            .opacity(0)
            .allowsHitTesting(false)
            .offset(CGSize(width: Int.max, height: Int.max))
    }
}

private struct LayerView: UIViewRepresentable {
    let layer: CALayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.layer.addSublayer(layer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
