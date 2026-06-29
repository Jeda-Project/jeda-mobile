/**
 * Scope: HistoryModels.swift
 * Purpose: Defines data models for the history feature including weekly and daily summary structures.
 */

import Foundation

struct JournalEntry: Identifiable, Hashable {
    let id: UUID
    let date: Date
    let mood: JedaMood
    let title: String
    let snippet: String
    let body: String
    let topics: [String]
    let reflectionQuestion: String?
    let reflectionText: String?
    let aiReplyText: String?
    let timestamp: Date

    var dayAbbreviation: String {
        HistoryFormatting.dayAbbreviation(for: date)
    }

    var formattedTime: String {
        HistoryFormatting.timeString(for: timestamp)
    }

    var formattedDate: String {
        HistoryFormatting.entryDateString(for: date)
    }
}

struct WeeklyStats: Hashable {
    let checkIns: Int
    let wordsWritten: Int
    let aiReflections: Int
}

struct WeeklyStoryPage: Identifiable, Hashable {
    let id: UUID
    let title: String
    let symbol: String
    let body: String
}

struct MoodBreakdownItem: Identifiable, Hashable {
    let mood: JedaMood
    let count: Int

    var id: Int {
        mood.rawValue
    }
}

struct WeekSummary: Identifiable {
    let id: UUID
    let weekNumber: Int
    let startDate: Date
    let endDate: Date
    let overallMood: JedaMood
    let moodLabel: String
    let checkInCount: Int
    let totalDays: Int
    let summaryPhrase: String
    let topTopics: [String]
    let moodTrendPoints: [JedaMoodTrendPoint]
    let aiReflectionSummary: String
    let aiReflectionLong: String
    let storyPages: [WeeklyStoryPage]
    let moodBreakdown: [MoodBreakdownItem]
    let topicChartItems: [JedaTopicChartItem]
    let memorableMoments: [JournalEntry]
    let improvements: [String]
    let quoteOfWeek: String?
    let stats: WeeklyStats
    let wordCloud: [String]
    let frequentEmotions: [String]
    let checkInRhythm: [Bool]
    let entries: [JournalEntry]

    var dateRangeText: String {
        HistoryFormatting.weekRangeString(from: startDate, to: endDate)
    }

    var checkInProgress: Double {
        guard totalDays > 0 else { return 0 }
        return Double(checkInCount) / Double(totalDays)
    }

    var isCurrentWeek: Bool {
        Calendar.current.isDate(startDate, equalTo: Date(), toGranularity: .weekOfYear)
    }
}

enum HistoryDestination: Hashable {
    case weeklySummary(UUID)
    case weeklyStory(UUID)
    case dailyEntries(UUID)
    case entryDetail(entryID: UUID, weekID: UUID)
}
