//
//  AIService.swift
//  Jeda
//
//  Client untuk OpenAI chat completions API.
//

import Foundation

protocol AICompleting: Sendable {
    func complete(
        messages: [ChatMessage],
        temperature: Double?,
        maxTokens: Int?,
        responseFormat: ChatCompletionResponseFormat?
    ) async throws -> String

    func generateReflection(for journalEntry: String, detectedEmotion: String?) async throws -> String

    func generateWeeklySummary(from snapshot: WeekSnapshot) async throws -> WeeklySummaryAIContent
}

enum AIServiceError: LocalizedError, Sendable {
    case missingAPIKey
    case emptyResponse
    case invalidPrompt
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            "API key OpenAI belum dikonfigurasi. Tambahkan OPENAI_API_KEY di Secrets.plist."
        case .emptyResponse:
            "Model AI tidak mengembalikan respons."
        case .invalidPrompt:
            "Teks journal kosong."
        case .decodingFailed(let detail):
            "Respons AI tidak valid: \(detail)"
        }
    }
}

struct AIService: AICompleting {
    private let api: APIService
    private let model: String

    init(api: APIService, model: String = JedaAIConstants.aiModel) {
        self.api = api
        self.model = model
    }

    static func makeDefault(keyProvider: AIAPIKeyProviding = BundleAIAPIKeyProvider()) throws -> AIService {
        let apiKey = try keyProvider.apiKey()
        let configuration = APIConfiguration.openAI(apiKey: apiKey)
        return AIService(api: APIService(configuration: configuration))
    }

    func complete(
        messages: [ChatMessage],
        temperature: Double? = 0.7,
        maxTokens: Int? = 512,
        responseFormat: ChatCompletionResponseFormat? = nil
    ) async throws -> String {
        let request = ChatCompletionRequest(
            model: model,
            messages: messages,
            temperature: temperature,
            maxTokens: maxTokens,
            responseFormat: responseFormat
        )

        let response = try await api.request(
            ChatCompletionAPIEndpoint.complete(request),
            responseType: ChatCompletionResponse.self
        )

        guard let content = response.firstContent?.trimmingCharacters(in: .whitespacesAndNewlines),
              !content.isEmpty
        else {
            throw AIServiceError.emptyResponse
        }

        return content
    }

    func generateReflection(for journalEntry: String, detectedEmotion: String? = nil) async throws -> String {
        let trimmed = journalEntry.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw AIServiceError.invalidPrompt }

        var systemPrompt = """
        Kamu asisten refleksi Jeda untuk developer/builder Indonesia.
        Balas singkat (2-3 kalimat), hangat, non-klinis, dan ajak user mengeksplorasi perasaan.
        Jangan diagnosis medis. Gunakan Bahasa Indonesia.
        """

        if let detectedEmotion {
            systemPrompt += "\nEmosi terdeteksi dari entry: \(detectedEmotion)."
        }

        let messages: [ChatMessage] = [
            .init(role: .system, content: systemPrompt),
            .init(role: .user, content: trimmed),
        ]

        return try await complete(messages: messages, temperature: 0.7, maxTokens: 256)
    }

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
        Balas HANYA JSON dengan keys moodLabel, summaryPhrase, aiReflectionSummary, aiReflectionLong, storyPages, improvements, quoteOfWeek, memorableMomentIndices.
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

        let raw = try await complete(
            messages: [
                .init(role: .system, content: systemPrompt),
                .init(role: .user, content: userPrompt),
            ],
            temperature: 0.65,
            maxTokens: 2048,
            responseFormat: .jsonObject
        )
        return try Self.decodeWeeklySummary(from: raw, fallbackMood: snapshot.overallMood.optimisticLabel)
    }

    private struct WeeklySummaryPayload: Decodable {
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
                    .init(title: "Mood Journey", symbol: "waveform.path.ecg", body: Self.nonEmpty(aiReflectionLong) ?? aiReflectionSummary),
                    .init(title: "Top Topics", symbol: "text.bubble", body: Self.nonEmpty(summaryPhrase) ?? aiReflectionSummary),
                    .init(title: "Growth Highlight", symbol: "leaf", body: Self.nonEmpty(aiReflectionLong) ?? aiReflectionSummary),
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

        private static func nonEmpty(_ value: String?) -> String? {
            guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
                return nil
            }
            return trimmed
        }
    }

    private static func decodeWeeklySummary(from raw: String, fallbackMood: String) throws -> WeeklySummaryAIContent {
        let json = extractJSONObject(from: raw)
        guard let data = json.data(using: .utf8) else {
            throw AIServiceError.decodingFailed("Encoding gagal.")
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            let payload = try decoder.decode(WeeklySummaryPayload.self, from: data)
            return try payload.materialized(fallbackMood: fallbackMood)
        } catch let error as AIServiceError {
            logWeeklySummaryDecodeFailure(raw: raw, extracted: json, error: error)
            throw error
        } catch {
            logWeeklySummaryDecodeFailure(raw: raw, extracted: json, error: error)
            throw AIServiceError.decodingFailed(decodingDetail(from: error))
        }
    }

    private static func extractJSONObject(from raw: String) -> String {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("```") {
            var lines = text.components(separatedBy: .newlines)
            if lines.first?.hasPrefix("```") == true {
                lines.removeFirst()
            }
            if lines.last?.hasPrefix("```") == true {
                lines.removeLast()
            }
            text = lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard let start = text.firstIndex(of: "{"), let end = text.lastIndex(of: "}") else {
            return text
        }
        return String(text[start...end])
    }

    private static func decodingDetail(from error: Error) -> String {
        switch error {
        case DecodingError.keyNotFound(let key, let context):
            "Field '\(key.stringValue)' tidak ada (\(context.codingPath.map(\.stringValue).joined(separator: ".")))"
        case DecodingError.typeMismatch(_, let context):
            "Tipe field tidak cocok (\(context.codingPath.map(\.stringValue).joined(separator: ".")))"
        case DecodingError.valueNotFound(_, let context):
            "Nilai field kosong (\(context.codingPath.map(\.stringValue).joined(separator: ".")))"
        default:
            error.localizedDescription
        }
    }

    private static func logWeeklySummaryDecodeFailure(raw: String, extracted: String, error: Error) {
        print("[Jeda AI Reflection] Decode weekly summary gagal")
        print("[Jeda AI Reflection] Extracted JSON (\(extracted.count) chars): \(extracted.prefix(800))")
        if extracted.count > 800 {
            print("[Jeda AI Reflection] … (truncated, total \(extracted.count) chars)")
        }
        print("[Jeda AI Reflection] Raw response (\(raw.count) chars): \(raw.prefix(400))")
    }
}
