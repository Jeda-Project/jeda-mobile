/**
 * Scope: SafetyAPIEndpoint.swift
 * Purpose: Endpoint definitions and DTOs for the backend safety scan and resources API.
 */

import Foundation

struct SafetyScanRequest: Encodable {
    let text: String
}

struct SafetyResourcesEnvelope: Decodable {
    let resources: [SafetyResourceDTO]
}

enum SafetyAPIEndpoint: APIEndpoint {
    case scan(SafetyScanRequest)
    case resources

    var path: String {
        switch self {
        case .scan:
            "api/safety/scan"
        case .resources:
            "api/safety/resources"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .scan:
            .post
        case .resources:
            .get
        }
    }

    var body: Data? {
        guard case let .scan(request) = self else { return nil }
        return try? encodeBody(request)
    }
}
