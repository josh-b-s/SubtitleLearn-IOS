import SwiftUI
import Pipify

/// Screen Share tab. For now it tests PiP with a mock subtitle stream.
struct ScreenShareView: View {
    @StateObject private var subtitles = PipSubtitleModel()
    @State private var isPipPresented = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    mockMedia
                    pipButton
                    Text(helpText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Screen Share")
        }
        .pipify(isPresented: $isPipPresented) {
            PipSubtitleView(model: subtitles)
        }
        .onChange(of: isPipPresented) { _, presented in
            if !presented { subtitles.stop() }
        }
    }

    /// Stand-in for the media being watched, with the same subtitle panel the PiP shows.
    private var mockMedia: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(red: 0.06, green: 0.1, blue: 0.2), .black, Color(red: 0.45, green: 0.25, blue: 0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            Text("Mock video")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.5))
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(12)
            PipSubtitleView(model: subtitles)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 420)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var pipButton: some View {
        Button {
            if isPipPresented {
                isPipPresented = false
            } else {
                subtitles.start()
                isPipPresented = true
            }
        } label: {
            Label(
                isPipPresented ? "Stop Picture in Picture" : "Start Picture in Picture demo",
                systemImage: isPipPresented ? "pip.exit" : "pip.enter"
            )
            .font(.title3.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 32)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 18))
        .controlSize(.large)
        .disabled(!PipifyController.isSupported)
    }

    private var helpText: String {
        PipifyController.isSupported
            ? "Starts a floating window with a mock stream of words. Press Home afterwards to see it stay on top of other apps."
            : "Picture in Picture isn't supported on this device or simulator."
    }
}
