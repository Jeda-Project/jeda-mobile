/**
 * Scope: JedaApp.swift
 * Purpose: App entry point that configures Firebase and sets up the root SwiftUI scene.
 */

import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        return true
    }
}

@main
struct JedaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var delegate
    @StateObject private var reflectionStore: ReflectionStore

    private let onboardingProgressStore = UserDefaultsOnboardingProgressStore()
    private let aiService: (any AICompleting)? = try? AIService.makeDefault()
    private let aiServiceFast: (any AICompleting)? = try? AIService.makeForWeeklySummary()
    private let backend: BackendServices?

    init() {
        let backend = BackendServices.make()
        self.backend = backend
        _reflectionStore = StateObject(
            wrappedValue: ReflectionStore(repository: backend?.entryRepository)
        )
    }

    var body: some Scene {
        WindowGroup {
            JedaLaunchGateView(
                hasCompletedOnboarding: onboardingProgressStore.hasCompletedOnboarding
            )
            .environment(\.onboardingProgressStore, onboardingProgressStore)
            .environmentObject(reflectionStore)
            .environment(\.aiService, aiService)
            .environment(\.aiServiceFast, aiServiceFast)
            .environment(\.entryRepository, backend?.entryRepository)
            .environment(\.summaryRepository, backend?.summaryRepository)
            .environment(\.safetyService, backend?.safetyService)
        }
    }
}
