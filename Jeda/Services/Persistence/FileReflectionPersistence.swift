/**
 * Scope: FileReflectionPersistence.swift
 * Purpose: JSON file persistence for reflection entries in Application Support.
 */

import Foundation

final class FileReflectionPersistence: ReflectionPersisting, @unchecked Sendable {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        fileManager: FileManager = .default,
        filename: String = "reflections.json"
    ) {
        let directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("Jeda", isDirectory: true)
            ?? fileManager.temporaryDirectory.appendingPathComponent("Jeda", isDirectory: true)

        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        fileURL = directory.appendingPathComponent(filename)
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func loadEntries() throws -> [ReflectionEntry] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        guard !data.isEmpty else { return [] }
        return try decoder.decode([ReflectionEntry].self, from: data)
    }

    func saveEntries(_ entries: [ReflectionEntry]) throws {
        let data = try encoder.encode(entries)
        guard !data.isEmpty else {
            throw ReflectionPersistenceError.encodingFailed
        }

        do {
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            throw ReflectionPersistenceError.writeFailed(error.localizedDescription)
        }
    }
}
