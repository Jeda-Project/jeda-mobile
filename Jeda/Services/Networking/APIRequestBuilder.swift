/**
 * Scope: APIRequestBuilder.swift
 * Purpose: Builds URLRequest instances from APIEndpoint descriptors.
 */

import Foundation

struct APIRequestBuilder {
    private let baseURL: URL
    private var path: String
    private var method: HTTPMethod
    private var headers: [String: String]
    private var queryItems: [URLQueryItem]
    private var body: Data?
    private var timeoutInterval: TimeInterval

    init(
        baseURL: URL,
        path: String = "",
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        queryItems: [URLQueryItem] = [],
        body: Data? = nil,
        timeoutInterval: TimeInterval = 30
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
        self.timeoutInterval = timeoutInterval
    }

    func path(_ path: String) -> APIRequestBuilder {
        var copy = self
        copy.path = path
        return copy
    }

    func method(_ method: HTTPMethod) -> APIRequestBuilder {
        var copy = self
        copy.method = method
        return copy
    }

    func header(_ field: String, _ value: String) -> APIRequestBuilder {
        var copy = self
        copy.headers[field] = value
        return copy
    }

    func headers(_ headers: [String: String]) -> APIRequestBuilder {
        var copy = self
        copy.headers.merge(headers) { _, new in new }
        return copy
    }

    func query(_ items: [URLQueryItem]) -> APIRequestBuilder {
        var copy = self
        copy.queryItems = items
        return copy
    }

    func query(name: String, value: String) -> APIRequestBuilder {
        query([URLQueryItem(name: name, value: value)])
    }

    func body(_ data: Data?) -> APIRequestBuilder {
        var copy = self
        copy.body = data
        return copy
    }

    func body(_ value: some Encodable, encoder: JSONEncoder = JSONEncoder()) throws -> APIRequestBuilder {
        var copy = self
        do {
            copy.body = try encoder.encode(value)
        } catch {
            throw APIError.encodingFailed
        }
        return copy
    }

    func timeout(_ interval: TimeInterval) -> APIRequestBuilder {
        var copy = self
        copy.timeoutInterval = interval
        return copy
    }

    func build() throws -> URLRequest {
        let normalizedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        guard var url = URL(string: normalizedPath, relativeTo: baseURL)?.absoluteURL else {
            throw APIError.invalidURL
        }

        if !queryItems.isEmpty {
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw APIError.invalidURL
            }
            components.queryItems = queryItems
            guard let composedURL = components.url else {
                throw APIError.invalidURL
            }
            url = composedURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeoutInterval
        request.httpBody = body

        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }

        return request
    }
}
