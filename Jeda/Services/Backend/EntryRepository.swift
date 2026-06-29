/**
 * Scope: EntryRepository.swift
 * Purpose: Syncs reflection entries with the backend, reading emotion/mood/confidence directly from server responses.
 */

import Foundation

struct EntrySaveResult {
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

    init(api: APIService) {
        self.api = api
    }

    func saveReflection(_ entry: ReflectionEntry) async throws -> EntrySaveResult {
        let request = CreateEntryRequest(
            id: entry.id.uuidString,
            content: entry.journalExcerpt,
            sentimentScore: Self.sentimentScore(for: entry.emotion),
            reflectedPhrase: entry.aiReplyText,
            openQuestion: entry.reflectionQuestion,
            reflectionText: entry.reflectionText?.isEmpty == false ? entry.reflectionText : nil,
            emotion: entry.emotion.rawValue,
            mood: Self.moodName(for: entry.mood),
            confidence: entry.confidence,
            createdAt: BackendDateFormat.dateTimeString(from: entry.date)
        )

        let envelope = try await api.request(
            EntriesAPIEndpoint.create(request),
            responseType: CreateEntryEnvelope.self
        )

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
    }

    private func reflectionEntry(from dto: EntryDTO) -> ReflectionEntry {
        let id = UUID(uuidString: dto.id) ?? UUID()
        let date = BackendDateFormat.date(fromDateTime: dto.createdAt) ?? Date()

        return ReflectionEntry(
            id: id,
            date: date,
            journalExcerpt: dto.content,
            mood: Self.mood(from: dto) ?? Self.fallbackMood(for: dto.sentimentScore),
            emotion: Self.emotion(from: dto) ?? Self.fallbackEmotion(for: dto.sentimentScore),
            confidence: dto.confidence ?? 0,
            reflectionQuestion: dto.openQuestion ?? "",
            reflectionText: dto.reflectionText,
            aiReplyText: dto.reflectedPhrase
        )
    }

    private static func mood(from dto: EntryDTO) -> JedaMood? {
        guard let name = dto.mood else { return nil }
        switch name {
        case "heavy": return .heavy
        case "low": return .low
        case "neutral": return .neutral
        case "okay": return .okay
        case "light": return .light
        default: return nil
        }
    }

    private static func moodName(for mood: JedaMood) -> String {
        switch mood {
        case .heavy: "heavy"
        case .low: "low"
        case .neutral: "neutral"
        case .okay: "okay"
        case .light: "light"
        }
    }

    private static func emotion(from dto: EntryDTO) -> Emotion? {
        dto.emotion.flatMap { Emotion(rawValue: $0) }
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
