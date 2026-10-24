import Foundation
import Security

/// The DeepSeek key lives in the keychain, never in UserDefaults and never in
/// the repo. A CLI run can also read `DEEPSEEK_API_KEY`, which is how the
/// headless self-test works without touching the keychain.
enum Keychain {
    private static let service = "com.hayden.DeutschBegleiter"
    private static let account = "deepseek-api-key"

    static func save(_ value: String) {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)

        guard !value.isEmpty else { return }
        query[kSecValueData as String] = Data(value.utf8)
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        SecItemAdd(query as CFDictionary, nil)
    }

    static func load() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard
            SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
            let data = item as? Data,
            let value = String(data: data, encoding: .utf8),
            !value.isEmpty
        else { return nil }
        return value
    }

    static func delete() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }

    /// Keychain first, then the environment (for CLI runs).
    static var apiKey: String? {
        load() ?? ProcessInfo.processInfo.environment["DEEPSEEK_API_KEY"]
    }
}
