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
        maxTokens: Int?
    ) async throws -> String

    func generateReflection(for journalEntry: String, detectedEmotion: String?) async throws -> String
}

enum AIServiceError: LocalizedError, Sendable {
    case missingAPIKey
    case emptyResponse
    case invalidPrompt

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            "API key OpenAI belum dikonfigurasi. Tambahkan OPENAI_API_KEY di Secrets.plist."
        case .emptyResponse:
            "Model AI tidak mengembalikan respons."
        case .invalidPrompt:
            "Teks journal kosong."
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
        maxTokens: Int? = 512
    ) async throws -> String {
        let request = ChatCompletionRequest(
            model: model,
            messages: messages,
            temperature: temperature,
            maxTokens: maxTokens
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
}
