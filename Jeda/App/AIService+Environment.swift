/**
 * Scope: AIService+Environment.swift
 * Purpose: SwiftUI environment key registration for injecting AIService into the view hierarchy.
 */

import SwiftUI

private struct AICompletingKey: EnvironmentKey {
    #if DEBUG
    static let defaultValue: (any AICompleting)? = MockAICompletingService()
    #else
    static let defaultValue: (any AICompleting)? = nil
    #endif
}

private struct AICompletingFastKey: EnvironmentKey {
    #if DEBUG
    static let defaultValue: (any AICompleting)? = MockAICompletingService()
    #else
    static let defaultValue: (any AICompleting)? = nil
    #endif
}

extension EnvironmentValues {
    var aiService: (any AICompleting)? {
        get { self[AICompletingKey.self] }
        set { self[AICompletingKey.self] = newValue }
    }

    var aiServiceFast: (any AICompleting)? {
        get { self[AICompletingFastKey.self] }
        set { self[AICompletingFastKey.self] = newValue }
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
