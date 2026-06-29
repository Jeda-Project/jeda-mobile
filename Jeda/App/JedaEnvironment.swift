/**
 * Scope: JedaEnvironment.swift
 * Purpose: Defines SwiftUI environment keys and values for app-wide dependency injection.
 */

import SwiftUI

private struct EmotionAnalyzingKey: EnvironmentKey {
    static let defaultValue: any EmotionAnalyzing = EmotionClassificationService.shared
}

private struct OnboardingProgressStoreKey: EnvironmentKey {
    static let defaultValue: any OnboardingProgressStoring = UserDefaultsOnboardingProgressStore()
}

private struct CrisisDetectingKey: EnvironmentKey {
    static let defaultValue: any CrisisDetecting = CrisisDetectionService()
}

private struct EntryRepositingKey: EnvironmentKey {
    static let defaultValue: (any EntryRepositing)? = nil
}

private struct SummaryRepositingKey: EnvironmentKey {
    static let defaultValue: (any SummaryRepositing)? = nil
}

private struct SafetyScanningKey: EnvironmentKey {
    static let defaultValue: (any SafetyScanning)? = nil
}

extension EnvironmentValues {
    var emotionService: any EmotionAnalyzing {
        get { self[EmotionAnalyzingKey.self] }
        set { self[EmotionAnalyzingKey.self] = newValue }
    }

    var onboardingProgressStore: any OnboardingProgressStoring {
        get { self[OnboardingProgressStoreKey.self] }
        set { self[OnboardingProgressStoreKey.self] = newValue }
    }

    var crisisDetector: any CrisisDetecting {
        get { self[CrisisDetectingKey.self] }
        set { self[CrisisDetectingKey.self] = newValue }
    }

    var entryRepository: (any EntryRepositing)? {
        get { self[EntryRepositingKey.self] }
        set { self[EntryRepositingKey.self] = newValue }
    }

    var summaryRepository: (any SummaryRepositing)? {
        get { self[SummaryRepositingKey.self] }
        set { self[SummaryRepositingKey.self] = newValue }
    }

    var safetyService: (any SafetyScanning)? {
        get { self[SafetyScanningKey.self] }
        set { self[SafetyScanningKey.self] = newValue }
    }
}
