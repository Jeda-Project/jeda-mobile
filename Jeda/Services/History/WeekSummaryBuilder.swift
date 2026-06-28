/**
 * Scope: WeekSummaryBuilder.swift
 * Purpose: Builds local WeekSummary baseline from persisted reflections.
 */

import Foundation

enum WeekSummaryBuilder {
    private static let stopWords: Set<String> = [
        "yang", "dan", "atau", "di", "ke", "dari", "ini", "itu", "saya", "aku", "kamu",
        "dengan", "untuk", "ada", "tidak", "bisa", "akan", "sudah", "jadi", "tapi", "juga",
        "kami", "mereka", "kita", "pada", "soal", "jeda", "entry", "versi", "lengkap", "preview",
    ]

    static func buildBaseline(
        template: WeekSummary,
        reflectionEntries: [ReflectionEntry]
    ) -> WeekSummary {
        let journalEntries: [JournalEntry]
        if !reflectionEntries.isEmpty {
            journalEntries = mapReflections(reflectionEntries)
        } else if !template.entries.isEmpty {
            journalEntries = template.entries
        } else {
            journalEntries = []
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

        let overallMood = dominantMood(in: journalEntries) ?? template.overallMood
        let checkInRhythm = checkInRhythm(for: template, entries: journalEntries)
        let checkInCount = checkInRhythm.filter { $0 }.count
        let topTopics = topTopics(from: journalEntries)
        let moodTrendPoints = moodTrendPoints(for: template, entries: journalEntries)
        let moodBreakdown = moodBreakdown(from: journalEntries)
        let topicChartItems = topicChartItems(from: journalEntries)
        let stats = weeklyStats(from: journalEntries, checkInCount: checkInCount)
        let wordCloud = wordCloud(from: journalEntries)
        let frequentEmotions = frequentEmotionSymbols(from: journalEntries)

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
            topTopics: topTopics,
            moodTrendPoints: moodTrendPoints,
            moodBreakdown: moodBreakdown,
            topicChartItems: topicChartItems,
            stats: stats,
            wordCloud: wordCloud,
            frequentEmotions: frequentEmotions,
            checkInRhythm: checkInRhythm,
            entryContentHash: entryHash(for: journalEntries)
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
            let topics = extractTopics(from: reflection.journalExcerpt)
            let title = title(from: reflection.journalExcerpt)
            var bodyParts = [reflection.journalExcerpt]
            if !reflection.reflectionText.isEmpty {
                bodyParts.append(reflection.reflectionText)
            }
            if let aiReply = reflection.aiReplyText, !aiReply.isEmpty {
                bodyParts.append(aiReply)
            }

            return JournalEntry(
                id: reflection.id,
                date: reflection.date,
                mood: reflection.mood,
                title: title,
                snippet: reflection.journalExcerpt,
                body: bodyParts.joined(separator: "\n\n"),
                topics: topics,
                reflectionQuestion: reflection.reflectionQuestion,
                timestamp: reflection.date
            )
        }
        .sorted { $0.date < $1.date }
    }

    private static func dominantMood(in entries: [JournalEntry]) -> JedaMood? {
        guard !entries.isEmpty else { return nil }
        let counts = Dictionary(grouping: entries, by: \.mood).mapValues(\.count)
        return counts.max(by: { $0.value < $1.value })?.key
    }

    private static func topTopics(from entries: [JournalEntry]) -> [String] {
        let counts = topicCounts(from: entries)
        return counts.sorted { $0.value > $1.value }.prefix(5).map(\.key)
    }

    private static func topicChartItems(from entries: [JournalEntry]) -> [JedaTopicChartItem] {
        topTopics(from: entries).map { topic in
            JedaTopicChartItem(topic: topic, count: topicCounts(from: entries)[topic, default: 0])
        }
    }

    private static func topicCounts(from entries: [JournalEntry]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for entry in entries {
            for topic in entry.topics {
                counts[topic, default: 0] += 1
            }
        }
        return counts
    }

    private static func moodBreakdown(from entries: [JournalEntry]) -> [MoodBreakdownItem] {
        let counts = Dictionary(grouping: entries, by: \.mood).mapValues(\.count)
        return JedaMood.allCases.compactMap { mood in
            guard let count = counts[mood], count > 0 else { return nil }
            return MoodBreakdownItem(mood: mood, count: count)
        }
    }

    private static func moodTrendPoints(for template: WeekSummary, entries: [JournalEntry]) -> [JedaMoodTrendPoint] {
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

    private static func checkInRhythm(for template: WeekSummary, entries: [JournalEntry]) -> [Bool] {
        let days = HistoryFormatting.weekDays(for: template)
        let calendar = Calendar.current
        return days.map { day in
            entries.contains { calendar.isDate($0.date, inSameDayAs: day) }
        }
    }

    private static func weeklyStats(from entries: [JournalEntry], checkInCount: Int) -> WeeklyStats {
        let words = entries.reduce(0) { partial, entry in
            partial + entry.body.split(whereSeparator: \.isWhitespace).count
        }
        let reflections = entries.filter { $0.reflectionQuestion != nil }.count
        return WeeklyStats(checkIns: checkInCount, wordsWritten: words, aiReflections: reflections)
    }

    private static func wordCloud(from entries: [JournalEntry]) -> [String] {
        var counts: [String: Int] = [:]
        for entry in entries {
            for word in tokenize(entry.body) {
                counts[word, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }.prefix(8).map(\.key)
    }

    private static func frequentEmotionSymbols(from entries: [JournalEntry]) -> [String] {
        let symbols = entries.map(\.mood.symbol)
        var counts: [String: Int] = [:]
        for symbol in symbols {
            counts[symbol, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }.prefix(4).map(\.key)
    }

    private static func extractTopics(from text: String) -> [String] {
        tokenize(text)
            .filter { $0.count > 4 && !stopWords.contains($0) }
            .prefix(3)
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
    }

    private static func title(from text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let firstSentence = trimmed.split(separator: ".").first {
            let sentence = String(firstSentence)
            return sentence.count > 60 ? String(sentence.prefix(57)) + "…" : sentence
        }
        return trimmed.count > 60 ? String(trimmed.prefix(57)) + "…" : trimmed
    }

    private static func tokenize(_ text: String) -> [String] {
        text
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 3 && !stopWords.contains($0) }
    }

    private static func entryHash(for entries: [JournalEntry]) -> String {
        let payload = entries.map { "\($0.id.uuidString):\($0.snippet)" }.joined(separator: "|")
        return String(payload.hashValue)
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
