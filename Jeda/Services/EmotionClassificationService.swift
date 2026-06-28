//
//  EmotionClassificationService.swift
//  Jeda
//
//  On-device emotion classification using fine-tuned IndoBERT-lite (Core ML).
//

import CoreML
import Foundation

protocol EmotionAnalyzing: Sendable {
    func classify(_ text: String) async throws -> EmotionClassificationResult
}

actor EmotionClassificationService: EmotionAnalyzing {
    static let shared: EmotionClassificationService = {
        do {
            return try EmotionClassificationService()
        } catch {
            fatalError("Failed to load EmotionClassificationService: \(error.localizedDescription)")
        }
    }()

    static let maxSequenceLength = 128

    private let model: MLModel
    private let tokenizer: IndoBertTokenizer

    init(bundle: Bundle = .main) throws {
        guard let modelURL = Self.modelURL(in: bundle) else {
            throw EmotionClassificationError.modelNotFound
        }

        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all
        self.model = try MLModel(contentsOf: modelURL, configuration: configuration)
        self.tokenizer = try IndoBertTokenizer(bundle: bundle)
    }

    private static func modelURL(in bundle: Bundle) -> URL? {
        if let compiled = bundle.url(forResource: "JedaEmotionIndoBERT-int8", withExtension: "mlmodelc") {
            return compiled
        }
        return bundle.url(forResource: "JedaEmotionIndoBERT-int8", withExtension: "mlpackage")
    }

    /// Classifies journal text into one of five EmoT emotions.
    func classify(_ text: String) async throws -> EmotionClassificationResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw EmotionClassificationError.emptyInput
        }

        let encoding = tokenizer.encode(trimmed, maxLength: Self.maxSequenceLength)
        let logits = try predictLogits(encoding: encoding)
        guard let result = EmotionClassificationResult.from(logits: logits) else {
            throw EmotionClassificationError.invalidModelOutput
        }
        return result
    }

    private func predictLogits(encoding: IndoBertEncoding) throws -> [Float] {
        let inputIdsArray = try makeMultiArray(from: encoding.inputIds)
        let attentionMaskArray = try makeMultiArray(from: encoding.attentionMask)

        let input = try MLDictionaryFeatureProvider(dictionary: [
            "input_ids": MLFeatureValue(multiArray: inputIdsArray),
            "attention_mask": MLFeatureValue(multiArray: attentionMaskArray),
        ])

        let output: MLFeatureProvider
        do {
            output = try model.prediction(from: input)
        } catch {
            throw EmotionClassificationError.predictionFailed(error.localizedDescription)
        }

        guard let logitsValue = output.featureValue(for: "logits"),
              let multiArray = logitsValue.multiArrayValue
        else {
            throw EmotionClassificationError.invalidModelOutput
        }

        return multiArrayToFloatArray(multiArray)
    }

    private func makeMultiArray(from values: [Int32]) throws -> MLMultiArray {
        let array = try MLMultiArray(shape: [1, NSNumber(value: values.count)], dataType: .int32)
        for (index, value) in values.enumerated() {
            array[index] = NSNumber(value: value)
        }
        return array
    }

    private func multiArrayToFloatArray(_ multiArray: MLMultiArray) -> [Float] {
        let count = multiArray.count
        var result = [Float](repeating: 0, count: count)
        let pointer = multiArray.dataPointer.bindMemory(to: Float.self, capacity: count)
        for index in 0..<count {
            result[index] = pointer[index]
        }
        return result
    }
}
