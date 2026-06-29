/**
 * Scope: JedaLaunchGateView.swift
 * Purpose: Launch gate view that controls initial navigation based on onboarding state.
 */

import SwiftUI

struct JedaLaunchGateView: View {
    @Environment(\.onboardingProgressStore)
    private var onboardingProgressStore
    @State private var hasCompletedOnboarding: Bool

    init(hasCompletedOnboarding: Bool? = nil) {
        _hasCompletedOnboarding = State(initialValue: hasCompletedOnboarding ?? false)
    }

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                JedaRootTabView()
            } else {
                JedaOnboardingView {
                    onboardingProgressStore.markOnboardingCompleted()
                    withAnimation(.snappy) {
                        hasCompletedOnboarding = true
                    }
                }
            }
        }
    }
}

#Preview("Onboarding") {
    JedaLaunchGateView(hasCompletedOnboarding: false)
}

#Preview("Completed") {
    JedaLaunchGateView(hasCompletedOnboarding: true)
}
