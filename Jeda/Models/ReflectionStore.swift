/**
 * Scope: ReflectionStore.swift
 * Purpose: In-memory store for reflection entries, shared across tabs via Environment.
 */

import Combine

@MainActor
final class ReflectionStore: ObservableObject {
    @Published private(set) var entries: [ReflectionEntry] = []

    func add(_ entry: ReflectionEntry) {
        entries.insert(entry, at: 0)
    }
}
