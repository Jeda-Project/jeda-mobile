/**
 * Scope: AIAPIKeyProviding.swift
 * Purpose: Protocol and implementation for providing the AI service API key securely.
 */

import Foundation

protocol AIAPIKeyProviding: Sendable {
    func apiKey() throws -> String
}

/// Reads `OPENAI_API_KEY` from Secrets.plist (gitignored) or environment variable.
struct BundleAIAPIKeyProvider: AIAPIKeyProviding {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func apiKey() throws -> String {
        for envName in ["OPENROUTER_API_KEY", "OPENAI_API_KEY", "DICODING_AI_API_KEY"] {
            if let envKey = ProcessInfo.processInfo.environment[envName], !envKey.isEmpty {
                return envKey
            }
        }

        if let url = bundle.url(forResource: "Secrets", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] {
            for keyName in ["OPENROUTER_API_KEY", "OPENAI_API_KEY", "DICODING_AI_API_KEY"] {
                if let key = plist[keyName] as? String, !key.isEmpty {
                    return key
                }
            }
        }

        throw AIServiceError.missingAPIKey
    }
}
