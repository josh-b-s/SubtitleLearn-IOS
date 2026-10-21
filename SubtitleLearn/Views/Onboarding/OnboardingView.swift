import SwiftUI

/// First launch tour of the main tabs. Also reachable again from Settings.
struct OnboardingView: View {
    static let seenKey = "hasSeenOnboarding"

    let onFinish: () -> Void

    @State private var index = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let pages = OnboardingPage.all
    private var isLast: Bool { index == pages.count - 1 }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if !isLast {
                    Button("Skip", action: onFinish)
                        .accessibilityHint("Closes the introduction")
                }
            }
            .padding(.horizontal, 20)
            .frame(minHeight: 44)

            TabView(selection: $index) {
                ForEach(pages) { page in
                    OnboardingPageView(page: page).tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button(action: advance) {
                Text(isLast ? "Get started" : "Next")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 32)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 18))
            .controlSize(.large)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func advance() {
        if isLast {
            onFinish()
        } else {
            withAnimation(reduceMotion ? nil : .default) { index += 1 }
        }
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
