/**
 * Scope: EntryRepository.swift
 * Purpose: Syncs reflection entries with the backend while preserving mobile-only fields via a local sidecar.
 */

import Foundation

struct EntrySaveResult: Sendable {
    let entry: ReflectionEntry
    let safety: SafetyDTO
}

protocol EntryRepositing: Sendable {
    func saveReflection(_ entry: ReflectionEntry) async throws -> EntrySaveResult
    func fetchReflections(limit: Int, before: Date?) async throws -> [ReflectionEntry]
    func deleteReflection(id: UUID) async throws
}

struct EntryRepository: EntryRepositing {
    private let api: APIService
    private let enrichmentStore: any ReflectionEnrichmentPersisting

    init(api: APIService, enrichmentStore: any ReflectionEnrichmentPersisting) {
        self.api = api
        self.enrichmentStore = enrichmentStore
    }

    func saveReflection(_ entry: ReflectionEntry) async throws -> EntrySaveResult {
        let request = CreateEntryRequest(
            id: entry.id.uuidString,
            content: entry.journalExcerpt,
            sentimentScore: Self.sentimentScore(for: entry.emotion),
            reflectedPhrase: entry.aiReplyText,
            openQuestion: entry.reflectionQuestion,
            createdAt: BackendDateFormat.dateTimeString(from: entry.date)
        )

        let envelope = try await api.request(
            EntriesAPIEndpoint.create(request),
            responseType: CreateEntryEnvelope.self
        )

        persistEnrichment(for: entry)
        let saved = reflectionEntry(from: envelope.entry)
        return EntrySaveResult(entry: saved, safety: envelope.safety)
    }

    func fetchReflections(limit: Int, before: Date? = nil) async throws -> [ReflectionEntry] {
        let envelope = try await api.request(
            EntriesAPIEndpoint.list(from: nil, to: before, limit: limit),
            responseType: EntriesListEnvelope.self
        )
        return envelope.entries.map(reflectionEntry(from:))
    }

    func deleteReflection(id: UUID) async throws {
        try await api.requestVoid(EntriesAPIEndpoint.delete(id: id.uuidString))
        enrichmentStore.remove(id: id)
    }

    private func persistEnrichment(for entry: ReflectionEntry) {
        let enrichment = ReflectionEnrichment(
            mood: entry.mood,
            emotion: entry.emotion,
            confidence: entry.confidence,
            reflectionText: entry.reflectionText
        )
        enrichmentStore.store(enrichment, for: entry.id)
    }

    private func reflectionEntry(from dto: EntryDTO) -> ReflectionEntry {
        let id = UUID(uuidString: dto.id) ?? UUID()
        let date = BackendDateFormat.date(fromDateTime: dto.createdAt) ?? Date()
        let enrichment = enrichmentStore.enrichment(for: id)

        return ReflectionEntry(
            id: id,
            date: date,
            journalExcerpt: dto.content,
            mood: enrichment?.mood ?? Self.fallbackMood(for: dto.sentimentScore),
            emotion: enrichment?.emotion ?? Self.fallbackEmotion(for: dto.sentimentScore),
            confidence: enrichment?.confidence ?? 0,
            reflectionQuestion: dto.openQuestion ?? "",
            reflectionText: enrichment?.reflectionText ?? dto.reflectedPhrase ?? "",
            aiReplyText: dto.reflectedPhrase
        )
    }

    private static func sentimentScore(for emotion: Emotion) -> Double {
        switch emotion {
        case .happy: 1
        case .love: 0.8
        case .fear: -0.6
        case .anger: -0.9
        case .sadness: -1
        }
    }

    private static func fallbackEmotion(for sentimentScore: Double?) -> Emotion {
        guard let sentimentScore else { return .sadness }
        if sentimentScore > 0.1 { return .happy }
        if sentimentScore < -0.1 { return .sadness }
        return .fear
    }

    private static func fallbackMood(for sentimentScore: Double?) -> JedaMood {
        guard let sentimentScore else { return .neutral }
        if sentimentScore > 0.5 { return .light }
        if sentimentScore > 0.1 { return .okay }
        if sentimentScore < -0.5 { return .heavy }
        if sentimentScore < -0.1 { return .low }
        return .neutral
    }
}
