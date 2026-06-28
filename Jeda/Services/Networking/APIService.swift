//
//  APIService.swift
//  Jeda
//

import Foundation

/// Client HTTP generik. Inject `URLSession` untuk unit test.
final class APIService {
    private let configuration: APIConfiguration
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        configuration: APIConfiguration,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.configuration = configuration
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    // MARK: - Endpoint-based API (recommended)

    func request<T: Decodable>(
        _ endpoint: some APIEndpoint,
        responseType: T.Type,
        acceptableStatusCodes: Set<Int> = Set(200...299)
    ) async throws -> T {
        let request = try APIRequestBuilder(configuration: configuration, endpoint: endpoint).build()
        let data = try await perform(request, acceptableStatusCodes: acceptableStatusCodes)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error.localizedDescription)
        }
    }

    /// Untuk DELETE / PUT tanpa response body (204 No Content).
    func requestVoid(
        _ endpoint: some APIEndpoint,
        acceptableStatusCodes: Set<Int> = Set(200...299)
    ) async throws {
        let request = try APIRequestBuilder(configuration: configuration, endpoint: endpoint).build()
        _ = try await perform(request, acceptableStatusCodes: acceptableStatusCodes)
    }

    // MARK: - Builder-based API (flexible)

    func request<T: Decodable>(
        builder: APIRequestBuilder,
        responseType: T.Type,
        acceptableStatusCodes: Set<Int> = Set(200...299)
    ) async throws -> T {
        let request = try builder.build()
        let data = try await perform(request, acceptableStatusCodes: acceptableStatusCodes)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error.localizedDescription)
        }
    }

    func requestVoid(
        builder: APIRequestBuilder,
        acceptableStatusCodes: Set<Int> = Set(200...299)
    ) async throws {
        let request = try builder.build()
        _ = try await perform(request, acceptableStatusCodes: acceptableStatusCodes)
    }

    /// Raw request jika perlu custom handling.
    func data(for request: URLRequest, acceptableStatusCodes: Set<Int> = Set(200...299)) async throws -> Data {
        try await perform(request, acceptableStatusCodes: acceptableStatusCodes)
    }

    // MARK: - Private

    private func perform(_ request: URLRequest, acceptableStatusCodes: Set<Int>) async throws -> Data {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard acceptableStatusCodes.contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: message)
        }

        if data.isEmpty, httpResponse.statusCode == 204 {
            return Data()
        }

        return data
    }
}

extension APIService {
    /// Shortcut builder dengan base URL dari configuration.
    func builder(path: String = "", method: HTTPMethod = .get) -> APIRequestBuilder {
        APIRequestBuilder(
            baseURL: configuration.baseURL,
            path: path,
            method: method,
            headers: configuration.defaultHeaders,
            timeoutInterval: configuration.timeoutInterval
        )
    }
}
