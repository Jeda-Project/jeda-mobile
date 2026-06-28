//
//  HistoryRootView.swift
//  Jeda
//

import SwiftUI

struct HistoryRootView: View {
    let weeks: [WeekSummary]

    var body: some View {
        NavigationStack {
            HistoryOverviewView(weeks: weeks)
                .navigationDestination(for: HistoryDestination.self) { destination in
                    switch destination {
                    case .weeklySummary(let weekID):
                        if let week = HistorySampleData.week(withID: weekID) {
                            WeeklySummaryView(week: week)
                        }

                    case .weeklyStory(let weekID):
                        if let week = HistorySampleData.week(withID: weekID) {
                            WeeklyStoryView(week: week)
                        }

                    case .dailyEntries(let weekID):
                        if let week = HistorySampleData.week(withID: weekID) {
                            WeeklyDailyEntriesView(week: week)
                        }

                    case .entryDetail(let entryID, let weekID):
                        if
                            let week = HistorySampleData.week(withID: weekID),
                            let entry = HistorySampleData.entry(withID: entryID, in: week)
                        {
                            HistoryEntryDetailView(
                                entry: entry,
                                relatedEntries: week.entries.filter { $0.id != entry.id }.prefix(3).map { $0 }
                            )
                        }
                    }
                }
        }
        .tint(JedaColor.sage)
    }
}

#Preview {
    HistoryRootView(weeks: HistorySampleData.weeks)
}
