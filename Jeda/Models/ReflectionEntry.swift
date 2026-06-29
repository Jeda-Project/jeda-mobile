/**
 * Scope: ReflectionEntry.swift
 * Purpose: Data model representing a single saved reflection session.
 */

import Foundation

struct ReflectionEntry: Identifiable, Hashable, Codable {
    let id: UUID
    let date: Date
    let journalExcerpt: String
    let mood: JedaMood
    let emotion: Emotion
    let confidence: Double
    let reflectionQuestion: String
    let reflectionText: String?
    let aiReplyText: String?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        journalExcerpt: String,
        mood: JedaMood,
        emotion: Emotion,
        confidence: Double,
        reflectionQuestion: String,
        reflectionText: String? = nil,
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

    var formattedDate: String {
        let locale = Locale(identifier: "id_ID")
        let datePart = date.formatted(.dateTime.day().month(.wide).year().locale(locale))
        let timePart = date.formatted(.dateTime.hour().minute().locale(locale))
        return "\(datePart) pukul \(timePart) WIB"
    }
}
