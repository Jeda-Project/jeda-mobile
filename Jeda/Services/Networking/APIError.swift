//
//  APIError.swift
//  Jeda
//

import Foundation

enum APIError: LocalizedError, Sendable {
    case invalidURL
    case invalidResponse
    case encodingFailed
    case noData
    case decodingFailed(String)
    case httpError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL tidak valid"
        case .invalidResponse:
            return "Response server tidak valid"
        case .encodingFailed:
            return "Gagal encode request"
        case .noData:
            return "Tidak ada data dari server"
        case .decodingFailed(let message):
            return "Gagal parse response: \(message)"
        case .httpError(let statusCode, let message):
            return "HTTP \(statusCode): \(message)"
        }
    }
}
