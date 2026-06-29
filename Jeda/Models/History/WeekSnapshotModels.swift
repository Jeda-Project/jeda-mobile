/**
 * Scope: WeekSnapshotModels.swift
 * Purpose: Pure snapshot and AI output types used as input for weekly history summarization.
 */

import Foundation

struct JournalEntrySnapshot {
    let index: Int
    let id: UUID
    let date: Date
    let mood: JedaMood
    let snippet: String
    let topics: [String]
}

struct WeekSnapshot {
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

struct WeeklyStoryPageDTO: Codable, Equatable {
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

struct WeeklySummaryAIContent: Codable, Equatable {
    let moodLabel: String
    let summaryPhrase: String
    let aiReflectionSummary: String
    let aiReflectionLong: String
    let storyPages: [WeeklyStoryPageDTO]
    let improvements: [String]
    let quoteOfWeek: String?
    let memorableMomentIndices: [Int]
}

enum WeekSummaryLoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed
}
