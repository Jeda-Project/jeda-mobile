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
    // TODO: Remove this QA flag after onboarding review; set false to respect saved first-run state.
    private static let alwaysShowOnboardingForReview = true

    private let onboardingProgressStore = UserDefaultsOnboardingProgressStore()
    
    var body: some Scene {
        WindowGroup {
            JedaLaunchGateView(
                hasCompletedOnboarding: Self.alwaysShowOnboardingForReview
                ? false
                : onboardingProgressStore.hasCompletedOnboarding
            )
                .environment(\.onboardingProgressStore, onboardingProgressStore)
        }
    }
}
