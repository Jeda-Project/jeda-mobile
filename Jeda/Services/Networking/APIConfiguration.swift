//
//  APIConfiguration.swift
//  Jeda
//

import Foundation

struct APIConfiguration: Sendable {
    let baseURL: URL
    var defaultHeaders: [String: String]
    var timeoutInterval: TimeInterval

    init(
        baseURL: URL,
        defaultHeaders: [String: String] = ["Content-Type": "application/json"],
        timeoutInterval: TimeInterval = 30
    ) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
        self.timeoutInterval = timeoutInterval
    }
}

extension APIConfiguration {
    /// Jeda backend dengan Bearer token statis (single-user MVP).
    static func backend(baseURL: URL, token: String, timeoutInterval: TimeInterval = 30) -> APIConfiguration {
        APIConfiguration(
            baseURL: baseURL,
            defaultHeaders: [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(token)",
            ],
            timeoutInterval: timeoutInterval
        )
    }

    /// OpenAI chat completions API.
    static func openAI(apiKey: String, timeoutInterval: TimeInterval = 60) -> APIConfiguration {
        APIConfiguration(
            baseURL: JedaAIConstants.baseURL,
            defaultHeaders: [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(apiKey)",
            ],
            timeoutInterval: timeoutInterval
        )
    }
}
