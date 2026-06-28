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
        self.template = week
    }

    func loadIfNeeded(
        reflectionStore: ReflectionStore,
        aiService: (any AICompleting)?
    ) async {
        await load(
            reflectionStore: reflectionStore,
            aiService: aiService,
            forceRefresh: false
        )
    }

    func reloadIfStale(
        reflectionStore: ReflectionStore,
        aiService: (any AICompleting)?
    ) async {
        await load(
            reflectionStore: reflectionStore,
            aiService: aiService,
            forceRefresh: false
        )
    }

    func retry(
        reflectionStore: ReflectionStore,
        aiService: (any AICompleting)?
    ) async {
        lastLoadedEntryHash = nil
        loadState = .idle
        await load(
            reflectionStore: reflectionStore,
            aiService: aiService,
            forceRefresh: true
        )
    }

    private func load(
        reflectionStore: ReflectionStore,
        aiService: (any AICompleting)?,
        forceRefresh: Bool
    ) async {
        let currentHash = await WeeklySummaryLoader.currentEntryHash(
            template: template,
            reflectionStore: reflectionStore
        )

        if !forceRefresh,
           currentHash == lastLoadedEntryHash,
           loadState == .loaded {
            return
        }

        loadState = .loading
        aiErrorMessage = nil

        let result = await WeeklySummaryLoader.loadEnrichedWeek(
            template: template,
            reflectionStore: reflectionStore,
            aiService: aiService,
            forceRefresh: forceRefresh
        )

        week = result.week
        lastLoadedEntryHash = result.entryContentHash
        await EnrichedWeekRegistry.store(result.week, entryHash: result.entryContentHash)

        switch result.aiStatus {
        case .unavailable, .cached, .sessionCached, .generated:
            loadState = .loaded
            aiErrorMessage = nil
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
