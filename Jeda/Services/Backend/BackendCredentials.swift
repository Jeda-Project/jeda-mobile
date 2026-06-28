/**
 * Scope: BackendCredentials.swift
 * Purpose: Supplies the Jeda backend base URL and Bearer token from Secrets.plist or environment.
 */

import Foundation

struct BackendCredentials: Sendable {
    let baseURL: URL
    let token: String
}

enum BackendCredentialsError: LocalizedError, Sendable {
    case missingBaseURL
    case invalidBaseURL(String)
    case missingToken

    var errorDescription: String? {
        switch self {
        case .missingBaseURL:
            "Base URL backend belum dikonfigurasi. Tambahkan JEDA_API_BASE_URL di Secrets.plist."
        case .invalidBaseURL(let value):
            "Base URL backend tidak valid: \(value)"
        case .missingToken:
            "Token backend belum dikonfigurasi. Tambahkan JEDA_API_TOKEN di Secrets.plist."
        }
    }
}

protocol BackendCredentialsProviding: Sendable {
    func credentials() throws -> BackendCredentials
}

struct BundleBackendCredentialsProvider: BackendCredentialsProviding {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func credentials() throws -> BackendCredentials {
        guard let rawBaseURL = value(for: "JEDA_API_BASE_URL") else {
            throw BackendCredentialsError.missingBaseURL
        }

        guard let baseURL = URL(string: rawBaseURL) else {
            throw BackendCredentialsError.invalidBaseURL(rawBaseURL)
        }

        guard let token = value(for: "JEDA_API_TOKEN") else {
            throw BackendCredentialsError.missingToken
        }

        return BackendCredentials(baseURL: baseURL, token: token)
    }

    private func value(for key: String) -> String? {
        if let envValue = ProcessInfo.processInfo.environment[key], !envValue.isEmpty {
            return envValue
        }

        guard let url = bundle.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let value = plist[key] as? String,
              !value.isEmpty
        else {
            return nil
        }

        return value
    }
}
