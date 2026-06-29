/**
 * Scope: ChatCompletionModels.swift
 * Purpose: Codable models for OpenAI-compatible chat completion request and response payloads.
 */

import Foundation

struct ChatMessage: Codable, Equatable {
    let role: Role
    let content: String

    enum Role: String, Codable {
        case system
        case user
        case assistant
    }
}

struct ChatCompletionResponseFormat: Encodable {
    let type: String

    static let jsonObject = ChatCompletionResponseFormat(type: "json_object")
}

struct ChatCompletionRequest: Encodable {
    let model: String
    let messages: [ChatMessage]
    var temperature: Double?
    var maxTokens: Int?
    var responseFormat: ChatCompletionResponseFormat?

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case maxTokens = "max_tokens"
        case responseFormat = "response_format"
    }
}

struct ChatCompletionResponse: Decodable {
    let choices: [ChatCompletionChoice]

    var firstContent: String? {
        choices.first?.message.content
    }
}

struct ChatCompletionChoice: Decodable {
    let message: ChatMessage
}

struct ChatCompletionErrorResponse: Decodable {
    struct Detail: Decodable {
        let message: String?
    }

    let error: Detail?
}
