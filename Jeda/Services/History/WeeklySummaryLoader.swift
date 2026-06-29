/**
 * Scope: WeeklySummaryLoader.swift
 * Purpose: Loads enriched WeekSummary with OpenAI narrative and local cache.
 */
import Foundation

enum WeeklySummaryLoader {
    static func currentEntryHash(template: WeekSummary, reflectionStore: ReflectionStore) -> String {
        buildSnapshot(template: template, reflectionStore: reflectionStore).entryContentHash
    }

    static func loadEnrichedWeek(
        template: WeekSummary,
        reflectionStore: ReflectionStore,
        aiService: (any AICompleting)?,
        repository: (any SummaryRepositing)? = nil,
        forceRefresh: Bool = false
    ) async -> WeeklySummaryLoadResult {
        let reflections = WeekSummaryBuilder.reflections(in: template, from: reflectionStore)
        let baseline = WeekSummaryBuilder.buildBaseline(template: template, reflectionEntries: reflections)
        let snapshot = WeekSummaryBuilder.makeSnapshot(template: template, journalEntries: baseline.entries)
        let policy = WeekSummaryCache.policy(for: template)
        if let cached = await checkCachedResult(
            snapshot: snapshot,
            baseline: baseline,
            policy: policy,
            forceRefresh: forceRefresh,
            repository: repository
        ) { return cached }
        return await generateOrFallback(
            aiService: aiService,
            snapshot: snapshot,
            baseline: baseline,
            entryHash: snapshot.entryContentHash,
            policy: policy
        )
    }

    private static func savePhrase(
        weekID: UUID, hash: String, content: WeeklySummaryAIContent, policy: WeekSummaryCachePolicy
    ) {
        WeekSummaryCache.saveSummaryPhrase(
            weekID: weekID,
            entryHash: hash,
            phrase: content.summaryPhrase,
            moodLabel: content.moodLabel,
            policy: policy
        )
    }

    private static func buildSnapshot(template: WeekSummary, reflectionStore: ReflectionStore) -> WeekSnapshot {
        let reflections = WeekSummaryBuilder.reflections(in: template, from: reflectionStore)
        let baseline = WeekSummaryBuilder.buildBaseline(template: template, reflectionEntries: reflections)
        return WeekSummaryBuilder.makeSnapshot(template: template, journalEntries: baseline.entries)
    }

    private static func fetchFromBackend(
        weekID: UUID, repository: any SummaryRepositing
    ) async -> WeeklySummaryAIContent? {
        guard let summaries = try? await repository.fetchSummaries(limit: 20),
              let match = summaries.first(where: { UUID(uuidString: $0.id) == weekID }) else { return nil }
        return WeeklySummaryAIContent(
            moodLabel: "",
            summaryPhrase: match.reliefNote ?? "",
            aiReflectionSummary: "",
            aiReflectionLong: "",
            storyPages: [],
            improvements: [],
            quoteOfWeek: match.reliefNote,
            memorableMomentIndices: []
        )
    }

    private static func generateOrFallback(
        aiService: (any AICompleting)?,
        snapshot: WeekSnapshot,
        baseline: WeekSummary,
        entryHash: String,
        policy: WeekSummaryCachePolicy
    ) async -> WeeklySummaryLoadResult {
        guard let aiService else {
            JedaAIReflectionLog.weeklySummarySkipped(
                "AIService nil", weekNumber: snapshot.weekNumber, entryCount: snapshot.checkInCount
            )
            return .make(week: baseline, status: .unavailable, hash: entryHash, error: "Layanan AI belum tersedia.")
        }
        guard !snapshot.entries.isEmpty else {
            JedaAIReflectionLog.weeklySummarySkipped(
                "Belum ada kontemplasi", weekNumber: snapshot.weekNumber, entryCount: 0
            )
            return .make(
                week: baseline, status: .unavailable, hash: entryHash, error: "Belum ada kontemplasi minggu ini."
            )
        }
        do {
            let aiContent = try await aiService.generateWeeklySummary(from: snapshot)
            if policy == .persistent {
                WeekSummaryCache.save(
                    weekID: snapshot.weekID, policy: .persistent, entryHash: entryHash, content: aiContent
                )
            }
            savePhrase(weekID: snapshot.weekID, hash: entryHash, content: aiContent, policy: policy)
            let enriched = baseline.merging(aiContent: aiContent, entries: snapshot.journalEntries)
            await MainActor.run { EnrichedWeekRegistry.store(enriched, entryHash: entryHash) }
            return .make(week: enriched, status: .generated, hash: entryHash)
        } catch {
            JedaAIReflectionLog.weeklySummaryFailed(
                error, weekNumber: snapshot.weekNumber, entryCount: snapshot.checkInCount
            )
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            return .make(week: baseline, status: .failed, hash: entryHash, error: message)
        }
    }

    private static func checkCachedResult(
        snapshot: WeekSnapshot,
        baseline: WeekSummary,
        policy: WeekSummaryCachePolicy,
        forceRefresh: Bool,
        repository: (any SummaryRepositing)?
    ) async -> WeeklySummaryLoadResult? {
        let hash = snapshot.entryContentHash
        let sessionHit = !forceRefresh && policy == .sessionOnly
            ? await MainActor.run(body: { EnrichedWeekRegistry.enrichedWeek(id: snapshot.weekID, entryHash: hash) })
            : nil
        if let hit = sessionHit {
            return .make(week: hit, status: .sessionCached, hash: hash)
        }
        if !forceRefresh, policy == .persistent,
           let cached = WeekSummaryCache.load(weekID: snapshot.weekID, policy: .persistent, entryHash: hash) {
            let updated = baseline.merging(aiContent: cached, entries: snapshot.journalEntries)
            savePhrase(weekID: snapshot.weekID, hash: hash, content: cached, policy: .persistent)
            await MainActor.run { EnrichedWeekRegistry.store(updated, entryHash: hash) }
            return .make(week: updated, status: .cached, hash: hash)
        }
        if !forceRefresh, policy == .persistent, let repository,
           let backendContent = await fetchFromBackend(weekID: snapshot.weekID, repository: repository) {
            WeekSummaryCache.save(
                weekID: snapshot.weekID, policy: .persistent, entryHash: hash, content: backendContent
            )
            savePhrase(weekID: snapshot.weekID, hash: hash, content: backendContent, policy: .persistent)
            let enriched = baseline.merging(aiContent: backendContent, entries: snapshot.journalEntries)
            await MainActor.run { EnrichedWeekRegistry.store(enriched, entryHash: hash) }
            return .make(week: enriched, status: .cached, hash: hash)
        }
        return nil
    }
}
