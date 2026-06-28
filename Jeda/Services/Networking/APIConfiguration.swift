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
    /// Ganti dengan base URL production/staging sesuai environment.
    static let jeda = APIConfiguration(
        baseURL: URL(string: "https://api.jeda.example.com/v1")!
    )

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
