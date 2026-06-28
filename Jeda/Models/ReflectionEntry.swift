/**
 * Scope: ReflectionEntry.swift
 * Purpose: Data model representing a single saved reflection session.
 */

import Foundation

struct ReflectionEntry: Identifiable, Hashable, Sendable {
    let id: UUID
    let date: Date
    let journalExcerpt: String
    let reflectionQuestion: String
    let reflectionText: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        journalExcerpt: String,
        reflectionQuestion: String,
        reflectionText: String
    ) {
        self.id = id
        self.date = date
        self.journalExcerpt = journalExcerpt
        self.reflectionQuestion = reflectionQuestion
        self.reflectionText = reflectionText
    }
}
