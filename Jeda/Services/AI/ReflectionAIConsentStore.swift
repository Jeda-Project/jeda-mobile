/**
 * Scope: ReflectionAIConsentStore.swift
 * Purpose: Persists the user's consent decision for sending reflection text to a cloud AI service.
 */

import Foundation

protocol ReflectionAIConsentPersisting: Sendable {
    func status() -> ReflectionAIConsentStatus
    func setStatus(_ status: ReflectionAIConsentStatus)
}

final class ReflectionAIConsentStore: ReflectionAIConsentPersisting, @unchecked Sendable {
    private enum Key {
        static let consentStatus = "reflectionAIConsentStatus"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func status() -> ReflectionAIConsentStatus {
        guard let rawValue = defaults.string(forKey: Key.consentStatus),
              let status = ReflectionAIConsentStatus(rawValue: rawValue)
        else {
            return .notDetermined
        }
        return status
    }

    func setStatus(_ status: ReflectionAIConsentStatus) {
        defaults.set(status.rawValue, forKey: Key.consentStatus)
    }
}
