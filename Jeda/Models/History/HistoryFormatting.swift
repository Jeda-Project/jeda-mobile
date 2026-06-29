/**
 * Scope: HistoryFormatting.swift
 * Purpose: Date and text formatting utilities for the History feature.
 */

import Foundation

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

    static func fullDateTimeString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMMM yyyy 'pukul' HH.mm 'WIB'"
        return formatter.string(from: date)
    }

    static func weekDays(for week: WeekSummary) -> [Date] {
        (0 ..< 7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: week.startDate)
        }
    }

    static func uniqueCheckInDayCount(for dates: [Date]) -> Int {
        Set(dates.map { calendar.startOfDay(for: $0) }).count
    }
}

extension JedaMood {
    var historyLabel: String {
        title
    }

    var optimisticLabel: String {
        switch self {
        case .heavy: "Berat"
        case .low: "Lelah"
        case .neutral: "Tenang"
        case .okay: "Lega"
        case .light: "Tenteram"
        }
    }
}
