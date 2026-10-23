import SwiftUI

/// Bottom sheet shown when a word card is tapped.
struct WordDetailSheet: View {
    let token: WordToken
    let isSaved: Bool
    var progress: Binding<Double>? = nil   // only for saved words
    let onToggleSave: () -> Void

    @State private var glosses: [CharGloss] = []
    @State private var headerHeight: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var buttonHeight: CGFloat = 0
    @State private var bottomInset: CGFloat = 0
    @State private var confirmingRemove = false
    @ScaledMetric(relativeTo: .largeTitle) private var wordSize = 52

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Text(token.text)
                    .font(.system(size: wordSize, weight: .bold))
                if !token.pinyin.isEmpty {
                    Text(token.pinyin)
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)
                }
                HStack(spacing: 12) {
                    SpeakButton(word: token.text, font: .title3)
                    if AudioClipStore.hasClip(for: token.text) { ReplayClipButton(word: token.text) }
                }
                .controlSize(.large)
                .padding(.top, 8)
            }
            .padding(.top, 28)
            .padding(.bottom, 20)
            .overlay(alignment: .topTrailing) {
                SlowSpeechButton().font(.title3).padding(.top, 14)
            }
            .measureHeight(into: $headerHeight)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    meanings
                    if !glosses.isEmpty {
                        CharacterBreakdown(glosses: glosses)
                    }
                    if let progress {
                        MasteryPicker(progress: progress)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 12)
                .measureHeight(into: $contentHeight)
            }
            .scrollBounceBehavior(.basedOnSize)

            Button { if isSaved { confirmingRemove = true } else { onToggleSave() } } label: {
                Text(isSaved ? "Remove from Vocabulary" : "Save to Vocabulary")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 36)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 18))
            .controlSize(.large)
            .tint(isSaved ? .red : .accentColor)
            .accessibilityHint(isSaved ? "Deletes this word and its progress" : "Adds this word to your quiz")
            .alert("Remove \(token.text)?", isPresented: $confirmingRemove) {
                Button("Remove", role: .destructive, action: onToggleSave)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Its level and review history are deleted too.")
            }
            .padding(.bottom, 8)
            .measureHeight(into: $buttonHeight)
        }
        .padding(.horizontal, 24)
        .onGeometryChange(for: CGFloat.self) { $0.safeAreaInsets.bottom } action: { bottomInset = $0 }
        .task(id: token.text) {
            glosses = await DictionaryLoader.shared.value?.breakdown(for: token.text) ?? []
        }
        .presentationDetents(detents)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
    }

    /// Opens just tall enough to show everything, so the mastery picker isn't hidden below the fold.
    private var detents: Set<PresentationDetent> {
        guard contentHeight > 0 else { return [.medium, .large] }
        let fit = headerHeight + 1 + contentHeight + buttonHeight + bottomInset
        return [.height(fit), .large]
    }

    private var meanings: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MEANINGS")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)

            if token.meanings.isEmpty {
                Text("No definition").foregroundStyle(.secondary)
            } else {
                ForEach(Array(token.meanings.enumerated()), id: \.offset) { index, meaning in
                    Text("\(index + 1). \(meaning)").font(.title3)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
