/**
 * Scope: ReflectionStore.swift
 * Purpose: Shared store for kontemplasi and reflection entries with disk persistence.
 */
import Combine
import Foundation

final class ReflectionStore: ObservableObject {
    @Published private(set) var entries: [ReflectionEntry] = []
    @Published private(set) var pendingReflection: PendingReflection?
    @Published private(set) var completedSaveCount = 0
    @Published private(set) var isSyncing = false
    @Published private(set) var isHistorySyncing = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var hasMore = true
    @Published private(set) var syncErrorMessage: String?
    @Published private(set) var lastServerSafety: SafetyDTO?
    @Published private(set) var crisisDetected = false
    @Published private(set) var isDeletingID: UUID?
    private static let pageSize = 10
    private let persistence: ReflectionPersisting
    private let repository: (any EntryRepositing)?
    private static var pendingReflectionURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("pending_reflection.json")
    }

    var entriesFingerprint: String {
        entries.map { "\($0.id.uuidString)-\($0.date.timeIntervalSince1970)" }.joined(separator: "|")
    }

    init(
        persistence: ReflectionPersisting = FileReflectionPersistence(),
        repository: (any EntryRepositing)? = nil
    ) {
        self.persistence = persistence
        self.repository = repository
        entries = (try? persistence.loadEntries()) ?? []
        pendingReflection = Self.loadPendingFromDisk()
        if repository != nil { Task { await refreshFromBackend() } }
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
            let remote = try await repository.fetchReflections(limit: Self.pageSize, before: nil)
            entries = remote
            hasMore = remote.count >= Self.pageSize
            persistEntries()
        } catch {
            syncErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func fetchAllForHistory(limit: Int) async {
        guard let repository else { return }
        isHistorySyncing = true
        syncErrorMessage = nil
        defer { isHistorySyncing = false }
        do {
            let remote = try await repository.fetchReflections(limit: limit, before: nil)
            let existingIDs = Set(entries.map(\.id))
            let newEntries = remote.filter { !existingIDs.contains($0.id) }
            if !newEntries.isEmpty {
                entries = (entries + newEntries).sorted { $0.date > $1.date }
                persistEntries()
            }
        } catch {
            syncErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func loadNextPage() async {
        guard let repository, hasMore, !isLoadingMore, !isSyncing else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        let cursor = entries.last?.date
        do {
            let page = try await repository.fetchReflections(limit: Self.pageSize, before: cursor)
            let existingIDs = Set(entries.map(\.id))
            let newEntries = page.filter { !existingIDs.contains($0.id) }
            entries.append(contentsOf: newEntries)
            hasMore = page.count >= Self.pageSize
            persistEntries()
        } catch {
            syncErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func delete(_ entry: ReflectionEntry) async {
        guard let repository else {
            entries.removeAll { $0.id == entry.id }
            persistEntries()
            return
        }
        isDeletingID = entry.id
        defer { isDeletingID = nil }
        do {
            try await repository.deleteReflection(id: entry.id)
            entries.removeAll { $0.id == entry.id }
            persistEntries()
        } catch {
            syncErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
    func setPending(_ pending: PendingReflection) {
        pendingReflection = pending
        Self.savePendingToDisk(pending)
    }
    func clearPending() {
        pendingReflection = nil
        Self.deletePendingFromDisk()
    }
    private func pushEntry(_ entry: ReflectionEntry, using repository: any EntryRepositing) async {
        isSyncing = true
        syncErrorMessage = nil
        defer { isSyncing = false }
        do {
            let result = try await repository.saveReflection(entry)
            lastServerSafety = result.safety
            if result.safety.flagged { crisisDetected = true }
        } catch {
            syncErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
    func clearCrisisDetected() { crisisDetected = false }
    private func persistEntries() { try? persistence.saveEntries(entries) }
    private static func savePendingToDisk(_ pending: PendingReflection) {
        guard let data = try? JSONEncoder().encode(pending) else { return }
        let url = pendingReflectionURL
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? data.write(to: url, options: .atomic)
    }
    private static func loadPendingFromDisk() -> PendingReflection? {
        guard let data = try? Data(contentsOf: pendingReflectionURL) else { return nil }
        return try? JSONDecoder().decode(PendingReflection.self, from: data)
    }
    private static func deletePendingFromDisk() { try? FileManager.default.removeItem(at: pendingReflectionURL) }
}
