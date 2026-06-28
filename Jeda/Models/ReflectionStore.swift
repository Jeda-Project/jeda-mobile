/**
 * Scope: ReflectionStore.swift
 * Purpose: In-memory store for reflection entries, shared across tabs via Environment.
 */

import SwiftUI
import Combine

@MainActor
final class ReflectionStore: ObservableObject {
    @Published private(set) var entries: [ReflectionEntry] = []

    func add(_ entry: ReflectionEntry) {
        entries.insert(entry, at: 0)
    }
}

private struct ReflectionStoreKey: EnvironmentKey {
    static let defaultValue = ReflectionStore()
}

extension EnvironmentValues {
    var reflectionStore: ReflectionStore {
        get { self[ReflectionStoreKey.self] }
        set { self[ReflectionStoreKey.self] = newValue }
    }
}
