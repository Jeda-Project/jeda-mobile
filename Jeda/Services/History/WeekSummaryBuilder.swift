/**
 * Scope: WeekSummaryBuilder.swift
 * Purpose: Builds local WeekSummary baseline from persisted reflections by orchestrating WeekMetricsComputer.
 */

import Foundation

enum WeekSummaryBuilder {
    static func buildBaseline(
        template: WeekSummary,
        reflectionEntries: [ReflectionEntry]
    ) -> WeekSummary {
        let journalEntries: [JournalEntry] = if !reflectionEntries.isEmpty {
            mapReflections(reflectionEntries)
        } else if !template.entries.isEmpty {
            template.entries
        } else {
            []
        }

        let snapshot = makeSnapshot(template: template, journalEntries: journalEntries)
        return weekSummary(from: snapshot, narrative: template)
    }

    static func makeSnapshot(template: WeekSummary, journalEntries: [JournalEntry]) -> WeekSnapshot {
        let entrySnapshots = journalEntries.enumerated().map { index, entry in
            JournalEntrySnapshot(
                index: index,
                id: entry.id,
                date: entry.date,
                mood: entry.mood,
                snippet: entry.snippet,
                topics: entry.topics
            )
        }

        let overallMood = WeekMetricsComputer.dominantMood(in: journalEntries) ?? template.overallMood
        let checkInRhythm = WeekMetricsComputer.checkInRhythm(for: template, entries: journalEntries)
        let checkInCount = journalEntries.count

        return WeekSnapshot(
            weekID: template.id,
            weekNumber: template.weekNumber,
            startDate: template.startDate,
            endDate: template.endDate,
            entries: entrySnapshots,
            journalEntries: journalEntries,
            overallMood: overallMood,
            checkInCount: checkInCount,
            totalDays: template.totalDays,
            topTopics: WeekMetricsComputer.topTopics(from: journalEntries),
            moodTrendPoints: WeekMetricsComputer.moodTrendPoints(for: template, entries: journalEntries),
            moodBreakdown: WeekMetricsComputer.moodBreakdown(from: journalEntries),
            topicChartItems: WeekMetricsComputer.topicChartItems(from: journalEntries),
            stats: WeekMetricsComputer.weeklyStats(from: journalEntries, checkInCount: checkInCount),
            wordCloud: WeekMetricsComputer.wordCloud(from: journalEntries),
            frequentEmotions: WeekMetricsComputer.frequentEmotionSymbols(from: journalEntries),
            checkInRhythm: checkInRhythm,
            entryContentHash: WeekMetricsComputer.entryHash(for: journalEntries)
        )
    }

    static func weekSummary(from snapshot: WeekSnapshot, narrative: WeekSummary) -> WeekSummary {
        let placeholder = WeekSummary.placeholderNarrative(for: snapshot.overallMood)
        let policy = WeekSummaryCache.policy(for: narrative)
        let cached = WeekSummaryCache.cachedSummaryPhrase(
            weekID: snapshot.weekID,
            entryHash: policy == .sessionOnly ? snapshot.entryContentHash : nil,
            policy: policy
        )

        return WeekSummary(
            id: snapshot.weekID,
            weekNumber: snapshot.weekNumber,
            startDate: snapshot.startDate,
            endDate: snapshot.endDate,
            overallMood: snapshot.overallMood,
            moodLabel: cached?.moodLabel ?? placeholder.moodLabel,
            checkInCount: snapshot.checkInCount,
            totalDays: snapshot.totalDays,
            summaryPhrase: cached?.phrase ?? placeholder.summaryPhrase,
            topTopics: snapshot.topTopics,
            moodTrendPoints: snapshot.moodTrendPoints,
            aiReflectionSummary: narrative.aiReflectionSummary,
            aiReflectionLong: narrative.aiReflectionLong,
            storyPages: narrative.storyPages,
            moodBreakdown: snapshot.moodBreakdown,
            topicChartItems: snapshot.topicChartItems,
            memorableMoments: Array(snapshot.journalEntries.prefix(3)),
            improvements: narrative.improvements,
            quoteOfWeek: narrative.quoteOfWeek,
            stats: snapshot.stats,
            wordCloud: snapshot.wordCloud,
            frequentEmotions: snapshot.frequentEmotions,
            checkInRhythm: snapshot.checkInRhythm,
            entries: snapshot.journalEntries
        )
    }

    static func reflections(in template: WeekSummary, from store: ReflectionStore) -> [ReflectionEntry] {
        let calendar = Calendar.current
        let endOfWeek = calendar.date(byAdding: .day, value: 1, to: template.endDate) ?? template.endDate

        return store.entries.filter { entry in
            entry.date >= template.startDate && entry.date < endOfWeek
        }
    }

    private static func mapReflections(_ reflections: [ReflectionEntry]) -> [JournalEntry] {
        reflections.map { reflection in
            let topics = WeekMetricsComputer.extractTopics(from: reflection.journalExcerpt)
            let title = WeekMetricsComputer.title(from: reflection.journalExcerpt)
            return JournalEntry(
                id: reflection.id,
                date: reflection.date,
                mood: reflection.mood,
                title: title,
                snippet: reflection.journalExcerpt,
                body: reflection.journalExcerpt,
                topics: topics,
                reflectionQuestion: reflection.reflectionQuestion.isEmpty ? nil : reflection.reflectionQuestion,
                reflectionText: reflection.reflectionText,
                aiReplyText: reflection.aiReplyText,
                timestamp: reflection.date
            )
        }
        .sorted { $0.date < $1.date }
    }
}

extension Emotion {
    var jedaMood: JedaMood {
        switch self {
        case .sadness: .heavy
        case .anger: .heavy
        case .fear: .low
        case .love: .okay
        case .happy: .light
        }
    }
}
