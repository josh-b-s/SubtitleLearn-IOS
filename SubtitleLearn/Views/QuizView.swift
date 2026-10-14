import SwiftUI
import SwiftData

struct QuizView: View {
    /// Words handed over by the session summary. Starts a quiz on just these, then clears.
    @Binding var pendingReview: [String]?

    @Environment(\.modelContext) private var modelContext
    @Query private var words: [SavedWord]
    @State private var viewModel = QuizViewModel()
    @State private var confirmingQuit = false

    private var activeCount: Int { words.filter { !$0.isMastered }.count }
    private var dueCount: Int { words.filter { !$0.isMastered && $0.isDue }.count }

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
                if !viewModel.isInProgress {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink { StatsView() } label: { Image(systemName: "chart.bar.xaxis") }
                            .accessibilityLabel("Stats")
                    }
                }
                if viewModel.isInProgress {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Quit") { confirmingQuit = true }
                    }
                }
                if case .answering = viewModel.phase {
                    ToolbarItem(placement: .topBarTrailing) { Text(viewModel.progressText).foregroundStyle(.secondary) }
                }
            }
            .task(id: pendingReview) { await startPendingReview() }
            .confirmationDialog("Quit this quiz?", isPresented: $confirmingQuit, titleVisibility: .visible) {
                Button("Quit Quiz", role: .destructive) { viewModel.reset() }
                Button("Keep Going", role: .cancel) {}
            } message: {
                Text("Answers you've already submitted are saved.")
            }
        }
    }

    private func startPendingReview() async {
        guard let list = pendingReview else { return }
        pendingReview = nil
        viewModel.reset()
        await Task.yield()   // let freshly saved words land in the store
        let all = (try? modelContext.fetch(FetchDescriptor<SavedWord>())) ?? words
        Task { await viewModel.start(allWords: all, focus: Set(list)) }
    }

    private var startPrompt: some View {
        QuizHomeView(dueCount: dueCount, activeCount: activeCount) {
            Task { await viewModel.start(allWords: words) }
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
                        viewModel.submit(allWords: words, context: modelContext)
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
