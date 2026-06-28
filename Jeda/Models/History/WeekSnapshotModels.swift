/**
 * Scope: WeekSnapshotModels.swift
 * Purpose: Snapshot input and AI output types for weekly history summarization.
 */

import Foundation

struct JournalEntrySnapshot: Sendable {
    let index: Int
    let id: UUID
    let date: Date
    let mood: JedaMood
    let snippet: String
    let topics: [String]
}

struct WeekSnapshot: Sendable {
    let weekID: UUID
    let weekNumber: Int
    let startDate: Date
    let endDate: Date
    let entries: [JournalEntrySnapshot]
    let journalEntries: [JournalEntry]
    let overallMood: JedaMood
    let checkInCount: Int
    let totalDays: Int
    let topTopics: [String]
    let moodTrendPoints: [JedaMoodTrendPoint]
    let moodBreakdown: [MoodBreakdownItem]
    let topicChartItems: [JedaTopicChartItem]
    let stats: WeeklyStats
    let wordCloud: [String]
    let frequentEmotions: [String]
    let checkInRhythm: [Bool]
    let entryContentHash: String
}

struct WeeklyStoryPageDTO: Codable, Sendable, Equatable {
    let title: String
    let symbol: String
    let body: String

    init(title: String, symbol: String, body: String) {
        self.title = title
        self.symbol = symbol
        self.body = body
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title)
            ?? container.decode(String.self, forKey: .titleEN)
        symbol = try container.decodeIfPresent(String.self, forKey: .symbol) ?? "calendar"
        body = try container.decodeIfPresent(String.self, forKey: .body)
            ?? container.decode(String.self, forKey: .bodyID)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(body, forKey: .body)
    }

    private enum CodingKeys: String, CodingKey {
        case title
        case titleEN = "title EN"
        case symbol
        case body
        case bodyID = "body ID"
    }
}

struct WeeklySummaryAIContent: Codable, Sendable, Equatable {
    let moodLabel: String
    let summaryPhrase: String
    let aiReflectionSummary: String
    let aiReflectionLong: String
    let storyPages: [WeeklyStoryPageDTO]
    let improvements: [String]
    let quoteOfWeek: String?
    let memorableMomentIndices: [Int]
}

enum WeekSummaryLoadState: Equatable, Sendable {
    case idle
    case loading
    case loaded
    case failed
}

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

enum WeekSummaryCachePolicy: Sendable {
    case persistent
    case sessionOnly
}

enum WeekSummaryCache {
    private static let prefix = "jeda.weekSummary.ai."

    static func policy(for week: WeekSummary) -> WeekSummaryCachePolicy {
        week.isCurrentWeek ? .sessionOnly : .persistent
    }

    static func load(
        weekID: UUID,
        policy: WeekSummaryCachePolicy,
        entryHash: String
    ) -> WeeklySummaryAIContent? {
        switch policy {
        case .sessionOnly:
            return nil
        case .persistent:
            let key = persistentCacheKey(weekID: weekID)
            guard
                let data = UserDefaults.standard.data(forKey: key),
                let content = try? JSONDecoder().decode(WeeklySummaryAIContent.self, from: data)
            else {
                return nil
            }
            return content
        }
    }

    static func save(
        weekID: UUID,
        policy: WeekSummaryCachePolicy,
        entryHash: String,
        content: WeeklySummaryAIContent
    ) {
        guard policy == .persistent else { return }
        let key = persistentCacheKey(weekID: weekID)
        guard let data = try? JSONEncoder().encode(content) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func saveSummaryPhrase(
        weekID: UUID,
        entryHash: String,
        phrase: String,
        moodLabel: String,
        policy: WeekSummaryCachePolicy
    ) {
        guard policy == .persistent else { return }
        UserDefaults.standard.set(phrase, forKey: "\(prefix)phrase.\(weekID.uuidString)")
        UserDefaults.standard.set(moodLabel, forKey: "\(prefix)moodLabel.\(weekID.uuidString)")
    }

    static func cachedSummaryPhrase(
        weekID: UUID,
        entryHash: String?,
        policy: WeekSummaryCachePolicy
    ) -> (phrase: String, moodLabel: String)? {
        guard policy == .persistent else { return nil }
        guard
            let phrase = UserDefaults.standard.string(forKey: "\(prefix)phrase.\(weekID.uuidString)"),
            let moodLabel = UserDefaults.standard.string(forKey: "\(prefix)moodLabel.\(weekID.uuidString)")
        else {
            return nil
        }
        return (phrase, moodLabel)
    }

    private static func persistentCacheKey(weekID: UUID) -> String {
        "\(prefix)\(weekID.uuidString)"
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
