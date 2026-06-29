# Security Guidelines

## Mandatory Security Checks

Before EVERY commit:

- [ ] No hardcoded API keys, tokens, or passwords in Swift files
- [ ] Sensitive data stored in Keychain, not UserDefaults
- [ ] No `http://` URLs in production config — must be `https://`
- [ ] Journal text is NOT sent to a server (on-device ML only)
- [ ] `GoogleService-Info.plist` does not contain production keys in a public repo
- [ ] Error messages do not expose internal details to the user

## Secret Management

- DO NOT hardcode secrets in source code
- USE environment variables or Xcode configuration files (`.xcconfig`)
- Firebase config: `GoogleService-Info.plist` must be in `.gitignore` for production keys
- API tokens: store in Keychain, not in `UserDefaults` or `Info.plist`

## Data Privacy (Critical for Jeda)

Jeda is a mental health app — user data is highly sensitive:

- **On-device only:** Journal text and emotion classification results MUST NOT be sent to a server without explicit user consent
- **Minimal data collection:** Only collect analytics that are truly necessary
- **No PII in analytics:** Do not send names, emails, or journal content as Firebase Analytics parameters
- **Keychain for auth token:** If backend auth is added in the future, tokens must be in Keychain

## Network Security

```swift
// ✅ Always HTTPS
let baseURL = URL(string: "https://api.jeda.app")!

// ❌ HTTP is not allowed
let baseURL = URL(string: "http://api.jeda.app")!
```

App Transport Security (ATS) must be active — do not add `NSAllowsArbitraryLoads` to `Info.plist` without a strong, documented reason.

## Security Response Protocol

If a security issue is found:

1. **STOP** — do not continue with other tasks
2. Fix CRITICAL issues before any other commit
3. Rotate any secrets that may have been exposed
4. Review related files for similar issues
5. Document the fix in the commit message
