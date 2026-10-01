import SwiftUI
import SwiftData

struct QuizView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var words: [SavedWord]
    @State private var viewModel = QuizViewModel()

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.phase {
                case .idle:
                    startPrompt
                case .loading:
                    ProgressView("Generating quiz…").frame(maxHeight: .infinity)
                case .answering, .grading:
                    questionScreen
                case .feedback(let result):
                    feedbackScreen(result)
                case .finished(let reviewed):
                    finishedScreen(reviewed)
                case .error(let message):
                    errorScreen(message)
                }
            }
            .navigationTitle("Quiz")
            .toolbar {
                if case .answering = viewModel.phase {
                    ToolbarItem(placement: .topBarTrailing) { Text(viewModel.progressText).foregroundStyle(.secondary) }
                }
            }
        }
    }

    private var startPrompt: some View {
        ContentUnavailableView {
            Label("Ready to review?", systemImage: "brain")
        } description: {
            Text("Generates questions from your \(words.count) saved word\(words.count == 1 ? "" : "s"), prioritising ones that are due.")
        } actions: {
            Button("Start Quiz") { Task { await viewModel.start(allWords: words, modelContext: modelContext) } }
                .buttonStyle(.borderedProminent)
        }
    }

    private func errorScreen(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Couldn't start quiz", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") { Task { await viewModel.start(allWords: words, modelContext: modelContext) } }
        }
    }

    private func finishedScreen(_ reviewed: Int) -> some View {
        ContentUnavailableView {
            Label("Quiz complete", systemImage: "checkmark.circle.fill")
        } description: {
            Text("Reviewed \(reviewed) word\(reviewed == 1 ? "" : "s"). Their next review dates have been updated.")
        } actions: {
            Button("New Quiz") { viewModel.reset() }
                .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Question

    private var questionScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let question = viewModel.currentQuestion {
                    Text(questionKindLabel(question.type))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.accentColor)

                    Text(question.prompt)
                        .font(.title2.weight(.medium))
                        .fixedSize(horizontal: false, vertical: true)

                    answerInput(for: question)

                    Button {
                        Task { await viewModel.submit(allWords: words, modelContext: modelContext) }
                    } label: {
                        if case .grading = viewModel.phase {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Submit").frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!canSubmit(question) || isGrading)
                }
            }
            .padding(20)
        }
    }

    private var isGrading: Bool { if case .grading = viewModel.phase { true } else { false } }

    private func canSubmit(_ question: QuizQuestion) -> Bool {
        question.type == .multipleChoice
            ? viewModel.selectedChoice != nil
            : !viewModel.userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @ViewBuilder
    private func answerInput(for question: QuizQuestion) -> some View {
        if question.type == .multipleChoice {
            VStack(spacing: 10) {
                ForEach(question.choices ?? [], id: \.self) { choice in
                    Button {
                        viewModel.selectedChoice = choice
                    } label: {
                        Text(choice)
                            .font(.title3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(viewModel.selectedChoice == choice ? Color.accentColor.opacity(0.15) : Color(.secondarySystemGroupedBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(viewModel.selectedChoice == choice ? Color.accentColor : .clear, lineWidth: 2)
                            )
                    }
                    .foregroundStyle(.primary)
                }
            }
        } else {
            TextField(placeholderText(for: question.type), text: $viewModel.userAnswer, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.title3)
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private func placeholderText(for type: QuizQuestionType) -> String {
        switch type {
        case .fillBlank: "Fill in the blank"
        case .translateToChinese: "Type the Chinese translation"
        case .translateToEnglish: "Type the English translation"
        case .sentenceCorrection: "Type the corrected sentence"
        case .multipleChoice: ""
        }
    }

    private func questionKindLabel(_ type: QuizQuestionType) -> String {
        switch type {
        case .fillBlank: "FILL IN THE BLANK"
        case .translateToChinese: "TRANSLATE TO CHINESE"
        case .translateToEnglish: "TRANSLATE TO ENGLISH"
        case .multipleChoice: "MULTIPLE CHOICE"
        case .sentenceCorrection: "FIX THE SENTENCE"
        }
    }

    // MARK: - Feedback

    private func feedbackScreen(_ result: GradeResult) -> some View {
        VStack(spacing: 20) {
            Image(systemName: result.quality >= 5 ? "checkmark.circle.fill" : (result.quality >= 3 ? "circle.lefthalf.filled" : "xmark.circle.fill"))
                .font(.system(size: 56))
                .foregroundStyle(result.quality >= 5 ? Color.green : (result.quality >= 3 ? Color.orange : Color.red))

            if let question = viewModel.currentQuestion, question.type != .multipleChoice {
                VStack(spacing: 4) {
                    Text("Expected: \(question.answer)").font(.subheadline).foregroundStyle(.secondary)
                }
            }

            Text(result.feedback)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Continue") { viewModel.next() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .padding(20)
        .frame(maxHeight: .infinity)
    }
}
