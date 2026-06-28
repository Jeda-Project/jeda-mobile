//
//  AIService+Environment.swift
//  Jeda
//

import SwiftUI

private struct AICompletingKey: EnvironmentKey {
    static let defaultValue: (any AICompleting)? = MockAICompletingService()
}

extension EnvironmentValues {
    var aiService: (any AICompleting)? {
        get { self[AICompletingKey.self] }
        set { self[AICompletingKey.self] = newValue }
    }
}

private struct ReflectionAIConsentStoreKey: EnvironmentKey {
    static let defaultValue: any ReflectionAIConsentPersisting = ReflectionAIConsentStore()
}

extension EnvironmentValues {
    var reflectionAIConsentStore: any ReflectionAIConsentPersisting {
        get { self[ReflectionAIConsentStoreKey.self] }
        set { self[ReflectionAIConsentStoreKey.self] = newValue }
    }
}
