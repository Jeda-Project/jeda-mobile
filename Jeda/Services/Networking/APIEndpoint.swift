//
//  APIEndpoint.swift
//  Jeda
//
//  Best practice: definisikan setiap domain API sebagai enum yang conform ke `APIEndpoint`.
//

import Foundation

/// Kontrak untuk semua endpoint. Setiap feature/domain punya enum sendiri.
protocol APIEndpoint: Sendable {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
}

extension APIEndpoint {
    var headers: [String: String] { [:] }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }
}

extension APIEndpoint {
    /// Encode body dari model `Encodable` — dipakai di enum endpoint.
    func encodeBody<T: Encodable>(_ value: T, encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        do {
            return try encoder.encode(value)
        } catch {
            throw APIError.encodingFailed
        }
    }
}

extension APIRequestBuilder {
    /// Buat request langsung dari endpoint definition.
    init(configuration: APIConfiguration, endpoint: some APIEndpoint) throws {
        var mergedHeaders = configuration.defaultHeaders.merging(endpoint.headers) { _, new in new }

        if endpoint.body != nil {
            mergedHeaders["Content-Type"] = "application/json"
        }

        self.init(
            baseURL: configuration.baseURL,
            path: endpoint.path,
            method: endpoint.method,
            headers: mergedHeaders,
            queryItems: endpoint.queryItems ?? [],
            body: endpoint.body,
            timeoutInterval: configuration.timeoutInterval
        )
    }
}
