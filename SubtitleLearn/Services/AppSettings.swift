import Foundation
import Observation

/// Small UserDefaults-backed settings store. The Gemini key is stored in plain
/// UserDefaults for simplicity (fine for a student project, but move it to
/// the Keychain before shipping anything real).
@MainActor
@Observable
final class AppSettings {
    static let shared = AppSettings()

    var geminiAPIKey: String {
        didSet { UserDefaults.standard.set(geminiAPIKey, forKey: Self.keyDefaultsKey) }
    }
    var questionsPerQuiz: Int {
        didSet { UserDefaults.standard.set(questionsPerQuiz, forKey: Self.countDefaultsKey) }
    }

    var preferOnDeviceSpeech: Bool {
        didSet { UserDefaults.standard.set(preferOnDeviceSpeech, forKey: Self.onDeviceDefaultsKey) }
    }

    private static let onDeviceDefaultsKey = "preferOnDeviceSpeech"
    private static let keyDefaultsKey = "geminiAPIKey"
    private static let countDefaultsKey = "questionsPerQuiz"

    private init() {
        geminiAPIKey = UserDefaults.standard.string(forKey: Self.keyDefaultsKey) ?? ""
        let saved = UserDefaults.standard.integer(forKey: Self.countDefaultsKey)
        questionsPerQuiz = saved > 0 ? saved : 8
        preferOnDeviceSpeech = UserDefaults.standard.object(forKey: Self.onDeviceDefaultsKey) as? Bool ?? true
    }
}
