//
//  JedaEnvironment.swift
//  Jeda
//
//  Created by Codex on 28/06/26.
//

import SwiftUI

private struct EmotionAnalyzingKey: EnvironmentKey {
    static let defaultValue: any EmotionAnalyzing = EmotionClassificationService.shared
}

private struct OnboardingProgressStoreKey: EnvironmentKey {
    static let defaultValue: any OnboardingProgressStoring = UserDefaultsOnboardingProgressStore()
}

private struct ReflectionStoreKey: EnvironmentKey {
    @MainActor static let defaultValue = ReflectionStore()
}

private struct CrisisDetectingKey: EnvironmentKey {
    static let defaultValue: any CrisisDetecting = CrisisDetectionService()
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

    var reflectionStore: ReflectionStore {
        get { self[ReflectionStoreKey.self] }
        set { self[ReflectionStoreKey.self] = newValue }
    }

    var crisisDetector: any CrisisDetecting {
        get { self[CrisisDetectingKey.self] }
        set { self[CrisisDetectingKey.self] = newValue }
    }
}
