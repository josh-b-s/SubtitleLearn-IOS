import Foundation

/// One screen of the first launch tour.
struct OnboardingPage: Identifiable {
    let id: Int
    let symbol: String
    let title: String
    let text: String
    var note: String? = nil

    /// Same order and icons as the tab bar.
    static let all: [OnboardingPage] = [
        OnboardingPage(
            id: 0, symbol: "airplayvideo", title: "Subtitles for what you watch",
            text: "Play a video or podcast in Chinese. The app listens and shows each word with its pinyin and meaning in a floating window. Words you hear are collected so you can review them afterwards.",
            note: "Needs a real device. In Settings you can hide hints for words you know and choose on-device or server speech recognition."
        ),
        OnboardingPage(
            id: 1, symbol: "arrow.left.arrow.right", title: "Look up any Chinese text",
            text: "Speak into the microphone or paste text. Tap a word to see its meaning, pinyin and each character, then save it to your vocabulary.",
            note: "In Settings you can choose on-device or server speech recognition."
        ),
        OnboardingPage(
            id: 2, symbol: "bookmark", title: "Keep the words you save",
            text: "Search and filter your words by mastery level, or set a level yourself. You can also search the whole dictionary and add words you already know."
        ),
        OnboardingPage(
            id: 3, symbol: "brain", title: "Review with spaced repetition",
            text: "Questions get harder as a word moves up a level. Words you miss come back at the end of the quiz. The stats screen tracks your streak and progress.",
            note: "In Settings you can set how many questions a quiz has and add a Gemini key for level 3."
        )
    ]
}
