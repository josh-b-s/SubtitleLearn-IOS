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

    var hideLearnedInPip: Bool {
        didSet { UserDefaults.standard.set(hideLearnedInPip, forKey: Self.hideLearnedDefaultsKey) }
    }

    var hideLearnedInTranslate: Bool {
        didSet { UserDefaults.standard.set(hideLearnedInTranslate, forKey: Self.hideTranslateDefaultsKey) }
    }

    var appearance: AppearanceMode {
        didSet { UserDefaults.standard.set(appearance.rawValue, forKey: Self.appearanceDefaultsKey) }
    }

    private static let appearanceDefaultsKey = "appearance"
    private static let hideLearnedDefaultsKey = "hideLearnedInPip"
    private static let hideTranslateDefaultsKey = "hideLearnedInTranslate"
    private static let onDeviceDefaultsKey = "preferOnDeviceSpeech"
    private static let keyDefaultsKey = "geminiAPIKey"
    private static let countDefaultsKey = "questionsPerQuiz"

    private init() {
        geminiAPIKey = UserDefaults.standard.string(forKey: Self.keyDefaultsKey) ?? ""
        let saved = UserDefaults.standard.integer(forKey: Self.countDefaultsKey)
        questionsPerQuiz = saved > 0 ? saved : 8
        preferOnDeviceSpeech = UserDefaults.standard.object(forKey: Self.onDeviceDefaultsKey) as? Bool ?? true
        hideLearnedInPip = UserDefaults.standard.object(forKey: Self.hideLearnedDefaultsKey) as? Bool ?? true
        hideLearnedInTranslate = UserDefaults.standard.bool(forKey: Self.hideTranslateDefaultsKey)
        appearance = UserDefaults.standard.string(forKey: Self.appearanceDefaultsKey)
            .flatMap(AppearanceMode.init(rawValue:)) ?? .system
    }
}
