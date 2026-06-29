/**
 * Scope: JedaOnDeviceReflection.swift
 * Purpose: Generates a lightweight on-device reflection question from journal text and detected emotion.
 */

import Foundation

enum JedaOnDeviceReflection {
    static func generate(from text: String, emotion: Emotion) -> String {
        emotionQuestion(for: emotion, keyword: keyword(from: text))
    }

    static func generate(from text: String, mood: JedaMood) -> String {
        let emotion: Emotion = switch mood {
        case .heavy: .sadness
        case .low: .fear
        case .neutral: .love
        case .okay: .happy
        case .light: .happy
        }
        return generate(from: text, emotion: emotion)
    }

    static func keyword(from text: String) -> String {
        extractKeyword(from: text) ?? "sesuatu"
    }

    private static func extractKeyword(from text: String) -> String? {
        let stopWords: Set = [
            "dan", "atau", "tapi", "tetapi", "karena", "kalau", "jika",
            "yang", "di", "ke", "dari", "dengan", "untuk", "pada",
            "sedang", "akan", "tidak", "tak", "bukan", "juga", "lagi",
            "sangat", "banget", "sekali", "masih", "sudah", "sih", "deh",
            "nih", "yah", "ya", "ah", "oh", "ada", "bisa", "mau",
            "baru", "punya", "harus", "boleh", "perlu", "lalu", "terus"
        ]

        let words = text
            .lowercased()
            .components(separatedBy: .whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { $0.count >= 2 && !stopWords.contains($0) }

        let counts = Dictionary(words.map { ($0, 1) }, uniquingKeysWith: +)
        return counts.max { lhs, rhs in
            lhs.value == rhs.value ? lhs.key.count < rhs.key.count : lhs.value < rhs.value
        }?.key
    }

    private static func emotionQuestion(for emotion: Emotion, keyword: String) -> String {
        let q = "\u{201C}\(keyword)\u{201D}"
        switch emotion {
        case .sadness:
            return "Kamu menyebut \(q) — apa yang membuat kata itu terasa berat hari ini?"
        case .anger:
            return "Kamu menyebut \(q) — apa yang paling membuatmu terganggu di situ?"
        case .love:
            return "Kamu menyebut \(q) — seperti apa rasanya saat memikirkan itu?"
        case .fear:
            return "Kamu menyebut \(q) — bagian mana dari itu yang paling membuatmu ragu?"
        case .happy:
            return "Kamu menyebut \(q) — apa yang membuatnya terasa menyenangkan bagimu?"
        }
    }
}
