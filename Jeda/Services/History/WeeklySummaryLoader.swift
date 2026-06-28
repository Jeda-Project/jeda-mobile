/**
 * Scope: WeeklySummaryLoader.swift
 * Purpose: Loads enriched WeekSummary with OpenAI narrative and local cache.
 */

import Foundation

enum WeeklyAIEnrichmentStatus: Sendable, Equatable {
    case unavailable
    case cached
    case sessionCached
    case generated
    case failed
}

struct WeeklySummaryLoadResult: Sendable {
    let week: WeekSummary
    let aiStatus: WeeklyAIEnrichmentStatus
    let entryContentHash: String
    let errorMessage: String?
}

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

enum WeeklySummaryLoader {
    static func currentEntryHash(
        template: WeekSummary,
        reflectionStore: ReflectionStore
    ) async -> String {
        buildSnapshot(template: template, reflectionStore: reflectionStore).entryContentHash
    }

    static func loadEnrichedWeek(
        template: WeekSummary,
        reflectionStore: ReflectionStore,
        aiService: (any AICompleting)?,
        forceRefresh: Bool = false
    ) async -> WeeklySummaryLoadResult {
        let reflections = WeekSummaryBuilder.reflections(in: template, from: reflectionStore)
        var baseline = WeekSummaryBuilder.buildBaseline(
            template: template,
            reflectionEntries: reflections
        )

        let snapshot = WeekSummaryBuilder.makeSnapshot(
            template: template,
            journalEntries: baseline.entries
        )

        let policy = WeekSummaryCache.policy(for: template)
        let entryHash = snapshot.entryContentHash

        if !forceRefresh, policy == .sessionOnly {
            if let sessionWeek = await EnrichedWeekRegistry.enrichedWeek(id: snapshot.weekID, entryHash: entryHash) {
                return WeeklySummaryLoadResult(
                    week: sessionWeek,
                    aiStatus: .sessionCached,
                    entryContentHash: entryHash,
                    errorMessage: nil
                )
            }
        }

        if !forceRefresh,
           policy == .persistent,
           let cached = WeekSummaryCache.load(
               weekID: snapshot.weekID,
               policy: .persistent,
               entryHash: entryHash
           ) {
            baseline = baseline.merging(aiContent: cached, entries: snapshot.journalEntries)
            WeekSummaryCache.saveSummaryPhrase(
                weekID: snapshot.weekID,
                entryHash: entryHash,
                phrase: cached.summaryPhrase,
                moodLabel: cached.moodLabel,
                policy: .persistent
            )
            await EnrichedWeekRegistry.store(baseline, entryHash: entryHash)
            return WeeklySummaryLoadResult(
                week: baseline,
                aiStatus: .cached,
                entryContentHash: entryHash,
                errorMessage: nil
            )
        }

        guard let aiService else {
            JedaAIReflectionLog.weeklySummarySkipped(
                "AIService nil — cek Secrets.plist / OPENAI_API_KEY",
                weekNumber: snapshot.weekNumber,
                entryCount: snapshot.checkInCount
            )
            return WeeklySummaryLoadResult(
                week: baseline,
                aiStatus: .unavailable,
                entryContentHash: entryHash,
                errorMessage: "Layanan AI belum tersedia. Periksa OPENAI_API_KEY di Secrets.plist."
            )
        }

        guard !snapshot.entries.isEmpty else {
            JedaAIReflectionLog.weeklySummarySkipped(
                "Belum ada check-in minggu ini",
                weekNumber: snapshot.weekNumber,
                entryCount: 0
            )
            return WeeklySummaryLoadResult(
                week: baseline,
                aiStatus: .unavailable,
                entryContentHash: entryHash,
                errorMessage: "Belum ada check-in minggu ini. Simpan minimal satu entry di tab Check-in."
            )
        }

        do {
            let aiContent = try await aiService.generateWeeklySummary(from: snapshot)

            if policy == .persistent {
                WeekSummaryCache.save(
                    weekID: snapshot.weekID,
                    policy: .persistent,
                    entryHash: entryHash,
                    content: aiContent
                )
            }

            WeekSummaryCache.saveSummaryPhrase(
                weekID: snapshot.weekID,
                entryHash: entryHash,
                phrase: aiContent.summaryPhrase,
                moodLabel: aiContent.moodLabel,
                policy: policy
            )

            let enriched = baseline.merging(aiContent: aiContent, entries: snapshot.journalEntries)
            await EnrichedWeekRegistry.store(enriched, entryHash: entryHash)
            return WeeklySummaryLoadResult(
                week: enriched,
                aiStatus: .generated,
                entryContentHash: entryHash,
                errorMessage: nil
            )
        } catch {
            JedaAIReflectionLog.weeklySummaryFailed(
                error,
                weekNumber: snapshot.weekNumber,
                entryCount: snapshot.checkInCount
            )
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            return WeeklySummaryLoadResult(
                week: baseline,
                aiStatus: .failed,
                entryContentHash: entryHash,
                errorMessage: message
            )
        }
    }

    private static func buildSnapshot(
        template: WeekSummary,
        reflectionStore: ReflectionStore
    ) -> WeekSnapshot {
        let reflections = WeekSummaryBuilder.reflections(in: template, from: reflectionStore)
        let baseline = WeekSummaryBuilder.buildBaseline(
            template: template,
            reflectionEntries: reflections
        )
        return WeekSummaryBuilder.makeSnapshot(
            template: template,
            journalEntries: baseline.entries
        )
    }
}
