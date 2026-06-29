/**
 * Scope: SummariesAPIEndpoint.swift
 * Purpose: Endpoint definitions and DTOs for the backend weekly summaries API.
 */

import Foundation

struct TopTopicDTO: Codable {
    let topic: String
    let count: Int
}

struct MoodTrendDTO: Codable {
    let day: String
    let score: Double
}

struct SummaryDTO: Codable {
    let id: String
    let weekStart: String
    let topTopics: [TopTopicDTO]
    let moodTrend: [MoodTrendDTO]
    let reliefNote: String?
    let createdAt: String
}

struct CreateSummaryRequest: Encodable {
    let id: String?
    let weekStart: String
    let topTopics: [TopTopicDTO]
    let moodTrend: [MoodTrendDTO]
    let reliefNote: String?
}

struct SummaryEnvelope: Decodable {
    let summary: SummaryDTO
}

struct SummariesListEnvelope: Decodable {
    let summaries: [SummaryDTO]
}

enum SummariesAPIEndpoint: APIEndpoint {
    case create(CreateSummaryRequest)
    case list(limit: Int)

    var path: String {
        "api/summaries"
    }

    var method: HTTPMethod {
        switch self {
        case .create:
            .post
        case .list:
            .get
        }
    }

    var queryItems: [URLQueryItem]? {
        guard case let .list(limit) = self else { return nil }
        return [URLQueryItem(name: "limit", value: String(limit))]
    }

    var body: Data? {
        guard case let .create(request) = self else { return nil }
        return try? encodeBody(request)
    }
}
