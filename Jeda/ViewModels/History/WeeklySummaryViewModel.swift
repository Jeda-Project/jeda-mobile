/**
 * Scope: WeeklySummaryViewModel.swift
 * Purpose: Manages loading state and enriched week data for WeeklySummaryView.
 */

import Foundation
import Observation

@Observable
@MainActor
final class WeeklySummaryViewModel {
    private(set) var week: WeekSummary
    private(set) var loadState: WeekSummaryLoadState = .idle
    private(set) var aiErrorMessage: String?

    private let template: WeekSummary
    private var lastLoadedEntryHash: String?

    init(week: WeekSummary) {
        self.week = week
        template = week
    }

    func loadIfNeeded(
        reflectionStore: ReflectionStore,
        aiService: (any AICompleting)?,
        summaryRepository: (any SummaryRepositing)? = nil
    ) async {
        await load(
            reflectionStore: reflectionStore,
            aiService: aiService,
            summaryRepository: summaryRepository,
            forceRefresh: false
        )
    }

    func reloadIfStale(
        reflectionStore: ReflectionStore,
        aiService: (any AICompleting)?,
        summaryRepository: (any SummaryRepositing)? = nil
    ) async {
        await load(
            reflectionStore: reflectionStore,
            aiService: aiService,
            summaryRepository: summaryRepository,
            forceRefresh: false
        )
    }

    func retry(
        reflectionStore: ReflectionStore,
        aiService: (any AICompleting)?,
        summaryRepository: (any SummaryRepositing)? = nil
    ) async {
        lastLoadedEntryHash = nil
        loadState = .idle
        await load(
            reflectionStore: reflectionStore,
            aiService: aiService,
            summaryRepository: summaryRepository,
            forceRefresh: true
        )
    }

    private func load(
        reflectionStore: ReflectionStore,
        aiService: (any AICompleting)?,
        summaryRepository: (any SummaryRepositing)?,
        forceRefresh: Bool
    ) async {
        let currentHash = WeeklySummaryLoader.currentEntryHash(
            template: template,
            reflectionStore: reflectionStore
        )
        if !forceRefresh, currentHash == lastLoadedEntryHash, loadState == .loaded { return }
        loadState = .loading
        aiErrorMessage = nil
        let result = await WeeklySummaryLoader.loadEnrichedWeek(
            template: template,
            reflectionStore: reflectionStore,
            aiService: aiService,
            repository: summaryRepository,
            forceRefresh: forceRefresh
        )
        week = result.week
        lastLoadedEntryHash = result.entryContentHash
        EnrichedWeekRegistry.store(result.week, entryHash: result.entryContentHash)
        switch result.aiStatus {
        case .unavailable, .cached, .sessionCached:
            loadState = .loaded
            aiErrorMessage = nil
        case .generated:
            loadState = .loaded
            aiErrorMessage = nil
            if let repository = summaryRepository {
                Task {
                    do { try await repository.pushWeeklySummary(result.week) } catch {
                        print("[Jeda Backend] Weekly summary push gagal: \(error.localizedDescription)")
                    }
                }
            }
        case .failed:
            loadState = .failed
            aiErrorMessage = result.errorMessage
        }
    }

    var isLoadingAI: Bool {
        loadState == .loading
    }

    var aiLoadFailed: Bool {
        loadState == .failed
    }
}
