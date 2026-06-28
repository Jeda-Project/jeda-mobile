//
//  JedaApp.swift
//  Jeda
//
//  Created by Muhamad Fardan Wardhana on 27/06/26.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct JedaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var reflectionStore: ReflectionStore

    // TODO: Remove this QA flag after onboarding review; set false to respect saved first-run state.
    private static let alwaysShowOnboardingForReview = false

    private let onboardingProgressStore = UserDefaultsOnboardingProgressStore()
    private let aiService: (any AICompleting)? = try? AIService.makeDefault()
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
                hasCompletedOnboarding: Self.alwaysShowOnboardingForReview
                ? false
                : onboardingProgressStore.hasCompletedOnboarding
            )
                .environment(\.onboardingProgressStore, onboardingProgressStore)
                .environment(\.reflectionStore, reflectionStore)
                .environment(\.aiService, aiService)
                .environment(\.entryRepository, backend?.entryRepository)
                .environment(\.summaryRepository, backend?.summaryRepository)
                .environment(\.safetyService, backend?.safetyService)
        }
    }
}
