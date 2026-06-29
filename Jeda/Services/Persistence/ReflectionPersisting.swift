/**
 * Scope: ReflectionPersisting.swift
 * Purpose: Protocol for persisting kontemplasi and reflection entries to disk.
 */

import Foundation

protocol ReflectionPersisting: Sendable {
    func loadEntries() throws -> [ReflectionEntry]
    func saveEntries(_ entries: [ReflectionEntry]) throws
}

enum ReflectionPersistenceError: LocalizedError {
    case encodingFailed
    case writeFailed(String)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            "Gagal menyimpan data kontemplasi."
        case let .writeFailed(detail):
            "Gagal menulis data kontemplasi: \(detail)"
        }
    }
}
