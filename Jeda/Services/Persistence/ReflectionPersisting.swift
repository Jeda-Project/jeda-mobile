/**
 * Scope: ReflectionPersisting.swift
 * Purpose: Protocol for persisting check-in and reflection entries to disk.
 */

import Foundation

protocol ReflectionPersisting: Sendable {
    func loadEntries() throws -> [ReflectionEntry]
    func saveEntries(_ entries: [ReflectionEntry]) throws
}

enum ReflectionPersistenceError: LocalizedError, Sendable {
    case encodingFailed
    case writeFailed(String)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            "Gagal menyimpan data check-in."
        case .writeFailed(let detail):
            "Gagal menulis data check-in: \(detail)"
        }
    }
}
