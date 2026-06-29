/**
 * Scope: PreviewStubs.swift
 * Purpose: Minimal stub data for SwiftUI Previews in the History feature.
 */

import Foundation

enum PreviewStubs {
    static let entry = JournalEntry(
        id: UUID(),
        date: Date(),
        mood: .okay,
        title: "Hari yang tenang",
        snippet: "Hari ini terasa lebih ringan dari biasanya.",
        body: "Hari ini terasa lebih ringan dari biasanya. Saya mencoba untuk lebih hadir di setiap momen.",
        topics: ["Ketenangan", "Syukur"],
        reflectionQuestion: "Apa yang membuatmu merasa tenang hari ini?",
        reflectionText: "Mendengarkan musik dan berjalan santai.",
        aiReplyText: nil,
        timestamp: Date()
    )

    static let stats = WeeklyStats(checkIns: 5, wordsWritten: 420, aiReflections: 2)

    static let week = WeekSummary(
        id: UUID(),
        weekNumber: 26,
        startDate: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(),
        endDate: Date(),
        overallMood: .okay,
        moodLabel: "Cukup Baik",
        checkInCount: 5,
        totalDays: 7,
        summaryPhrase: "Minggu yang cukup stabil",
        topTopics: ["Ketenangan", "Pekerjaan", "Keluarga"],
        moodTrendPoints: [
            JedaMoodTrendPoint(day: "Sen", score: 3),
            JedaMoodTrendPoint(day: "Sel", score: 4),
            JedaMoodTrendPoint(day: "Rab", score: 3),
            JedaMoodTrendPoint(day: "Kam", score: 4),
            JedaMoodTrendPoint(day: "Jum", score: 5)
        ],
        aiReflectionSummary: "Minggu ini kamu menunjukkan ketahanan yang baik.",
        aiReflectionLong: "Minggu ini kamu menunjukkan ketahanan yang baik "
            + "dalam menghadapi berbagai tantangan sehari-hari.",
        storyPages: [
            WeeklyStoryPage(
                id: UUID(),
                title: "Awal Minggu",
                symbol: "sunrise",
                body: "Kamu memulai minggu dengan penuh semangat."
            ),
            WeeklyStoryPage(
                id: UUID(),
                title: "Pertengahan",
                symbol: "cloud.sun",
                body: "Ada saat naik dan turun, tapi kamu tetap melangkah."
            )
        ],
        moodBreakdown: [
            MoodBreakdownItem(mood: .okay, count: 3),
            MoodBreakdownItem(mood: .light, count: 2)
        ],
        topicChartItems: [
            JedaTopicChartItem(topic: "Ketenangan", count: 4),
            JedaTopicChartItem(topic: "Pekerjaan", count: 2)
        ],
        memorableMoments: [entry],
        improvements: ["Tidur lebih awal", "Kurangi screen time"],
        quoteOfWeek: "Setiap hari adalah kesempatan baru.",
        stats: stats,
        wordCloud: ["tenang", "syukur", "keluarga", "kerja"],
        frequentEmotions: ["Lega", "Netral"],
        checkInRhythm: [true, true, false, true, true, false, true],
        entries: [entry]
    )

    static let weeks: [WeekSummary] = [week]
}
