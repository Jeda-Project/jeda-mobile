/**
 * Scope: ReflectionAIConsentStatus.swift
 * Purpose: Tracks whether the user has agreed to send reflection text to a cloud AI service.
 */

import Foundation

enum ReflectionAIConsentStatus: String, Sendable {
    case notDetermined
    case granted
    case denied
}
