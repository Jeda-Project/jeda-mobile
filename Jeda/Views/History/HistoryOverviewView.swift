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
                headerSection

                if let currentWeek = resolvedWeeks.first {
                    NavigationLink(value: HistoryDestination.weeklySummary(currentWeek.id)) {
                        JedaThisWeekCard(week: currentWeek)
                    }
                    .buttonStyle(.plain)
                }

                if !previousWeeks.isEmpty {
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
            }
            .padding(.horizontal, JedaSpacing.lg)
            .padding(.top, JedaSpacing.xl)
            .padding(.bottom, JedaSpacing.xl + JedaSpacing.floatingTabBarClearance)
        }
        .background { JedaScreenBackground() }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var headerSection: some View {
        HStack {
            Text("History")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color.black)

            Spacer()
        }
    }

    private var resolvedWeeks: [WeekSummary] {
        weeks.map { week in
            EnrichedWeekRegistry.week(id: week.id) ?? week
        }
    }

    private var previousWeeks: [WeekSummary] {
        resolvedWeeks.dropFirst().filter { $0.checkInCount > 0 }
    }
}

#Preview {
    NavigationStack {
        HistoryOverviewView(weeks: HistorySampleData.weeks)
    }
}
