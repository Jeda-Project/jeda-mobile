//
//  WeeklyDailyEntriesView.swift
//  Jeda
//

import SwiftUI

struct WeeklyDailyEntriesView: View {
    let week: WeekSummary
    @State private var selectedDayIndex = 0

    private var weekDays: [Date] {
        HistoryFormatting.weekDays(for: week)
    }

    private var entriesForSelectedDay: [JournalEntry] {
        guard weekDays.indices.contains(selectedDayIndex) else { return [] }
        let selectedDay = weekDays[selectedDayIndex]
        return week.entries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDay) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JedaSpacing.xl) {
                daySelector

                if entriesForSelectedDay.isEmpty {
                    JedaStateCard(kind: .empty, actionTitle: "Kembali ke ringkasan") {}
                } else {
                    VStack(spacing: JedaSpacing.md) {
                        ForEach(entriesForSelectedDay) { entry in
                            NavigationLink(
                                value: HistoryDestination.entryDetail(entryID: entry.id, weekID: week.id)
                            ) {
                                JedaEntryRowCard(entry: entry)
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
        .navigationTitle("Week \(week.weekNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundStyle(JedaColor.sage)
                    .accessibilityLabel("Filter entry")
            }
        }
        .onAppear {
            selectedDayIndex = defaultDayIndex
        }
    }

    private var defaultDayIndex: Int {
        let todayIndex = weekDays.firstIndex {
            Calendar.current.isDateInToday($0)
        }
        return todayIndex ?? max(weekDays.count - 1, 0)
    }

    private var daySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: JedaSpacing.sm) {
                ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
                    Button {
                        selectedDayIndex = index
                    } label: {
                        VStack(spacing: JedaSpacing.xs) {
                            Text(HistoryFormatting.dayAbbreviation(for: day))
                                .font(JedaTypography.caption)
                            Text(HistoryFormatting.dayNumber(for: day))
                                .font(JedaTypography.headline)
                        }
                        .foregroundStyle(
                            selectedDayIndex == index ? JedaColor.textPrimary : JedaColor.textSecondary
                        )
                        .frame(minWidth: 52, minHeight: 44)
                        .padding(.horizontal, JedaSpacing.sm)
                        .background {
                            RoundedRectangle(cornerRadius: JedaRadius.chip, style: .continuous)
                                .fill(
                                    selectedDayIndex == index
                                    ? JedaColor.sage.opacity(0.16)
                                    : Color.clear
                                )
                        }
                        .jedaGlassEffect(
                            tint: selectedDayIndex == index
                                ? JedaColor.sage.opacity(0.18)
                                : JedaColor.sage.opacity(0.06),
                            isInteractive: true,
                            in: RoundedRectangle(cornerRadius: JedaRadius.chip, style: .continuous)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Hari \(HistoryFormatting.dayAbbreviation(for: day)) \(HistoryFormatting.dayNumber(for: day))")
                    .accessibilityAddTraits(selectedDayIndex == index ? .isSelected : [])
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        WeeklyDailyEntriesView(week: HistorySampleData.currentWeek)
    }
}
