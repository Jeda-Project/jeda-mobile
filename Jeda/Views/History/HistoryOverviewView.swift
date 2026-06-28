//
//  HistoryOverviewView.swift
//  Jeda
//

import SwiftUI

struct HistoryOverviewView: View {
    let weeks: [WeekSummary]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JedaSpacing.xl) {
                if let currentWeek = weeks.first {
                    NavigationLink(value: HistoryDestination.weeklySummary(currentWeek.id)) {
                        JedaThisWeekCard(week: currentWeek)
                    }
                    .buttonStyle(.plain)
                }

                JedaSection("Minggu Sebelumnya") {
                    VStack(spacing: JedaSpacing.md) {
                        ForEach(previousWeeks) { week in
                            NavigationLink(value: HistoryDestination.weeklySummary(week.id)) {
                                JedaWeekRowCard(week: week)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, JedaSpacing.lg)
            .padding(.vertical, JedaSpacing.xl)
        }
        .background { JedaScreenBackground() }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "calendar")
                    .foregroundStyle(JedaColor.sage)
                    .accessibilityLabel("Kalender history")
            }
        }
    }

    private var previousWeeks: [WeekSummary] {
        Array(weeks.dropFirst())
    }
}

#Preview {
    NavigationStack {
        HistoryOverviewView(weeks: HistorySampleData.weeks)
    }
}
