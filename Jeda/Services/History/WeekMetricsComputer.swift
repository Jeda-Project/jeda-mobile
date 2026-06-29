/**
 * Scope: WeekMetricsComputer.swift
 * Purpose: Pure metric computation functions for weekly summary analytics (mood, topics, stats, word cloud).
 */

import Foundation

enum WeekMetricsComputer {
    static let stopWords: Set<String> = [
        "yang", "dan", "atau", "di", "ke", "dari", "ini", "itu", "saya", "aku", "kamu",
        "dengan", "untuk", "ada", "tidak", "bisa", "akan", "sudah", "jadi", "tapi", "juga",
        "kami", "mereka", "kita", "pada", "soal", "jeda", "entry", "versi", "lengkap", "preview"
    ]

    static func dominantMood(in entries: [JournalEntry]) -> JedaMood? {
        guard !entries.isEmpty else { return nil }
        let counts = Dictionary(grouping: entries, by: \.mood).mapValues(\.count)
        return counts.max(by: { $0.value < $1.value })?.key
    }

    static func topTopics(from entries: [JournalEntry]) -> [String] {
        let counts = topicCounts(from: entries)
        return counts.sorted { $0.value > $1.value }.prefix(5).map(\.key)
    }

    static func topicChartItems(from entries: [JournalEntry]) -> [JedaTopicChartItem] {
        topTopics(from: entries).map { topic in
            JedaTopicChartItem(topic: topic, count: topicCounts(from: entries)[topic, default: 0])
        }
    }

    static func topicCounts(from entries: [JournalEntry]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for entry in entries {
            for topic in entry.topics {
                counts[topic, default: 0] += 1
            }
        }
        return counts
    }

    static func moodBreakdown(from entries: [JournalEntry]) -> [MoodBreakdownItem] {
        let counts = Dictionary(grouping: entries, by: \.mood).mapValues(\.count)
        return JedaMood.allCases.compactMap { mood in
            guard let count = counts[mood], count > 0 else { return nil }
            return MoodBreakdownItem(mood: mood, count: count)
        }
    }

    static func moodTrendPoints(for template: WeekSummary, entries: [JournalEntry]) -> [JedaMoodTrendPoint] {
        let days = HistoryFormatting.weekDays(for: template)
        let calendar = Calendar.current

        return days.map { day in
            let dayEntries = entries.filter { calendar.isDate($0.date, inSameDayAs: day) }
            let score: Double
            if dayEntries.isEmpty {
                score = Double(template.overallMood.rawValue)
            } else {
                let average = dayEntries.map { Double($0.mood.rawValue) }.reduce(0, +) / Double(dayEntries.count)
                score = average
            }
            return JedaMoodTrendPoint(day: HistoryFormatting.dayAbbreviation(for: day), score: score)
        }
    }

    static func checkInRhythm(for template: WeekSummary, entries: [JournalEntry]) -> [Bool] {
        let days = HistoryFormatting.weekDays(for: template)
        let calendar = Calendar.current
        return days.map { day in
            entries.contains { calendar.isDate($0.date, inSameDayAs: day) }
        }
    }

    static func weeklyStats(from entries: [JournalEntry], checkInCount: Int) -> WeeklyStats {
        let words = entries.reduce(0) { partial, entry in
            partial + entry.body.split(whereSeparator: \.isWhitespace).count
        }
        let reflections = entries.filter { $0.aiReplyText?.isEmpty == false }.count
        return WeeklyStats(checkIns: checkInCount, wordsWritten: words, aiReflections: reflections)
    }

    static func wordCloud(from entries: [JournalEntry]) -> [String] {
        var counts: [String: Int] = [:]
        for entry in entries {
            for word in tokenize(entry.body) {
                counts[word, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }.prefix(8).map(\.key)
    }

    static func frequentEmotionSymbols(from entries: [JournalEntry]) -> [String] {
        let symbols = entries.map(\.mood.symbol)
        var counts: [String: Int] = [:]
        for symbol in symbols {
            counts[symbol, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }.prefix(4).map(\.key)
    }

    static func extractTopics(from text: String) -> [String] {
        tokenize(text)
            .filter { $0.count > 4 && !stopWords.contains($0) }
            .prefix(3)
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
    }

    static func title(from text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let firstSentence = trimmed.split(separator: ".").first {
            let sentence = String(firstSentence)
            return sentence.count > 60 ? String(sentence.prefix(57)) + "…" : sentence
        }
        return trimmed.count > 60 ? String(trimmed.prefix(57)) + "…" : trimmed
    }

    static func tokenize(_ text: String) -> [String] {
        text
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 3 && !stopWords.contains($0) }
    }

    static func entryHash(for entries: [JournalEntry]) -> String {
        let payload = entries.map { "\($0.id.uuidString):\($0.snippet)" }.joined(separator: "|")
        return String(payload.hashValue)
    }
}
