/**
 * Scope: SafetyAPIEndpoint.swift
 * Purpose: Endpoint definitions and DTOs for the backend safety scan and resources API.
 */

import Foundation

struct SafetyScanRequest: Encodable, Sendable {
    let text: String
}

struct SafetyResourcesEnvelope: Decodable, Sendable {
    let resources: [SafetyResourceDTO]
}

enum SafetyAPIEndpoint: APIEndpoint {
    case scan(SafetyScanRequest)
    case resources

    var path: String {
        switch self {
        case .scan:
            return "api/safety/scan"
        case .resources:
            return "api/safety/resources"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .scan:
            return .post
        case .resources:
            return .get
        }
    }

    var body: Data? {
        guard case let .scan(request) = self else { return nil }
        return try? encodeBody(request)
    }
}
