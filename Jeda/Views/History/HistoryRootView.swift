//
//  HistoryRootView.swift
//  Jeda
//

import SwiftUI

struct HistoryRootView: View {
    @Environment(\.reflectionStore) private var reflectionStore

    private var weeks: [WeekSummary] {
        HistoryWeekCatalog.weeks(from: reflectionStore.entries)
    }

    var body: some View {
        NavigationStack {
            HistoryOverviewView(weeks: weeks)
                .refreshable { await reflectionStore.refreshFromBackend() }
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
        case .weeklySummary(let weekID):
            if let week = resolveWeek(id: weekID) {
                WeeklySummaryView(week: week)
            }

        case .weeklyStory(let weekID):
            if let week = resolveWeek(id: weekID) {
                WeeklyStoryView(week: week)
            }

        case .dailyEntries(let weekID):
            if let week = resolveWeek(id: weekID) {
                WeeklyDailyEntriesView(week: week)
            }

        case .entryDetail(let entryID, let weekID):
            if
                let week = resolveWeek(id: weekID),
                let entry = week.entries.first(where: { $0.id == entryID })
            {
                HistoryEntryDetailView(
                    entry: entry,
                    relatedEntries: week.entries.filter { $0.id != entry.id }.prefix(3).map { $0 }
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
        .environment(\.reflectionStore, ReflectionStore())
}
