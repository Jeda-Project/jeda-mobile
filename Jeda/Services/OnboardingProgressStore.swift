/**
 * Scope: OnboardingProgressStore.swift
 * Purpose: Persists and exposes onboarding completion state using UserDefaults.
 */

import Foundation

protocol OnboardingProgressStoring {
    var hasCompletedOnboarding: Bool { get }
    func markOnboardingCompleted()
}

final class UserDefaultsOnboardingProgressStore: OnboardingProgressStoring {
    private enum Key {
        static let hasCompletedOnboarding = "jeda.hasCompletedOnboarding"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var hasCompletedOnboarding: Bool {
        userDefaults.bool(forKey: Key.hasCompletedOnboarding)
    }

    func markOnboardingCompleted() {
        userDefaults.set(true, forKey: Key.hasCompletedOnboarding)
    }
}
