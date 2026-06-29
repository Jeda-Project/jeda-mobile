/**
 * Scope: HistoryRootView.swift
 * Purpose: Root container view for the History tab that manages navigation within the history feature.
 */

import SwiftUI

struct HistoryRootView: View {
    @EnvironmentObject private var reflectionStore: ReflectionStore
    @State private var hasSynced = false

    private var weeks: [WeekSummary] {
        HistoryWeekCatalog.weeks(from: reflectionStore.entries)
    }

    private static let historyFetchLimit = 50

    var body: some View {
        NavigationStack {
            Group {
                if !hasSynced {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background { JedaScreenBackground() }
                } else {
                    HistoryOverviewView(weeks: weeks)
                        .refreshable { await reflectionStore.fetchAllForHistory(limit: Self.historyFetchLimit) }
                }
            }
            .task {
                await reflectionStore.fetchAllForHistory(limit: Self.historyFetchLimit)
                hasSynced = true
            }
            .navigationDestination(for: HistoryDestination.self) { destination in
                historyDetailView(for: destination)
                    .jedaHideTabBar()
            }
        }
        .tint(JedaColor.sage)
    }

    @ViewBuilder
    private func historyDetailView(for destination: HistoryDestination) -> some View {
        switch destination {
        case let .weeklySummary(weekID):
            if let week = resolveWeek(id: weekID) {
                WeeklySummaryView(week: week)
            }

        case let .weeklyStory(weekID):
            if let week = resolveWeek(id: weekID) {
                WeeklyStoryView(week: week)
            }

        case let .dailyEntries(weekID):
            if let week = resolveWeek(id: weekID) {
                WeeklyDailyEntriesView(week: week)
            }

        case let .entryDetail(entryID, weekID):
            if let week = resolveWeek(id: weekID),
               let entry = week.entries.first(where: { $0.id == entryID }) {
                HistoryEntryDetailView(
                    entry: entry,
                    relatedEntries: Array(week.entries.filter { $0.id != entry.id }.prefix(3))
                )
            }
        }
    }

    private func resolveWeek(id: UUID) -> WeekSummary? {
        EnrichedWeekRegistry.week(id: id)
            ?? HistoryWeekCatalog.week(withID: id, from: reflectionStore.entries)
    }
}

#Preview {
    HistoryRootView()
        .environmentObject(ReflectionStore())
}
