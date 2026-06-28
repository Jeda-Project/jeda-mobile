/**
 * Scope: JedaOnDeviceReflection.swift
 * Purpose: Generates a lightweight on-device reflection question from journal text and detected emotion.
 */

import Foundation

enum JedaOnDeviceReflection {
    static func generate(from text: String, emotion: Emotion) -> String {
        let keyword = extractKeyword(from: text)

        if let keyword {
            return emotionQuestion(for: emotion, keyword: keyword)
        } else {
            return fallbackQuestion(for: emotion)
        }
    }

    private static func extractKeyword(from text: String) -> String? {
        let stopWords: Set<String> = [
            "aku", "saya", "kamu", "dia", "kami", "mereka", "ini", "itu",
            "dan", "atau", "tapi", "tetapi", "karena", "kalau", "jika",
            "yang", "di", "ke", "dari", "dengan", "untuk", "pada", "sudah",
            "sedang", "akan", "tidak", "tak", "bukan", "juga", "lagi",
            "sangat", "banget", "sekali", "masih", "sudah", "sih", "deh",
            "nih", "yah", "ya", "ah", "oh", "ada", "bisa", "mau", "mau",
            "baru", "punya", "harus", "boleh", "perlu", "lalu", "terus"
        ]

        let words = text
            .lowercased()
            .components(separatedBy: .whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { $0.count >= 4 && !stopWords.contains($0) }

        return words.max(by: { $0.count < $1.count })
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

    private static func fallbackQuestion(for emotion: Emotion) -> String {
        switch emotion {
        case .sadness:
            return "Ada bagian dari harimu yang terasa lebih berat dari biasanya — apa yang muncul pertama kali saat kamu mengingatnya?"
        case .anger:
            return "Apa satu hal dari hari ini yang paling ingin kamu ubah kalau bisa?"
        case .love:
            return "Apa yang membuatmu merasa terhubung hari ini?"
        case .fear:
            return "Kalau ketidakpastian itu hilang besok, apa yang pertama kali ingin kamu lakukan?"
        case .happy:
            return "Momen mana dari hari ini yang ingin kamu ingat lebih lama?"
        }
    }
}
