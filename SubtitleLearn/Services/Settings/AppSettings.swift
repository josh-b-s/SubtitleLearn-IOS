import Foundation
import Observation

/// Small UserDefaults-backed settings store. The Gemini key lives in the Keychain.
@MainActor
@Observable
final class AppSettings {
    static let shared = AppSettings()

    var geminiAPIKey: String {
        didSet { KeychainStore.write(geminiAPIKey, for: Self.keyDefaultsKey) }
    }
    var questionsPerQuiz: Int {
        didSet { UserDefaults.standard.set(questionsPerQuiz, forKey: Self.countDefaultsKey) }
    }

    var preferOnDeviceSpeech: Bool {
        didSet { UserDefaults.standard.set(preferOnDeviceSpeech, forKey: Self.onDeviceDefaultsKey) }
    }

    var speakSlowly: Bool {
        didSet { UserDefaults.standard.set(speakSlowly, forKey: Self.speakSlowlyDefaultsKey) }
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

    var vocabularySort: VocabularySort {
        didSet { UserDefaults.standard.set(vocabularySort.rawValue, forKey: Self.vocabularySortDefaultsKey) }
    }

    private static let appearanceDefaultsKey = "appearance"
    private static let vocabularySortDefaultsKey = "vocabularySort"
    private static let hideLearnedDefaultsKey = "hideLearnedInPip"
    private static let hideTranslateDefaultsKey = "hideLearnedInTranslate"
    private static let onDeviceDefaultsKey = "preferOnDeviceSpeech"
    private static let speakSlowlyDefaultsKey = "speakSlowly"
    private static let keyDefaultsKey = "geminiAPIKey"
    private static let countDefaultsKey = "questionsPerQuiz"

    private init() {
        // Older builds kept the key in UserDefaults. Move it once.
        if let legacy = UserDefaults.standard.string(forKey: Self.keyDefaultsKey) {
            KeychainStore.write(legacy, for: Self.keyDefaultsKey)
            UserDefaults.standard.removeObject(forKey: Self.keyDefaultsKey)
        }
        geminiAPIKey = KeychainStore.read(Self.keyDefaultsKey) ?? ""
        let saved = UserDefaults.standard.integer(forKey: Self.countDefaultsKey)
        questionsPerQuiz = saved > 0 ? saved : 8
        preferOnDeviceSpeech = UserDefaults.standard.object(forKey: Self.onDeviceDefaultsKey) as? Bool ?? true
        speakSlowly = UserDefaults.standard.bool(forKey: Self.speakSlowlyDefaultsKey)
        hideLearnedInPip = UserDefaults.standard.object(forKey: Self.hideLearnedDefaultsKey) as? Bool ?? true
        hideLearnedInTranslate = UserDefaults.standard.bool(forKey: Self.hideTranslateDefaultsKey)
        appearance = UserDefaults.standard.string(forKey: Self.appearanceDefaultsKey)
            .flatMap(AppearanceMode.init(rawValue:)) ?? .system
        vocabularySort = UserDefaults.standard.string(forKey: Self.vocabularySortDefaultsKey)
            .flatMap(VocabularySort.init(rawValue:)) ?? .newest
    }
}
