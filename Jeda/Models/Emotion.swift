/**
 * Scope: Emotion.swift
 * Purpose: Defines the Emotion enum with all IndoNLU EmoT labels used by the on-device classifier.
 */

import Foundation

enum Emotion: String, CaseIterable, Codable, Identifiable {
    case sadness
    case anger
    case love
    case fear
    case happy

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .sadness: "Sedih"
        case .anger: "Marah"
        case .love: "Cinta"
        case .fear: "Takut"
        case .happy: "Bahagia"
        }
    }

    var systemImageName: String {
        switch self {
        case .sadness: "cloud.rain"
        case .anger: "flame"
        case .love: "heart.fill"
        case .fear: "exclamationmark.triangle"
        case .happy: "sun.max.fill"
        }
    }
}

struct EmotionClassificationResult: Equatable {
    let label: Emotion
    let confidence: Double
    let probabilities: [Emotion: Double]
    /// Normalized score in [-1, 1]: positive emotions minus negative emotions.
    let sentimentScore: Double

    nonisolated static func from(logits: [Float]) -> EmotionClassificationResult? {
        guard logits.count == Emotion.allCases.count else { return nil }

        let probabilities = softmax(logits)
        var byEmotion: [Emotion: Double] = [:]
        for (index, emotion) in Emotion.allCases.enumerated() {
            byEmotion[emotion] = Double(probabilities[index])
        }

        guard let best = probabilities.enumerated().max(by: { $0.element < $1.element }) else { return nil }
        let index = best.offset
        guard Emotion.allCases.indices.contains(index) else { return nil }
        let label = Emotion.allCases[index]

        let positive = (byEmotion[.happy] ?? 0) + (byEmotion[.love] ?? 0)
        let negative = (byEmotion[.sadness] ?? 0) + (byEmotion[.anger] ?? 0) + (byEmotion[.fear] ?? 0)
        let sentimentScore = max(-1, min(1, positive - negative))

        return EmotionClassificationResult(
            label: label,
            confidence: Double(best.element),
            probabilities: byEmotion,
            sentimentScore: sentimentScore
        )
    }

    nonisolated private static func softmax(_ logits: [Float]) -> [Float] {
        let maxLogit = logits.max() ?? 0
        let expValues = logits.map { expf($0 - maxLogit) }
        let sum = expValues.reduce(0, +)
        guard sum > 0 else { return Array(repeating: 0, count: logits.count) }
        return expValues.map { $0 / sum }
    }
}

enum EmotionClassificationError: LocalizedError {
    case emptyInput
    case modelNotFound
    case tokenizerNotFound
    case invalidModelOutput
    case predictionFailed(String)

    var errorDescription: String? {
        switch self {
        case .emptyInput:
            "Teks journal kosong."
        case .modelNotFound:
            "Model Core ML tidak ditemukan di bundle."
        case .tokenizerNotFound:
            "File tokenizer (vocab.txt) tidak ditemukan di bundle."
        case .invalidModelOutput:
            "Output model tidak valid."
        case let .predictionFailed(message):
            "Prediksi gagal: \(message)"
        }
    }
}
