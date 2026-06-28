//
//  EmotionAPIEndpoint.swift
//  Jeda
//
//  Contoh best practice: satu file per domain/feature untuk endpoint definitions.
//

import Foundation

// MARK: - Request / Response models (dekat dengan endpoint-nya)

struct EmotionAnalysisRequest: Encodable, Sendable {
    let text: String
}

struct EmotionAnalysisResponse: Decodable, Sendable {
    let emotion: String
    let confidence: Double
}

struct UpdateEmotionProfileRequest: Encodable, Sendable {
    let displayName: String
    let preferredLanguage: String
}

// MARK: - Endpoint enum

enum EmotionAPIEndpoint: APIEndpoint {
    case analyze(EmotionAnalysisRequest)
    case history(userId: String, page: Int)
    case profile(userId: String)
    case updateProfile(userId: String, UpdateEmotionProfileRequest)
    case deleteHistory(userId: String, entryId: String)

    var path: String {
        switch self {
        case .analyze:
            return "emotions/analyze"
        case .history(let userId, _):
            return "users/\(userId)/emotions/history"
        case .profile(let userId):
            return "users/\(userId)/profile"
        case .updateProfile(let userId, _):
            return "users/\(userId)/profile"
        case .deleteHistory(let userId, let entryId):
            return "users/\(userId)/emotions/history/\(entryId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .analyze:
            return .post
        case .history, .profile:
            return .get
        case .updateProfile:
            return .put
        case .deleteHistory:
            return .delete
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .history(_, let page):
            return [URLQueryItem(name: "page", value: String(page))]
        default:
            return nil
        }
    }

    var body: Data? {
        switch self {
        case .analyze(let request):
            return try? encodeBody(request)
        case .updateProfile(_, let request):
            return try? encodeBody(request)
        default:
            return nil
        }
    }

    /// Prefer throwing variant saat build request.
    func encodedBody() throws -> Data? {
        switch self {
        case .analyze(let request):
            return try encodeBody(request)
        case .updateProfile(_, let request):
            return try encodeBody(request)
        default:
            return nil
        }
    }
}

// MARK: - Feature-specific service (optional, wraps APIService)

struct EmotionAPIService: Sendable {
    private let api: APIService

    init(api: APIService = .shared) {
        self.api = api
    }

    func analyze(text: String) async throws -> EmotionAnalysisResponse {
        try await api.request(
            EmotionAPIEndpoint.analyze(.init(text: text)),
            responseType: EmotionAnalysisResponse.self
        )
    }

    func fetchHistory(userId: String, page: Int = 1) async throws -> [EmotionAnalysisResponse] {
        try await api.request(
            EmotionAPIEndpoint.history(userId: userId, page: page),
            responseType: [EmotionAnalysisResponse].self
        )
    }

    func updateProfile(userId: String, displayName: String, language: String) async throws {
        try await api.requestVoid(
            EmotionAPIEndpoint.updateProfile(
                userId: userId,
                .init(displayName: displayName, preferredLanguage: language)
            )
        )
    }

    func deleteHistoryEntry(userId: String, entryId: String) async throws {
        try await api.requestVoid(
            EmotionAPIEndpoint.deleteHistory(userId: userId, entryId: entryId)
        )
    }
}
