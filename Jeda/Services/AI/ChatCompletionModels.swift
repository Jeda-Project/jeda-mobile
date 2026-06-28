//
//  ChatCompletionModels.swift
//  Jeda
//
//  OpenAI-compatible chat completion payloads.
//

import Foundation

struct ChatMessage: Codable, Sendable, Equatable {
    let role: Role
    let content: String

    enum Role: String, Codable, Sendable {
        case system
        case user
        case assistant
    }
}

struct ChatCompletionRequest: Encodable, Sendable {
    let model: String
    let messages: [ChatMessage]
    var temperature: Double?
    var maxTokens: Int?

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case maxTokens = "max_tokens"
    }
}

struct ChatCompletionResponse: Decodable, Sendable {
    let choices: [ChatCompletionChoice]

    var firstContent: String? {
        choices.first?.message.content
    }
}

struct ChatCompletionChoice: Decodable, Sendable {
    let message: ChatMessage
}

struct ChatCompletionErrorResponse: Decodable, Sendable {
    struct Detail: Decodable, Sendable {
        let message: String?
    }

    let error: Detail?
}
