/**
 * Scope: EnrichedWeekRegistry.swift
 * Purpose: In-memory registry for enriched WeekSummary instances and WeekSummary merge/placeholder extensions.
 */

import Foundation

@MainActor
enum EnrichedWeekRegistry {
    private static var weeks: [UUID: WeekSummary] = [:]
    private static var entryHashes: [UUID: String] = [:]

    static func store(_ week: WeekSummary, entryHash: String) {
        weeks[week.id] = week
        entryHashes[week.id] = entryHash
    }

    static func week(id: UUID) -> WeekSummary? {
        weeks[id]
    }

    static func enrichedWeek(id: UUID, entryHash: String) -> WeekSummary? {
        guard entryHashes[id] == entryHash, let week = weeks[id] else { return nil }
        return week
    }

    static func resolve(id: UUID, entries: [ReflectionEntry] = []) -> WeekSummary? {
        week(id: id) ?? HistoryWeekCatalog.week(withID: id, from: entries)
    }
}

extension WeekSummary {
    static func placeholderNarrative(for mood: JedaMood) -> (moodLabel: String, summaryPhrase: String) {
        (mood.optimisticLabel, "Memuat refleksi minggu ini…")
    }

    func merging(
        aiContent: WeeklySummaryAIContent,
        entries: [JournalEntry]
    ) -> WeekSummary {
        let memorable = aiContent.memorableMomentIndices.compactMap { index -> JournalEntry? in
            guard entries.indices.contains(index) else { return nil }
            return entries[index]
        }
        let resolvedMemorable = memorable.isEmpty ? Array(entries.prefix(3)) : memorable

        let storyPages = aiContent.storyPages.map {
            WeeklyStoryPage(id: UUID(), title: $0.title, symbol: $0.symbol, body: $0.body)
        }

        return WeekSummary(
            id: id,
            weekNumber: weekNumber,
            startDate: startDate,
            endDate: endDate,
            overallMood: overallMood,
            moodLabel: aiContent.moodLabel,
            checkInCount: checkInCount,
            totalDays: totalDays,
            summaryPhrase: aiContent.summaryPhrase,
            topTopics: topTopics,
            moodTrendPoints: moodTrendPoints,
            aiReflectionSummary: aiContent.aiReflectionSummary,
            aiReflectionLong: aiContent.aiReflectionLong,
            storyPages: storyPages.isEmpty ? self.storyPages : storyPages,
            moodBreakdown: moodBreakdown,
            topicChartItems: topicChartItems,
            memorableMoments: resolvedMemorable,
            improvements: aiContent.improvements,
            quoteOfWeek: aiContent.quoteOfWeek,
            stats: stats,
            wordCloud: wordCloud,
            frequentEmotions: frequentEmotions,
            checkInRhythm: checkInRhythm,
            entries: entries
        )
    }
}
