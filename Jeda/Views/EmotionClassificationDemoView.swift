//
//  EmotionClassificationDemoView.swift
//  Jeda
//
//  Contoh pemakaian EmotionClassificationService di UI journal.
//

import SwiftUI

struct EmotionClassificationDemoView: View {
    @Environment(\.emotionService) private var emotionService

    @State private var journalText = "Hari ini deploy berhasil, lega banget."
    @State private var result: EmotionClassificationResult?
    @State private var errorMessage: String?
    @State private var isAnalyzing = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Journal entry") {
                    TextEditor(text: $journalText)
                        .frame(minHeight: 120)
                }

                Section {
                    Button {
                        Task { await analyze() }
                    } label: {
                        if isAnalyzing {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Analisis emosi")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isAnalyzing || journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if let result {
                    Section("Hasil") {
                        Label(result.label.displayName, systemImage: result.label.systemImageName)
                        LabeledContent("Confidence", value: result.confidence, format: .percent.precision(.fractionLength(1)))
                        LabeledContent("Sentiment score", value: result.sentimentScore, format: .number.precision(.fractionLength(2)))

                        ForEach(Emotion.allCases) { emotion in
                            if let probability = result.probabilities[emotion] {
                                LabeledContent(emotion.displayName, value: probability, format: .percent.precision(.fractionLength(1)))
                            }
                        }
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Check-in")
        }
    }

    private func analyze() async {
        isAnalyzing = true
        errorMessage = nil
        defer { isAnalyzing = false }

        do {
            result = try await emotionService.classify(journalText)
        } catch {
            result = nil
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    EmotionClassificationDemoView()
}
