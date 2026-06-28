/**
 * Scope: ReflectionStore.swift
 * Purpose: Shared store for check-in and reflection entries with disk persistence.
 */

import Combine
import Foundation

final class ReflectionStore: ObservableObject {
    @Published private(set) var entries: [ReflectionEntry] = []
    @Published private(set) var pendingReflection: PendingReflection?
    @Published private(set) var completedSaveCount = 0
    @Published private(set) var isSyncing = false
    @Published private(set) var syncErrorMessage: String?
    @Published private(set) var lastServerSafety: SafetyDTO?

    private let persistence: ReflectionPersisting
    private let repository: (any EntryRepositing)?

    var entriesFingerprint: String {
        entries
            .map { "\($0.id.uuidString)-\($0.date.timeIntervalSince1970)" }
            .joined(separator: "|")
    }

    init(
        persistence: ReflectionPersisting = FileReflectionPersistence(),
        repository: (any EntryRepositing)? = nil
    ) {
        self.persistence = persistence
        self.repository = repository
        entries = (try? persistence.loadEntries()) ?? []
        if repository != nil {
            Task { await refreshFromBackend() }
        }
    }

    func add(_ entry: ReflectionEntry) {
        entries.insert(entry, at: 0)
        completedSaveCount += 1
        persistEntries()

        guard let repository else { return }
        Task { await pushEntry(entry, using: repository) }
    }

    func refreshFromBackend() async {
        guard let repository else { return }
        isSyncing = true
        syncErrorMessage = nil
        defer { isSyncing = false }

        do {
            let remote = try await repository.fetchReflections(limit: 200)
            entries = remote
            persistEntries()
        } catch {
            syncErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func delete(_ entry: ReflectionEntry) async {
        entries.removeAll { $0.id == entry.id }
        persistEntries()

        guard let repository else { return }
        do {
            try await repository.deleteReflection(id: entry.id)
        } catch {
            syncErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func setPending(_ pending: PendingReflection) {
        pendingReflection = pending
    }

    func clearPending() {
        pendingReflection = nil
    }

    private func pushEntry(_ entry: ReflectionEntry, using repository: any EntryRepositing) async {
        isSyncing = true
        syncErrorMessage = nil
        defer { isSyncing = false }

        do {
            let result = try await repository.saveReflection(entry)
            lastServerSafety = result.safety
        } catch {
            syncErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    private func persistEntries() {
        try? persistence.saveEntries(entries)
    }
}
