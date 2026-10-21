import SwiftUI

struct AboutView: View {
    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    var body: some View {
        List {
            Section("App") {
                LabeledContent("Name", value: "Subtitle Learn")
                LabeledContent("Version", value: version)
                Text("Learn Mandarin from the video and audio you already watch. Live subtitles appear as tappable word cards, saved words go into a spaced repetition quiz.")
                    .font(.subheadline)
            }

            Section("Author") {
                LabeledContent("Name", value: "Josh Brian Saputra")
            }

            Section("Acknowledgements") {
                credit(
                    "CedPane",
                    "Chinese-English Dictionary Public-domain Additions for Names Etc, by ssb22. Source of words and definitions (PD-English-Definitions.tsv).",
                    link: "https://github.com/ssb22/CedPane"
                )
                credit(
                    "CC-CEDICT",
                    "Community Chinese-English dictionary from MDBG, used for pinyin. Licensed under CC BY-SA.",
                    link: "https://cc-cedict.org"
                )
                credit(
                    "pypinyin",
                    "Python library that filled in pinyin for words missing from CC-CEDICT when the word list was built.",
                    link: "https://github.com/mozillazg/python-pinyin"
                )
                credit(
                    "Google Gemini API",
                    "Writes the example sentences for level 3 quiz questions.",
                    link: "https://ai.google.dev"
                )
                credit(
                    "Apple frameworks",
                    "Speech for transcription, ReplayKit for screen share audio, AVKit for picture in picture, Charts for the stats screen, SwiftData for storage."
                )
                credit(
                    "AI assistance",
                    "Some code was written with help from Claude (Anthropic). I reviewed and can explain all of it."
                )
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func credit(_ title: String, _ detail: String, link: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline)
            Text(detail).font(.subheadline).foregroundStyle(.secondary)
            if let link, let url = URL(string: link) {
                Link(link, destination: url).font(.footnote)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack { AboutView() }
}
