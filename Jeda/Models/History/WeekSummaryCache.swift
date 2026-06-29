/**
 * Scope: WeekSummaryCache.swift
 * Purpose: UserDefaults-backed cache for weekly AI summary content with session and persistent policies.
 */

import Foundation

enum WeeklyAIEnrichmentStatus: Equatable {
    case unavailable, cached, sessionCached, generated, failed
}

struct WeeklySummaryLoadResult {
    let week: WeekSummary
    let aiStatus: WeeklyAIEnrichmentStatus
    let entryContentHash: String
    let errorMessage: String?
}

extension WeeklySummaryLoadResult {
    static func make(
        week: WeekSummary, status: WeeklyAIEnrichmentStatus, hash: String, error: String? = nil
    ) -> WeeklySummaryLoadResult {
        WeeklySummaryLoadResult(week: week, aiStatus: status, entryContentHash: hash, errorMessage: error)
    }
}

enum WeekSummaryCachePolicy {
    case persistent
    case sessionOnly
}

enum WeekSummaryCache {
    private static let prefix = "jeda.weekSummary.ai."

    static func policy(for week: WeekSummary) -> WeekSummaryCachePolicy {
        week.isCurrentWeek ? .sessionOnly : .persistent
    }

    static func load(
        weekID: UUID,
        policy: WeekSummaryCachePolicy,
        entryHash: String
    ) -> WeeklySummaryAIContent? {
        switch policy {
        case .sessionOnly:
            return nil
        case .persistent:
            let key = persistentCacheKey(weekID: weekID)
            guard
                let data = UserDefaults.standard.data(forKey: key),
                let content = try? JSONDecoder().decode(WeeklySummaryAIContent.self, from: data)
            else {
                return nil
            }
            return content
        }
    }

    static func save(
        weekID: UUID,
        policy: WeekSummaryCachePolicy,
        entryHash: String,
        content: WeeklySummaryAIContent
    ) {
        guard policy == .persistent else { return }
        let key = persistentCacheKey(weekID: weekID)
        guard let data = try? JSONEncoder().encode(content) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func saveSummaryPhrase(
        weekID: UUID,
        entryHash: String,
        phrase: String,
        moodLabel: String,
        policy: WeekSummaryCachePolicy
    ) {
        guard policy == .persistent else { return }
        UserDefaults.standard.set(phrase, forKey: "\(prefix)phrase.\(weekID.uuidString)")
        UserDefaults.standard.set(moodLabel, forKey: "\(prefix)moodLabel.\(weekID.uuidString)")
    }

    static func cachedSummaryPhrase(
        weekID: UUID,
        entryHash: String?,
        policy: WeekSummaryCachePolicy
    ) -> (phrase: String, moodLabel: String)? {
        guard policy == .persistent else { return nil }
        guard
            let phrase = UserDefaults.standard.string(forKey: "\(prefix)phrase.\(weekID.uuidString)"),
            let moodLabel = UserDefaults.standard.string(forKey: "\(prefix)moodLabel.\(weekID.uuidString)")
        else {
            return nil
        }
        return (phrase, moodLabel)
    }

    private static func persistentCacheKey(weekID: UUID) -> String {
        "\(prefix)\(weekID.uuidString)"
    }
}
