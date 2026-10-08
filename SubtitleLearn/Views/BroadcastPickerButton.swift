import SwiftUI
import ReplayKit

/// Invisible wrapper around the system broadcast picker. Bump `trigger` to open it.
struct BroadcastPickerButton: UIViewRepresentable {
    let extensionBundleID: String?
    let trigger: Int

    /// Finds the broadcast extension embedded in this app, whatever it was named.
    static var embeddedExtensionBundleID: String? {
        guard let plugins = Bundle.main.builtInPlugInsURL,
              let urls = try? FileManager.default.contentsOfDirectory(at: plugins, includingPropertiesForKeys: nil)
        else { return nil }

        for url in urls where url.pathExtension == "appex" {
            guard let bundle = Bundle(url: url),
                  let ext = bundle.infoDictionary?["NSExtension"] as? [String: Any],
                  ext["NSExtensionPointIdentifier"] as? String == "com.apple.broadcast-services-upload"
            else { continue }
            return bundle.bundleIdentifier
        }
        return nil
    }

    func makeUIView(context: Context) -> RPSystemBroadcastPickerView {
        let picker = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        picker.preferredExtension = extensionBundleID
        picker.showsMicrophoneButton = false
        return picker
    }

    func updateUIView(_ picker: RPSystemBroadcastPickerView, context: Context) {
        picker.preferredExtension = extensionBundleID
        guard context.coordinator.lastTrigger != trigger else { return }
        context.coordinator.lastTrigger = trigger
        DispatchQueue.main.async {
            picker.subviews.compactMap { $0 as? UIButton }.first?.sendActions(for: .touchUpInside)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(lastTrigger: trigger) }

    final class Coordinator {
        var lastTrigger: Int
        init(lastTrigger: Int) { self.lastTrigger = lastTrigger }
    }
}
