//
//  IndoBertTokenizer.swift
//  Jeda
//
//  WordPiece tokenizer compatible with HuggingFace BertTokenizer
//  (do_lower_case=true) used by indobenchmark/indobert-lite-base-p1.
//

import Foundation

struct IndoBertEncoding: Sendable {
    let inputIds: [Int32]
    let attentionMask: [Int32]
}

final class IndoBertTokenizer: Sendable {
    static let padTokenId: Int32 = 0
    static let unkTokenId: Int32 = 1
    static let clsTokenId: Int32 = 2
    static let sepTokenId: Int32 = 3

    private let vocabulary: [String: Int32]
    private let maxInputCharsPerWord = 200

    init(vocabulary: [String: Int32]) {
        self.vocabulary = vocabulary
    }

    convenience init(bundle: Bundle = .main) throws {
        guard let vocabURL = bundle.url(forResource: "vocab", withExtension: "txt") else {
            throw EmotionClassificationError.tokenizerNotFound
        }
        let contents = try String(contentsOf: vocabURL, encoding: .utf8)
        var vocabulary: [String: Int32] = [:]
        vocabulary.reserveCapacity(contents.components(separatedBy: .newlines).count)
        for (index, line) in contents.components(separatedBy: .newlines).enumerated() {
            let token = line.trimmingCharacters(in: .newlines)
            guard !token.isEmpty else { continue }
            vocabulary[token] = Int32(index)
        }
        self.init(vocabulary: vocabulary)
    }

    func encode(_ text: String, maxLength: Int) -> IndoBertEncoding {
        let tokens = tokenize(text)
        var inputIds = [Self.clsTokenId]
        inputIds.append(contentsOf: tokens.compactMap { vocabulary[$0] ?? Self.unkTokenId })
        inputIds.append(Self.sepTokenId)

        if inputIds.count > maxLength {
            inputIds = Array(inputIds.prefix(maxLength - 1)) + [Self.sepTokenId]
        }

        let realLength = inputIds.count
        if inputIds.count < maxLength {
            inputIds.append(contentsOf: repeatElement(Self.padTokenId, count: maxLength - inputIds.count))
        }

        let attentionMask = (0..<maxLength).map { index in
            index < realLength ? Int32(1) : Int32(0)
        }

        return IndoBertEncoding(inputIds: inputIds, attentionMask: attentionMask)
    }

    private func tokenize(_ text: String) -> [String] {
        let cleaned = cleanText(text)
        let chineseSpaced = tokenizeChineseChars(cleaned)
        let lowercased = chineseSpaced.lowercased()
        let basicTokens = basicTokenize(lowercased)
        return basicTokens.flatMap { wordpieceTokenize($0) }
    }

    private func cleanText(_ text: String) -> String {
        var output = ""
        output.reserveCapacity(text.count)
        for scalar in text.unicodeScalars {
            if scalar.value == 0 || scalar.value == 0xFFFD || isControl(scalar) {
                continue
            }
            if isWhitespace(scalar) {
                output.append(" ")
            } else {
                output.unicodeScalars.append(scalar)
            }
        }
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func tokenizeChineseChars(_ text: String) -> String {
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

    private func basicTokenize(_ text: String) -> [String] {
        text
            .split(whereSeparator: \.isWhitespace)
            .flatMap { splitOnPunctuation(String($0)) }
    }

    private func splitOnPunctuation(_ token: String) -> [String] {
        var chars = Array(token)
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

    private func wordpieceTokenize(_ token: String) -> [String] {
        guard !token.isEmpty else { return [] }

        var chars = Array(token)
        if chars.count > maxInputCharsPerWord {
            return ["[UNK]"]
        }

        var subTokens: [String] = []
        var start = 0
        let isBad = { () -> Bool in
            while start < chars.count {
                var end = chars.count
                var currentSubstr: String?
                while start < end {
                    var substr = String(chars[start..<end])
                    if start > 0 {
                        substr = "##" + substr
                    }
                    if self.vocabulary[substr] != nil {
                        currentSubstr = substr
                        break
                    }
                    end -= 1
                }
                guard let piece = currentSubstr else { return true }
                subTokens.append(piece)
                start = end
            }
            return false
        }()

        if isBad {
            return ["[UNK]"]
        }
        return subTokens
    }

    private func isControl(_ scalar: Unicode.Scalar) -> Bool {
        if scalar.properties.generalCategory == .format { return true }
        switch scalar.value {
        case 0x0000...0x001F, 0x007F...0x009F:
            return true
        default:
            return false
        }
    }

    private func isWhitespace(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.value {
        case 0x0009, 0x000A, 0x000B, 0x000C, 0x000D, 0x0020:
            return true
        default:
            return scalar.properties.generalCategory == .spaceSeparator
        }
    }

    private func isPunctuation(_ character: Character) -> Bool {
        let scalar = character.unicodeScalars.first!
        if (0x0021...0x002F).contains(scalar.value)
            || (0x003A...0x0040).contains(scalar.value)
            || (0x005B...0x0060).contains(scalar.value)
            || (0x007B...0x007E).contains(scalar.value) {
            return true
        }
        return scalar.properties.generalCategory == .otherPunctuation
            || scalar.properties.generalCategory == .initialPunctuation
            || scalar.properties.generalCategory == .finalPunctuation
    }

    private func isChineseChar(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.value {
        case 0x4E00...0x9FFF, 0x3400...0x4DBF, 0x20000...0x2A6DF, 0x2A700...0x2B73F,
             0x2B740...0x2B81F, 0x2B820...0x2CEAF, 0xF900...0xFAFF, 0x2F800...0x2FA1F:
            return true
        default:
            return false
        }
    }
}
