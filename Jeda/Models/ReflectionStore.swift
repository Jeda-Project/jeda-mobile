/**
 * Scope: ReflectionStore.swift
 * Purpose: Shared store for check-in and reflection entries with disk persistence.
 */

import Combine
import Foundation

@MainActor
final class ReflectionStore: ObservableObject {
    @Published private(set) var entries: [ReflectionEntry] = []
    @Published private(set) var pendingReflection: PendingReflection?
    @Published private(set) var completedSaveCount = 0

    private let persistence: ReflectionPersisting

    var entriesFingerprint: String {
        entries
            .map { "\($0.id.uuidString)-\($0.date.timeIntervalSince1970)" }
            .joined(separator: "|")
    }

    init(persistence: ReflectionPersisting = FileReflectionPersistence()) {
        self.persistence = persistence
        entries = (try? persistence.loadEntries()) ?? []
    }

    func add(_ entry: ReflectionEntry) {
        entries.insert(entry, at: 0)
        completedSaveCount += 1
        persistEntries()
    }

    func setPending(_ pending: PendingReflection) {
        pendingReflection = pending
    }

    func clearPending() {
        pendingReflection = nil
    }

    private func persistEntries() {
        try? persistence.saveEntries(entries)
    }
}
