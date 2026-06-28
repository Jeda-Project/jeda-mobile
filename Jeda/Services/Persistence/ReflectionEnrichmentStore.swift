/**
 * Scope: ReflectionEnrichmentStore.swift
 * Purpose: Local sidecar storing mobile-only reflection fields keyed by entry id for backend round-trips.
 */

import Foundation

struct ReflectionEnrichment: Codable, Sendable {
    let mood: JedaMood
    let emotion: Emotion
    let confidence: Double
    let reflectionText: String
}

protocol ReflectionEnrichmentPersisting: Sendable {
    func enrichment(for id: UUID) -> ReflectionEnrichment?
    func store(_ enrichment: ReflectionEnrichment, for id: UUID)
    func remove(id: UUID)
}

final class ReflectionEnrichmentStore: ReflectionEnrichmentPersisting, @unchecked Sendable {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let lock = NSLock()

    init(
        fileManager: FileManager = .default,
        filename: String = "enrichment.json"
    ) {
        let directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("Jeda", isDirectory: true)
            ?? fileManager.temporaryDirectory.appendingPathComponent("Jeda", isDirectory: true)

        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        fileURL = directory.appendingPathComponent(filename)
        encoder = JSONEncoder()
        decoder = JSONDecoder()
    }

    func enrichment(for id: UUID) -> ReflectionEnrichment? {
        lock.lock()
        defer { lock.unlock() }
        return load()[id.uuidString]
    }

    func store(_ enrichment: ReflectionEnrichment, for id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        var map = load()
        map[id.uuidString] = enrichment
        persist(map)
    }

    func remove(id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        var map = load()
        map.removeValue(forKey: id.uuidString)
        persist(map)
    }

    private func load() -> [String: ReflectionEnrichment] {
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              !data.isEmpty,
              let map = try? decoder.decode([String: ReflectionEnrichment].self, from: data)
        else {
            return [:]
        }
        return map
    }

    private func persist(_ map: [String: ReflectionEnrichment]) {
        guard let data = try? encoder.encode(map) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }
}
