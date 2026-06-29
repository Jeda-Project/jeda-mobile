/**
 * Scope: IndoBertTokenizer.swift
 * Purpose: WordPiece tokenizer compatible with HuggingFace BertTokenizer (do_lower_case=true) for IndoBERT.
 */

import Foundation

struct IndoBertEncoding {
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

        let attentionMask = (0 ..< maxLength).map { index in
            index < realLength ? Int32(1) : Int32(0)
        }

        return IndoBertEncoding(inputIds: inputIds, attentionMask: attentionMask)
    }

    private func tokenize(_ text: String) -> [String] {
        let cleaned = BertTextCleaner.cleanText(text)
        let chineseSpaced = BertTextCleaner.tokenizeChineseChars(cleaned)
        let lowercased = chineseSpaced.lowercased()
        let basicTokens = BertTextCleaner.basicTokenize(lowercased)
        return basicTokens.flatMap { wordpieceTokenize($0) }
    }

    private func wordpieceTokenize(_ token: String) -> [String] {
        guard !token.isEmpty else { return [] }

        let chars = Array(token)
        if chars.count > maxInputCharsPerWord { return ["[UNK]"] }

        var subTokens: [String] = []
        var start = 0
        let isBad = { () -> Bool in
            while start < chars.count {
                var end = chars.count
                var currentSubstr: String?
                while start < end {
                    var substr = String(chars[start ..< end])
                    if start > 0 { substr = "##" + substr }
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

        return isBad ? ["[UNK]"] : subTokens
    }
}
