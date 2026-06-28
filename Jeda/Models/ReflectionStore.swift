/**
 * Scope: ReflectionStore.swift
 * Purpose: In-memory store for reflection entries, shared across tabs via Environment.
 */

import Combine

@MainActor
final class ReflectionStore: ObservableObject {
    @Published private(set) var entries: [ReflectionEntry] = []
    @Published private(set) var pendingReflection: PendingReflection?
    @Published private(set) var completedSaveCount = 0

    func add(_ entry: ReflectionEntry) {
        entries.insert(entry, at: 0)
        completedSaveCount += 1
    }

    func setPending(_ pending: PendingReflection) {
        pendingReflection = pending
    }

    func clearPending() {
        pendingReflection = nil
    }
}
