/**
 * Scope: ReflectionEntry.swift
 * Purpose: Data model representing a single saved reflection session.
 */

import Foundation

struct ReflectionEntry: Identifiable, Hashable, Sendable, Codable {
    let id: UUID
    let date: Date
    let journalExcerpt: String
    let mood: JedaMood
    let emotion: Emotion
    let confidence: Double
    let reflectionQuestion: String
    let reflectionText: String
    let aiReplyText: String?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        journalExcerpt: String,
        mood: JedaMood,
        emotion: Emotion,
        confidence: Double,
        reflectionQuestion: String,
        reflectionText: String,
        aiReplyText: String? = nil
    ) {
        self.id = id
        self.date = date
        self.journalExcerpt = journalExcerpt
        self.mood = mood
        self.emotion = emotion
        self.confidence = confidence
        self.reflectionQuestion = reflectionQuestion
        self.reflectionText = reflectionText
        self.aiReplyText = aiReplyText
    }
}
