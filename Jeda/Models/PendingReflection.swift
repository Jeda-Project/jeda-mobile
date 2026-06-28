/**
 * Scope: PendingReflection.swift
 * Purpose: Data model representing a reflection prompt awaiting deeper input.
 */

import Foundation

struct PendingReflection: Identifiable, Hashable, Sendable {
    let id: UUID
    let date: Date
    let journalExcerpt: String
    let mood: JedaMood
    let emotion: Emotion
    let confidence: Double
    let reflectionQuestion: String
    let highlightedPhrase: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        journalExcerpt: String,
        mood: JedaMood,
        emotion: Emotion,
        confidence: Double,
        reflectionQuestion: String,
        highlightedPhrase: String
    ) {
        self.id = id
        self.date = date
        self.journalExcerpt = journalExcerpt
        self.mood = mood
        self.emotion = emotion
        self.confidence = confidence
        self.reflectionQuestion = reflectionQuestion
        self.highlightedPhrase = highlightedPhrase
    }
}
