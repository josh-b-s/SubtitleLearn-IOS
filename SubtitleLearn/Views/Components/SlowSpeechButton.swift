import SwiftUI

/// Toolbar button that turns slow speech on or off.
struct SlowSpeechButton: View {
    @State private var settings = AppSettings.shared

    var body: some View {
        Button { settings.speakSlowly.toggle() } label: {
            Image(systemName: settings.speakSlowly ? "tortoise.fill" : "tortoise")
        }
        .accessibilityLabel("Speak slowly")
        .accessibilityValue(settings.speakSlowly ? "On" : "Off")
    }
}
