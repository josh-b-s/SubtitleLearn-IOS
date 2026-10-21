import Foundation
import Security

/// Stores one string per key as a generic password item. Used for the Gemini API key.
enum KeychainStore {
    private static let service = "com.SubtitleLearn"

    static func read(_ key: String) -> String? {
        var query = baseQuery(key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// An empty value deletes the item.
    static func write(_ value: String, for key: String) {
        SecItemDelete(baseQuery(key) as CFDictionary)
        guard !value.isEmpty else { return }
        var item = baseQuery(key)
        item[kSecValueData as String] = Data(value.utf8)
        // Stays on this device and is unavailable until the first unlock after a restart.
        item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(item as CFDictionary, nil)
    }

    private static func baseQuery(_ key: String) -> [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service,
         kSecAttrAccount as String: key]
    }
}
