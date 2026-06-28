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
        maxTokens: Int?
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
}
