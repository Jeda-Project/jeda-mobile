/**
 * Scope: JedaAIReflectionLog.swift
 * Purpose: Centralized console logging for AI reflection and weekly summary operations.
 */

import Foundation

enum JedaAIReflectionLog {
    static func weeklySummaryFailed(_ error: Error, weekNumber: Int, entryCount: Int) {
        let detail = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        print("[Jeda AI Reflection] Weekly summary gagal — Week \(weekNumber), \(entryCount) entry(s)")
        print("[Jeda AI Reflection] Error: \(detail)")
        print("[Jeda AI Reflection] Raw: \(error)")
    }

    static func weeklySummarySkipped(_ reason: String, weekNumber: Int, entryCount: Int) {
        print("[Jeda AI Reflection] Weekly summary dilewati — Week \(weekNumber), \(entryCount) entry(s): \(reason)")
    }

    static func reflectionReplyFailed(_ error: Error) {
        let detail = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        print("[Jeda AI Reflection] Balasan refleksi gagal: \(detail)")
        print("[Jeda AI Reflection] Raw: \(error)")
    }
}
