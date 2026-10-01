import SwiftUI

struct ScreenShareView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Screen Share", systemImage: "airplayvideo",
                                   description: Text("Live subtitles in Picture-in-Picture are coming in a later stage."))
                .navigationTitle("Screen Share")
        }
    }
}
