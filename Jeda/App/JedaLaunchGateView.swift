//
//  JedaLaunchGateView.swift
//  Jeda
//
//  Created by Codex on 28/06/26.
//

import SwiftUI

struct JedaLaunchGateView: View {
    @Environment(\.onboardingProgressStore) private var onboardingProgressStore
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
