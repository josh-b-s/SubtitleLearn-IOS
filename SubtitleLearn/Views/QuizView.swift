import SwiftUI
import SwiftData

struct QuizView: View {
    @Query private var words: [SavedWord]
    @State private var viewModel = QuizViewModel()
    @State private var confirmingQuit = false

    private var activeCount: Int { words.filter { !$0.isMastered }.count }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.phase {
                case .idle:
                    startPrompt
                case .loading:
                    ProgressView("Building quiz…").frame(maxHeight: .infinity)
                case .answering:
                    questionScreen
                case .feedback(let feedback):
                    QuizFeedbackView(feedback: feedback) { viewModel.next() }
                case .finished(let summary):
                    finishedScreen(summary)
                case .error(let message):
                    errorScreen(message)
                }
            }
            .navigationTitle("Quiz")
            .toolbar {
                if viewModel.isInProgress {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Quit") { confirmingQuit = true }
                    }
                }
                if case .answering = viewModel.phase {
                    ToolbarItem(placement: .topBarTrailing) { Text(viewModel.progressText).foregroundStyle(.secondary) }
                }
            }
            .confirmationDialog("Quit this quiz?", isPresented: $confirmingQuit, titleVisibility: .visible) {
                Button("Quit Quiz", role: .destructive) { viewModel.reset() }
                Button("Keep Going", role: .cancel) {}
            } message: {
                Text("Answers you've already submitted are saved.")
            }
        }
    }

    private var startPrompt: some View {
        ContentUnavailableView {
            Label("Ready to review?", systemImage: "brain")
        } description: {
            Text("Reviews your \(activeCount) word\(activeCount == 1 ? "" : "s") still being learned, due ones first. Questions get harder as you learn each word, and missed ones come back at the end.")
        } actions: {
            Button("Start Quiz") { Task { await viewModel.start(allWords: words) } }
                .buttonStyle(.borderedProminent)
        }
    }

    private func errorScreen(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Can't start quiz", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") { Task { await viewModel.start(allWords: words) } }
        }
    }

    private func finishedScreen(_ summary: QuizSummary) -> some View {
        ContentUnavailableView {
            Label("Quiz complete", systemImage: "checkmark.circle.fill")
        } description: {
            Text(summaryText(summary))
        } actions: {
            Button("New Quiz") { viewModel.reset() }
                .buttonStyle(.borderedProminent)
        }
    }

    private func summaryText(_ s: QuizSummary) -> String {
        var text = "\(s.correctFirstTry) of \(s.attempted) right on the first try."
        if s.leveledUp > 0 { text += " \(s.leveledUp) word\(s.leveledUp == 1 ? "" : "s") moved up a level." }
        if s.mastered > 0 { text += " \(s.mastered) mastered." }
        return text
    }

    // MARK: - Question

    private var questionScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let note = viewModel.note {
                    Text(note).font(.footnote).foregroundStyle(Color.orange)
                }
                if let question = viewModel.currentQuestion {
                    QuizQuestionView(
                        question: question,
                        selectedChoice: $viewModel.selectedChoice,
                        selectedPinyin: $viewModel.selectedPinyin,
                        selectedMeaning: $viewModel.selectedMeaning
                    )
                    .id(question.id)

                    Button {
                        viewModel.submit(allWords: words)
                    } label: {
                        Text("Submit").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!viewModel.canSubmit)
                }
            }
            .padding(20)
        }
    }
}
