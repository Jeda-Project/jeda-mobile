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

extension EnvironmentValues {
    var emotionService: any EmotionAnalyzing {
        get { self[EmotionAnalyzingKey.self] }
        set { self[EmotionAnalyzingKey.self] = newValue }
    }

    var onboardingProgressStore: any OnboardingProgressStoring {
        get { self[OnboardingProgressStoreKey.self] }
        set { self[OnboardingProgressStoreKey.self] = newValue }
    }
}
