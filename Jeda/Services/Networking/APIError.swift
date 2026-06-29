/**
 * Scope: APIError.swift
 * Purpose: Defines typed networking errors surfaced by APIService to callers.
 */

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case encodingFailed
    case noData
    case decodingFailed(String)
    case httpError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "URL tidak valid"
        case .invalidResponse:
            "Response server tidak valid"
        case .encodingFailed:
            "Gagal encode request"
        case .noData:
            "Tidak ada data dari server"
        case let .decodingFailed(message):
            "Gagal parse response: \(message)"
        case let .httpError(statusCode, message):
            "HTTP \(statusCode): \(message)"
        }
    }
}
