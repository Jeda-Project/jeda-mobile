/**
 * Scope: EntriesAPIEndpoint.swift
 * Purpose: Endpoint definitions and DTOs for the backend journal entries API.
 */

import Foundation

struct EntryDTO: Codable {
    let id: String
    let content: String
    let sentimentScore: Double?
    let reflectedPhrase: String?
    let openQuestion: String?
    let reflectionText: String?
    let emotion: String?
    let mood: String?
    let confidence: Double?
    let createdAt: String
}

struct CreateEntryRequest: Encodable {
    let id: String?
    let content: String
    let sentimentScore: Double?
    let reflectedPhrase: String?
    let openQuestion: String?
    let reflectionText: String?
    let emotion: String?
    let mood: String?
    let confidence: Double?
    let createdAt: String?
}

struct SafetyMatchDTO: Codable {
    let ruleId: String
    let category: String
    let severity: String
}

struct SafetyResourceDTO: Codable {
    let name: String
    let description: String
    let phone: String?
    let url: String?
    let available: String
}

struct SafetyDTO: Codable {
    let flagged: Bool
    let severity: String
    let matches: [SafetyMatchDTO]
    let rulesVersion: String
    let resources: [SafetyResourceDTO]
}

struct CreateEntryEnvelope: Decodable {
    let entry: EntryDTO
    let safety: SafetyDTO
}

struct EntryEnvelope: Decodable {
    let entry: EntryDTO
}

struct EntriesListEnvelope: Decodable {
    let entries: [EntryDTO]
}

enum EntriesAPIEndpoint: APIEndpoint {
    case create(CreateEntryRequest)
    case list(from: Date?, to: Date?, limit: Int)
    case get(id: String)
    case delete(id: String)

    var path: String {
        switch self {
        case .create, .list:
            "api/entries"
        case let .get(id), let .delete(id):
            "api/entries/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .create:
            .post
        case .list, .get:
            .get
        case .delete:
            .delete
        }
    }

    var queryItems: [URLQueryItem]? {
        guard case let .list(from, to, limit) = self else { return nil }
        var items: [URLQueryItem] = [URLQueryItem(name: "limit", value: String(limit))]
        if let from {
            items.append(URLQueryItem(name: "from", value: BackendDateFormat.dateTimeString(from: from)))
        }
        if let to {
            items.append(URLQueryItem(name: "to", value: BackendDateFormat.dateTimeString(from: to)))
        }
        return items
    }

    var body: Data? {
        guard case let .create(request) = self else { return nil }
        do {
            return try encodeBody(request)
        } catch {
            assertionFailure("EntriesAPIEndpoint: failed to encode request body — \(error)")
            return nil
        }
    }
}
