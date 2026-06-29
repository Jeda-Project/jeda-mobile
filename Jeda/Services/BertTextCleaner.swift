/**
 * Scope: BertTextCleaner.swift
 * Purpose: Text preprocessing pipeline for BERT tokenization: cleaning, Chinese char spacing, and basic tokenization.
 */

import Foundation

enum BertTextCleaner {
    static func cleanText(_ text: String) -> String {
        var output = ""
        output.reserveCapacity(text.count)
        for scalar in text.unicodeScalars {
            if scalar.value == 0 || scalar.value == 0xFFFD || isControl(scalar) { continue }
            if isWhitespace(scalar) {
                output.append(" ")
            } else {
                output.unicodeScalars.append(scalar)
            }
        }
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func tokenizeChineseChars(_ text: String) -> String {
        var output = ""
        output.reserveCapacity(text.count * 2)
        for scalar in text.unicodeScalars {
            if isChineseChar(scalar) {
                output.append(" ")
                output.unicodeScalars.append(scalar)
                output.append(" ")
            } else {
                output.unicodeScalars.append(scalar)
            }
        }
        return output
    }

    static func basicTokenize(_ text: String) -> [String] {
        text
            .split(whereSeparator: \.isWhitespace)
            .flatMap { splitOnPunctuation(String($0)) }
    }

    static func splitOnPunctuation(_ token: String) -> [String] {
        let chars = Array(token)
        var index = 0
        var startNewWord = true
        var output: [String] = []

        while index < chars.count {
            if isPunctuation(chars[index]) {
                output.append(String(chars[index]))
                startNewWord = true
            } else {
                if startNewWord {
                    output.append("")
                    startNewWord = false
                }
                output[output.count - 1].append(chars[index])
            }
            index += 1
        }

        return output.filter { !$0.isEmpty }
    }

    private static func isControl(_ scalar: Unicode.Scalar) -> Bool {
        if scalar.properties.generalCategory == .format { return true }
        switch scalar.value {
        case 0x0000 ... 0x001F, 0x007F ... 0x009F: return true
        default: return false
        }
    }

    private static func isWhitespace(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.value {
        case 0x0009, 0x000A, 0x000B, 0x000C, 0x000D, 0x0020: true
        default: scalar.properties.generalCategory == .spaceSeparator
        }
    }

    static func isPunctuation(_ character: Character) -> Bool {
        guard let scalar = character.unicodeScalars.first else { return false }
        if (0x0021 ... 0x002F).contains(scalar.value)
            || (0x003A ... 0x0040).contains(scalar.value)
            || (0x005B ... 0x0060).contains(scalar.value)
            || (0x007B ... 0x007E).contains(scalar.value) {
            return true
        }
        return scalar.properties.generalCategory == .otherPunctuation
            || scalar.properties.generalCategory == .initialPunctuation
            || scalar.properties.generalCategory == .finalPunctuation
    }

    static func isChineseChar(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.value {
        case 0x4E00 ... 0x9FFF, 0x3400 ... 0x4DBF, 0x20000 ... 0x2A6DF, 0x2A700 ... 0x2B73F,
             0x2B740 ... 0x2B81F, 0x2B820 ... 0x2CEAF, 0xF900 ... 0xFAFF, 0x2F800 ... 0x2FA1F:
            true
        default: false
        }
    }
}
