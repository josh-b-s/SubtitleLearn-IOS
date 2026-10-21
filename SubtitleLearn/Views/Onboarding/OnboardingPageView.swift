import SwiftUI

/// Icon, title and text for one onboarding page. Scrolls so large Dynamic Type sizes still fit.
struct OnboardingPageView: View {
    let page: OnboardingPage

    @ScaledMetric(relativeTo: .largeTitle) private var iconSize = 72

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: page.symbol)
                    .font(.system(size: iconSize))
                    .foregroundStyle(Color.accentColor)
                    .accessibilityHidden(true)

                Text(page.title)
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(page.text)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                if let note = page.note {
                    Text(note)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.accentColor)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 48)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}
