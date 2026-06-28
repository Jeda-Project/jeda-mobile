/**
 * Scope: CrisisDetectionService.swift
 * Purpose: Deterministic, auditable crisis-signal detection over journal text using keyword matching only — no AI, no network, no async.
 */

import Foundation

protocol CrisisDetecting: Sendable {
    func detect(in text: String) -> CrisisDetectionResult
}

struct CrisisDetectionService: CrisisDetecting {
    func detect(in text: String) -> CrisisDetectionResult {
        let normalized = Self.normalize(text)
        guard !normalized.isEmpty else { return .none }

        let haystack = " \(normalized) "
        let matched = Self.lexicon.filter { haystack.contains(" \($0) ") }
        return CrisisDetectionResult(isCrisis: !matched.isEmpty, matchedTerms: matched)
    }

    private static func normalize(_ text: String) -> String {
        let folded = text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        let tokenized = folded.unicodeScalars.map {
            CharacterSet.alphanumerics.contains($0) ? Character($0) : " "
        }
        return String(tokenized).split(separator: " ").joined(separator: " ")
    }

    private static let lexicon: [String] = [
        "bunuh diri",
        "ingin bunuh diri",
        "mau bunuh diri",
        "akhiri hidup",
        "akhiri hidupku",
        "mengakhiri hidup",
        "mengakhiri hidupku",
        "ingin mati",
        "pengen mati",
        "mau mati",
        "pengin mati",
        "mati aja",
        "lebih baik mati",
        "lebih baik aku mati",
        "ingin mengakhiri semuanya",
        "tidak mau hidup",
        "tidak mau hidup lagi",
        "gak mau hidup",
        "ga mau hidup lagi",
        "capek hidup",
        "lelah hidup",
        "menyakiti diri",
        "menyakiti diri sendiri",
        "melukai diri",
        "melukai diri sendiri",
        "menyilet",
        "menyilet tangan",
        "gantung diri",
        "potong nadi",
        "minum racun",
        "overdosis",
        "self harm",
        "selfharm",
        "self injury",
        "kill myself",
        "end my life",
        "want to die",
    ]
}
