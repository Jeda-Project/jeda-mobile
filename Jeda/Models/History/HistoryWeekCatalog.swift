/**
 * Scope: HistoryWeekCatalog.swift
 * Purpose: Builds week templates from calendar and persisted reflection entries.
 */

import Foundation

enum HistoryWeekCatalog {
    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "id_ID")
        return calendar
    }

    static func weeks(
        from entries: [ReflectionEntry],
        pastWeekCount: Int = 4,
        referenceDate: Date = Date()
    ) -> [WeekSummary] {
        (0...pastWeekCount).compactMap { offset in
            weekTemplate(weeksAgo: offset, referenceDate: referenceDate, allEntries: entries)
        }
    }

    static func week(withID id: UUID, from entries: [ReflectionEntry]) -> WeekSummary? {
        weeks(from: entries).first { $0.id == id }
    }

    private static func weekTemplate(
        weeksAgo: Int,
        referenceDate: Date,
        allEntries: [ReflectionEntry]
    ) -> WeekSummary? {
        guard
            let anchor = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: referenceDate),
            let interval = calendar.dateInterval(of: .weekOfYear, for: anchor)
        else {
            return nil
        }

        let start = interval.start
        guard let end = calendar.date(byAdding: .day, value: 6, to: start) else {
            return nil
        }

        let weekEntries = entries(from: start, to: end, in: allEntries)
        let weekNumber = calendar.component(.weekOfYear, from: start)
        let year = calendar.component(.yearForWeekOfYear, from: start)
        let id = weekID(year: year, weekOfYear: weekNumber)
        let dominant = dominantMood(in: weekEntries) ?? .neutral
        let checkIns = HistoryFormatting.uniqueCheckInDayCount(for: weekEntries.map(\.date))

        return WeekSummary(
            id: id,
            weekNumber: weekNumber,
            startDate: start,
            endDate: end,
            overallMood: dominant,
            moodLabel: dominant.optimisticLabel,
            checkInCount: checkIns,
            totalDays: 7,
            summaryPhrase: checkIns > 0
                ? "\(checkIns) check-in minggu ini"
                : WeekSummary.placeholderNarrative(for: dominant).summaryPhrase,
            topTopics: [],
            moodTrendPoints: [],
            aiReflectionSummary: checkIns > 0
                ? "Kamu sudah check-in \(checkIns) kali minggu ini."
                : "Belum ada check-in minggu ini. Mulai dari satu catatan singkat.",
            aiReflectionLong: "Setiap check-in membantu kamu melihat pola dengan lebih jujur.",
            storyPages: [],
            moodBreakdown: [],
            topicChartItems: [],
            memorableMoments: [],
            improvements: [],
            quoteOfWeek: nil,
            stats: WeeklyStats(checkIns: checkIns, wordsWritten: 0, aiReflections: 0),
            wordCloud: [],
            frequentEmotions: checkIns > 0 ? [dominant.symbol] : [],
            checkInRhythm: Array(repeating: false, count: 7),
            entries: []
        )
    }

    private static func entries(
        from start: Date,
        to end: Date,
        in allEntries: [ReflectionEntry]
    ) -> [ReflectionEntry] {
        let endExclusive = calendar.date(byAdding: .day, value: 1, to: end) ?? end

        return allEntries.filter { entry in
            entry.date >= start && entry.date < endExclusive
        }
    }

    private static func dominantMood(in entries: [ReflectionEntry]) -> JedaMood? {
        guard !entries.isEmpty else { return nil }
        let counts = Dictionary(grouping: entries, by: \.mood).mapValues(\.count)
        return counts.max(by: { $0.value < $1.value })?.key
    }

    private static func weekID(year: Int, weekOfYear: Int) -> UUID {
        let token = year * 100 + weekOfYear
        return UUID(uuidString: String(format: "B1000000-0000-0000-0000-%012d", token)) ?? UUID()
    }
}
