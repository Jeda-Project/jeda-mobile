/**
 * Scope: MockAICompletingService.swift
 * Purpose: Placeholder AICompleting implementation that returns canned responses until a production backend is wired up.
 */

import Foundation

struct MockAICompletingService: AICompleting {
    private static let cannedReplies = [
        "Terima kasih sudah cerita. Sepertinya momen itu cukup berarti buatmu — apa yang membuatnya terasa begitu?",
        "Aku dengar kamu. Coba pikirkan, apa yang sebenarnya kamu butuhkan saat menghadapi situasi seperti itu?",
        "Itu perasaan yang valid. Kalau dilihat lagi, hal kecil apa yang bisa membantumu merasa lebih baik hari ini?",
        "Menulis ini saja sudah langkah baik. Menurutmu, apa yang berubah dibanding saat pertama kali kamu merasakannya?",
    ]

    func complete(
        messages: [ChatMessage],
        temperature: Double?,
        maxTokens: Int?,
        responseFormat: ChatCompletionResponseFormat? = nil
    ) async throws -> String {
        try await Task.sleep(for: .milliseconds(1200))
        return Self.cannedReplies.randomElement() ?? Self.cannedReplies[0]
    }

    func generateReflection(for journalEntry: String, detectedEmotion: String?) async throws -> String {
        try await Task.sleep(for: .milliseconds(1200))
        let trimmed = journalEntry.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw AIServiceError.invalidPrompt }
        return Self.cannedReplies.randomElement() ?? Self.cannedReplies[0]
    }

    func generateWeeklySummary(from snapshot: WeekSnapshot) async throws -> WeeklySummaryAIContent {
        try await Task.sleep(for: .milliseconds(1200))
        guard !snapshot.entries.isEmpty else { throw AIServiceError.invalidPrompt }

        return WeeklySummaryAIContent(
            moodLabel: snapshot.overallMood.optimisticLabel,
            summaryPhrase: "Minggu dengan \(snapshot.checkInCount) check-in",
            aiReflectionSummary: "Minggu ini kamu menulis \(snapshot.checkInCount) kali. Pola emosi terlihat dari entry yang sudah kamu catat.",
            aiReflectionLong: "Setiap check-in adalah langkah kecil untuk memahami diri sendiri lebih jujur.",
            storyPages: [
                .init(title: "The Week in a Glance", symbol: "calendar", body: "Ringkasan minggu \(snapshot.weekNumber) dari mock AI."),
                .init(title: "Mood Journey", symbol: "waveform.path.ecg", body: "Mood dominan: \(snapshot.overallMood.title)."),
                .init(title: "Top Topics", symbol: "text.bubble", body: snapshot.topTopics.joined(separator: ", ")),
                .init(title: "Growth Highlight", symbol: "leaf", body: "Konsistensi check-in membantu melihat pola lebih jelas."),
            ],
            improvements: ["Tetap jujur saat menulis", "Luangkan waktu refleksi singkat"],
            quoteOfWeek: "Setiap check-in adalah langkah kecil untuk memahami diri sendiri.",
            memorableMomentIndices: [0]
        )
    }
}
