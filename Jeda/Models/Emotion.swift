//
//  Emotion.swift
//  Jeda
//

import Foundation

/// IndoNLU EmoT labels (matches fine-tuned IndoBERT-lite checkpoint).
enum Emotion: String, CaseIterable, Codable, Sendable, Identifiable {
    case sadness
    case anger
    case love
    case fear
    case happy

    var id: String { rawValue }

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

    init?(classIndex: Int) {
        switch classIndex {
        case 0: self = .sadness
        case 1: self = .anger
        case 2: self = .love
        case 3: self = .fear
        case 4: self = .happy
        default: return nil
        }
    }
}

struct EmotionClassificationResult: Sendable, Equatable {
    let label: Emotion
    let confidence: Double
    let probabilities: [Emotion: Double]
    /// Normalized score in [-1, 1]: positive emotions minus negative emotions.
    let sentimentScore: Double

    static func from(logits: [Float]) -> EmotionClassificationResult? {
        guard logits.count == Emotion.allCases.count else { return nil }

        let probabilities = softmax(logits)
        var byEmotion: [Emotion: Double] = [:]
        for (index, emotion) in Emotion.allCases.enumerated() {
            byEmotion[emotion] = Double(probabilities[index])
        }

        guard let best = probabilities.enumerated().max(by: { $0.element < $1.element }),
              let label = Emotion(classIndex: best.offset)
        else { return nil }

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

    private static func softmax(_ logits: [Float]) -> [Float] {
        let maxLogit = logits.max() ?? 0
        let expValues = logits.map { expf($0 - maxLogit) }
        let sum = expValues.reduce(0, +)
        guard sum > 0 else { return Array(repeating: 0, count: logits.count) }
        return expValues.map { $0 / sum }
    }
}

enum EmotionClassificationError: LocalizedError, Sendable {
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
