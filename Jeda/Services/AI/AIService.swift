/**
 * Scope: AIService.swift
 * Purpose: OpenRouter chat completions client with protocol, error types, and core reflection generation.
 */

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

enum AIServiceError: LocalizedError {
    case missingAPIKey
    case emptyResponse
    case invalidPrompt
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            "API key belum dikonfigurasi. Tambahkan OPENROUTER_API_KEY di Secrets.plist."
        case .emptyResponse:
            "Model AI tidak mengembalikan respons."
        case .invalidPrompt:
            "Teks journal kosong."
        case let .decodingFailed(detail):
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
        let configuration = APIConfiguration.openRouter(apiKey: apiKey)
        return AIService(api: APIService(configuration: configuration))
    }

    static func makeForWeeklySummary(keyProvider: AIAPIKeyProviding = BundleAIAPIKeyProvider()) throws -> AIService {
        let apiKey = try keyProvider.apiKey()
        let configuration = APIConfiguration.openRouter(apiKey: apiKey)
        return AIService(api: APIService(configuration: configuration), model: JedaAIConstants.fastAIModel)
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
        Balas dengan 2-3 kalimat yang hangat, non-klinis, dan memvalidasi perasaan user.
        Respons harus bersifat menutup dan menenangkan — jangan ajukan pertanyaan balik, \
        jangan undang kelanjutan percakapan. Akui apa yang user rasakan, lalu berikan perspektif \
        yang menenangkan atau menguatkan sebagai penutup refleksi.
        Jangan diagnosis medis. Gunakan Bahasa Indonesia.
        """

        if let detectedEmotion {
            systemPrompt += "\nEmosi terdeteksi dari entry: \(detectedEmotion)."
        }

        let messages: [ChatMessage] = [
            .init(role: .system, content: systemPrompt),
            .init(role: .user, content: trimmed)
        ]

        return try await complete(messages: messages, temperature: 0.7, maxTokens: 256)
    }
}
