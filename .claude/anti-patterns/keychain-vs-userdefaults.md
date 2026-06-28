# Anti-Pattern: Keychain vs UserDefaults

## The Trap

Storing sensitive data (tokens, API keys, credentials) in `UserDefaults` because it's simpler than Keychain.

## Why It Happens

`UserDefaults` has a one-line API. Keychain requires more boilerplate. Under deadline pressure, developers choose the path of least resistance.

## Wrong Pattern

```swift
// ❌ UserDefaults — plaintext, unencrypted, accessible to any process
UserDefaults.standard.set(bearerToken, forKey: "api_bearer_token")
UserDefaults.standard.set(userPassword, forKey: "user_password")

// Reading back
let token = UserDefaults.standard.string(forKey: "api_bearer_token")
```

## Right Pattern

```swift
// ✅ Keychain — encrypted at rest, protected by device passcode / Secure Enclave
import Security

func saveToKeychain(key: String, value: String) throws {
    let data = Data(value.utf8)
    let query: [CFString: Any] = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: key,
        kSecValueData: data,
        kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ]
    SecItemDelete(query as CFDictionary)
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else { throw KeychainError.saveFailed(status) }
}
```

## Decision Table

| Data Type | Storage |
|---|---|
| Bearer token / API key | ✅ Keychain |
| User password / passphrase | ✅ Keychain |
| Firebase custom auth token | ✅ Keychain |
| User display name | ✅ UserDefaults |
| App theme preference | ✅ UserDefaults |
| Last-selected tab | ✅ UserDefaults |
| Journal entries | ✅ Core Data / local DB |
| Onboarding completed flag | ✅ UserDefaults |

## Rule

AGENTS.md §Larangan Keras: jangan simpan secrets di `UserDefaults` — gunakan Keychain. `env-guard.sh` akan memperingatkan jika `UserDefaults.set` dipanggil dengan key yang mengandung `token`, `key`, `secret`, atau `password`.

## Impact

- `UserDefaults` data is stored as plaintext plist in the app's sandbox — readable by anyone with device access or an unencrypted backup.
- Keychain data is AES-256 encrypted and bound to the device's Secure Enclave when `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` is set.
- App Store Review and security audits flag UserDefaults for credential storage.
