import Foundation

/// Keeps Gemini sentences on device so each word costs one request, and level 3 works offline after.
enum ClozeCache {
    private static let defaultsKey = "clozeSentences"

    static func all() -> [String: [ClozeSentence]] {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let decoded = try? JSONDecoder().decode([String: [ClozeSentence]].self, from: data)
        else { return [:] }
        return decoded
    }

    static func store(_ sentences: [ClozeSentence]) {
        var current = all()
        for s in sentences where !(current[s.word]?.contains(s) ?? false) {
            current[s.word, default: []].append(s)
        }
        if let data = try? JSONEncoder().encode(current) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
}
