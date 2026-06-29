/**
 * Scope: CrisisDetection.swift
 * Purpose: Pure value types describing a deterministic crisis-detection outcome and the professional help resource shown to the user.
 */

import Foundation

struct CrisisDetectionResult: Equatable {
    let isCrisis: Bool
    let matchedTerms: [String]

    static let none = CrisisDetectionResult(isCrisis: false, matchedTerms: [])
}

struct CrisisSupportResource: Equatable {
    let title: String
    let message: String
    let displayNumber: String
    let dialNumber: String

    static let sejiwa = CrisisSupportResource(
        title: "Kamu tidak sendirian",
        message: "Kalau perasaan ini terasa terlalu berat, ada orang yang siap mendengarkan. "
            + "Hubungi hotline kesehatan jiwa Kemenkes (SEJIWA) — gratis dan rahasia.",
        displayNumber: "119 ext 8",
        dialNumber: "119"
    )
}
