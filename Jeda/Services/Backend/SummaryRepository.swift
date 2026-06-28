/**
 * Scope: SummaryRepository.swift
 * Purpose: Pushes and fetches AI-generated weekly summaries to and from the backend.
 */

import Foundation

protocol SummaryRepositing: Sendable {
    func pushWeeklySummary(_ summary: WeekSummary) async throws
    func fetchSummaries(limit: Int) async throws -> [SummaryDTO]
}

struct SummaryRepository: SummaryRepositing {
    private let api: APIService

    init(api: APIService) {
        self.api = api
    }

    func pushWeeklySummary(_ summary: WeekSummary) async throws {
        let request = CreateSummaryRequest(
            id: summary.id.uuidString,
            weekStart: BackendDateFormat.dayString(from: summary.startDate),
            topTopics: summary.topicChartItems.map { TopTopicDTO(topic: $0.topic, count: $0.count) },
            moodTrend: summary.moodTrendPoints.map { MoodTrendDTO(day: $0.day, score: $0.score) },
            reliefNote: summary.quoteOfWeek ?? summary.summaryPhrase
        )

        _ = try await api.request(
            SummariesAPIEndpoint.create(request),
            responseType: SummaryEnvelope.self
        )
    }

    func fetchSummaries(limit: Int) async throws -> [SummaryDTO] {
        let envelope = try await api.request(
            SummariesAPIEndpoint.list(limit: limit),
            responseType: SummariesListEnvelope.self
        )
        return envelope.summaries
    }
}
