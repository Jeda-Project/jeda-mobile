//
//  HistoryModels.swift
//  Jeda
//

import Foundation

struct JournalEntry: Identifiable, Hashable, Sendable {
    let id: UUID
    let date: Date
    let mood: JedaMood
    let title: String
    let snippet: String
    let body: String
    let topics: [String]
    let reflectionQuestion: String?
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

struct WeeklyStats: Hashable, Sendable {
    let checkIns: Int
    let wordsWritten: Int
    let aiReflections: Int
}

struct WeeklyStoryPage: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let symbol: String
    let body: String
}

struct MoodBreakdownItem: Identifiable, Hashable, Sendable {
    let mood: JedaMood
    let count: Int

    var id: Int { mood.rawValue }
}

struct WeekSummary: Identifiable, Sendable {
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

enum HistoryFormatting {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "id_ID")
        return calendar
    }()

    static func weekRangeString(from start: Date, to end: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d"
        let startDay = formatter.string(from: start)
        formatter.dateFormat = "d MMMM yyyy"
        return "\(startDay) - \(formatter.string(from: end))"
    }

    static func dayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).capitalized
    }

    static func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    static func timeString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    static func entryDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: date)
    }

    static func weekDays(for week: WeekSummary) -> [Date] {
        (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: week.startDate)
        }
    }
}

extension JedaMood {
    var historyLabel: String {
        switch self {
        case .heavy: "Sangat Sedih"
        case .low: "Sedih"
        case .neutral: "Netral"
        case .okay: "Baik"
        case .light: "Sangat Baik"
        }
    }

    var optimisticLabel: String {
        switch self {
        case .heavy: "Berat"
        case .low: "Turun"
        case .neutral: "Tenang"
        case .okay: "Optimis"
        case .light: "Ringan"
        }
    }
}
