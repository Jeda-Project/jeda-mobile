/**
 * Scope: BackendDateFormat.swift
 * Purpose: Parses and formats ISO 8601 datetime and date strings exchanged with the Jeda backend.
 */

import Foundation

enum BackendDateFormat {
    private static let dateTimeWithFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let dateTime: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let dayOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func dateTimeString(from date: Date) -> String {
        dateTime.string(from: date)
    }

    static func date(fromDateTime string: String) -> Date? {
        dateTimeWithFractional.date(from: string) ?? dateTime.date(from: string)
    }

    static func dayString(from date: Date) -> String {
        dayOnly.string(from: date)
    }

    static func date(fromDay string: String) -> Date? {
        dayOnly.date(from: string)
    }
}
