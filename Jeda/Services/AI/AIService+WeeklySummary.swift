/**
 * Scope: AIService+WeeklySummary.swift
 * Purpose: AIService extension for weekly summary generation, JSON decoding, and logging.
 */
import Foundation

extension AIService {
    func generateWeeklySummary(from snapshot: WeekSnapshot) async throws -> WeeklySummaryAIContent {
        guard !snapshot.entries.isEmpty else { throw AIServiceError.invalidPrompt }
        let systemPrompt = """
        Kamu asisten refleksi mingguan Jeda untuk pengguna Indonesia (18–35).
        Rangkum pola emosi dan tema journal minggu ini. Bahasa Indonesia, hangat, non-klinis.
        Gunakan "kamu". moodLabel: 1 kata optimistik. summaryPhrase: maks 8 kata.
        aiReflectionSummary: 2–3 kalimat. aiReflectionLong: 1–2 kalimat reflektif tanpa tanda kutip.
        storyPages: 4 item dengan keys title (judul English), symbol (nama SF Symbol), body (teks Bahasa Indonesia).
        Urutan storyPages: The Week in a Glance, Mood Journey, Top Topics, Growth Highlight.
        improvements: 2–3 bullet positif. quoteOfWeek: 1 kalimat. memorableMomentIndices: maks 3 indeks entry (0-based).
        Balas HANYA JSON dengan keys moodLabel, summaryPhrase, aiReflectionSummary, aiReflectionLong,
        storyPages, improvements, quoteOfWeek, memorableMomentIndices.
        """
        let range = HistoryFormatting.weekRangeString(from: snapshot.startDate, to: snapshot.endDate)
        let entries = snapshot.entries.map {
            "\($0.index). [\(HistoryFormatting.entryDateString(for: $0.date)), \($0.mood.title)] \"\($0.snippet)\""
        }.joined(separator: "\n")
        let userPrompt = """
        Minggu \(snapshot.weekNumber) (\(range))
        Check-in: \(snapshot.checkInCount)/\(snapshot.totalDays)
        Mood: \(snapshot.overallMood.optimisticLabel)
        Topics: \(snapshot.topTopics.joined(separator: ", "))
        Stats: \(snapshot.stats.wordsWritten) kata
        Entry:
        \(entries)
        """
        let messages: [ChatMessage] = [
            .init(role: .system, content: systemPrompt),
            .init(role: .user, content: userPrompt)
        ]
        let raw = try await complete(
            messages: messages, temperature: 0.65, maxTokens: 2048, responseFormat: .jsonObject
        )
        return try Self.decodeWeeklySummary(from: raw, fallbackMood: snapshot.overallMood.optimisticLabel)
    }

    struct WeeklySummaryPayload: Decodable {
        let moodLabel: String?
        let summaryPhrase: String?
        let aiReflectionSummary: String?
        let aiReflectionLong: String?
        let storyPages: [WeeklyStoryPageDTO]?
        let improvements: [String]?
        let quoteOfWeek: String?
        let memorableMomentIndices: [Int]?

        func materialized(fallbackMood: String) throws -> WeeklySummaryAIContent {
            guard
                let aiReflectionSummary = Self.nonEmpty(aiReflectionSummary)
            else {
                throw AIServiceError.decodingFailed("Field aiReflectionSummary tidak ada atau kosong.")
            }
            let pages = storyPages?.filter { Self.nonEmpty($0.body) != nil } ?? []
            let resolvedPages: [WeeklyStoryPageDTO]
            if pages.count >= 4 {
                resolvedPages = Array(pages.prefix(4))
            } else {
                let defaults: [WeeklyStoryPageDTO] = [
                    .init(title: "The Week in a Glance", symbol: "calendar", body: aiReflectionSummary),
                    .init(
                        title: "Mood Journey",
                        symbol: "waveform.path.ecg",
                        body: Self.nonEmpty(aiReflectionLong) ?? aiReflectionSummary
                    ),
                    .init(
                        title: "Top Topics",
                        symbol: "text.bubble",
                        body: Self.nonEmpty(summaryPhrase) ?? aiReflectionSummary
                    ),
                    .init(
                        title: "Growth Highlight",
                        symbol: "leaf",
                        body: Self.nonEmpty(aiReflectionLong) ?? aiReflectionSummary
                    )
                ]
                resolvedPages = pages + defaults.dropFirst(pages.count)
            }
            return WeeklySummaryAIContent(
                moodLabel: Self.nonEmpty(moodLabel) ?? fallbackMood,
                summaryPhrase: Self.nonEmpty(summaryPhrase) ?? "Refleksi minggu ini",
                aiReflectionSummary: aiReflectionSummary,
                aiReflectionLong: Self.nonEmpty(aiReflectionLong) ?? aiReflectionSummary,
                storyPages: resolvedPages,
                improvements: improvements?.compactMap(Self.nonEmpty) ?? [],
                quoteOfWeek: Self.nonEmpty(quoteOfWeek),
                memorableMomentIndices: memorableMomentIndices ?? [0]
            )
        }

        nonisolated private static func nonEmpty(_ value: String?) -> String? {
            guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !trimmed.isEmpty else { return nil }
            return trimmed
        }
    }

    static func decodeWeeklySummary(from raw: String, fallbackMood: String) throws -> WeeklySummaryAIContent {
        let json = extractJSONObject(from: raw)
        guard let data = json.data(using: .utf8) else { throw AIServiceError.decodingFailed("Encoding gagal.") }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(WeeklySummaryPayload.self, from: data).materialized(fallbackMood: fallbackMood)
        } catch let error as AIServiceError {
            logWeeklySummaryDecodeFailure(raw: raw, extracted: json, error: error)
            throw error
        } catch {
            logWeeklySummaryDecodeFailure(raw: raw, extracted: json, error: error)
            throw AIServiceError.decodingFailed(decodingDetail(from: error))
        }
    }

    static func extractJSONObject(from raw: String) -> String {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("```") {
            var lines = text.components(separatedBy: .newlines)
            if lines.first?.hasPrefix("```") == true { lines.removeFirst() }
            if lines.last?.hasPrefix("```") == true { lines.removeLast() }
            text = lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard let start = text.firstIndex(of: "{"), let end = text.lastIndex(of: "}") else { return text }
        return String(text[start ... end])
    }

    private static func decodingDetail(from error: Error) -> String {
        switch error {
        case let DecodingError.keyNotFound(key, ctx):
            "Field '\(key.stringValue)' tidak ada (\(ctx.codingPath.map(\.stringValue).joined(separator: ".")))"
        case let DecodingError.typeMismatch(_, ctx):
            "Tipe field tidak cocok (\(ctx.codingPath.map(\.stringValue).joined(separator: ".")))"
        case let DecodingError.valueNotFound(_, ctx):
            "Nilai field kosong (\(ctx.codingPath.map(\.stringValue).joined(separator: ".")))"
        default: error.localizedDescription
        }
    }

    private static func logWeeklySummaryDecodeFailure(raw: String, extracted: String, error: Error) {
        print("[Jeda AI Reflection] Decode weekly summary gagal")
        print("[Jeda AI Reflection] Extracted JSON (\(extracted.count) chars): \(extracted.prefix(800))")
        if extracted.count > 800 { print("[Jeda AI] … (truncated, total \(extracted.count) chars)") }
        print("[Jeda AI Reflection] Raw response (\(raw.count) chars): \(raw.prefix(400))")
    }
}
