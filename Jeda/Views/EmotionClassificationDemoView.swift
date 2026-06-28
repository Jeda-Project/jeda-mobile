/**
 * Scope: EmotionClassificationDemoView.swift
 * Purpose: Check-in screen for journal entry and on-device emotion classification.
 */

import SwiftUI

struct EmotionClassificationDemoView: View {
    @Environment(\.emotionService) private var emotionService
    @Environment(\.reflectionStore) private var reflectionStore

    @State private var journalText = ""
    @State private var moodStep: Int = 2
    @State private var result: EmotionClassificationResult?
    @State private var errorMessage: String?
    @State private var isAnalyzing = false
    @State private var reflectionQuestion: String?
    @State private var showDeeperReflection = false
    @State private var isShowingResult = false

    private var selectedMood: JedaMood {
        JedaMood.mood(forCheckInStep: moodStep)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                    headerSection

                    if isShowingResult {
                        if let result {
                            summarySection
                            resultSection(result)
                        }
                        if let question = reflectionQuestion {
                            reflectionSection(question)
                            deeperReflectionButton
                        }
                        if let errorMessage {
                            errorSection(errorMessage)
                        }
                        resetButton
                    } else {
                        moodSliderSection
                        journalSection
                        analyzeButton
                    }
                }
                .padding(.horizontal, JedaSpacing.lg)
                .padding(.top, JedaSpacing.md)
                .padding(.bottom, JedaSpacing.xl)
                .animation(.easeInOut(duration: 0.35), value: isShowingResult)
            }
            .background { JedaScreenBackground() }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showDeeperReflection) {
                JedaDeeperReflectionView(
                    journalExcerpt: String(journalText.prefix(120)),
                    reflectionQuestion: reflectionQuestion ?? "Apa yang paling kamu rasakan saat ini?",
                    onSave: { entry in reflectionStore.add(entry) }
                )
            }
        }
    }

    private var headerSection: some View {
        Text(isShowingResult ? "Hasil Analisis" : "Catatan Harian")
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(Color.black)
            .animation(.easeInOut(duration: 0.2), value: isShowingResult)
    }

    private var summarySection: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.08)) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                HStack(spacing: JedaSpacing.xs) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 10, weight: .semibold))
                    Text("Catatan Harianmu")
                        .font(JedaTypography.caption)
                }
                .foregroundStyle(JedaColor.textSecondary)

                Divider()

                HStack(spacing: JedaSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(JedaColor.sage.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: selectedMood.symbol)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(JedaColor.sage)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mood hari ini")
                            .font(JedaTypography.caption)
                            .foregroundStyle(JedaColor.textSecondary)
                        Text(selectedMood.title)
                            .font(JedaTypography.headline)
                            .foregroundStyle(JedaColor.textPrimary)
                    }
                }

                Divider()

                Text(journalText)
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textPrimary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var moodSliderSection: some View {
        JedaMoodCheckInSlider(step: $moodStep)
    }

    private var journalSection: some View {
        JedaJournalInput(
            title: "Jurnal",
            prompt: "Bagaimana perasaanmu hari ini?",
            text: $journalText
        )
    }

    private var analyzeButton: some View {
        Button {
            Task { await analyze() }
        } label: {
            Label("Pahami Perasaanku", systemImage: "sparkles")
                .frame(maxWidth: .infinity)
                .opacity(isAnalyzing ? 0.001 : 1)
                .background(alignment: .center) {
                    if isAnalyzing {
                        ProgressView()
                            .tint(Color.white)
                            .scaleEffect(0.7)
                    }
                }
        }
        .jedaProminentButtonStyle(tint: JedaColor.sage)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .font(JedaTypography.headline)
        .disabled(journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .allowsHitTesting(!isAnalyzing)
        .frame(maxWidth: .infinity)
    }

    private var deeperReflectionButton: some View {
        Button {
            showDeeperReflection = true
        } label: {
            Label("Cerita Lebih Dalam", systemImage: "sparkles")
                .frame(maxWidth: .infinity)
        }
        .jedaProminentButtonStyle(tint: JedaColor.sage)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .font(JedaTypography.headline)
        .frame(maxWidth: .infinity)
    }

    private var resetButton: some View {
        HStack(spacing: JedaSpacing.sm) {
            Button {
                withAnimation(.easeInOut(duration: 0.35)) {
                    isShowingResult = false
                    result = nil
                    reflectionQuestion = nil
                    errorMessage = nil
                    journalText = ""
                    moodStep = 2
                }
            } label: {
                Label("Kembali", systemImage: "arrow.counterclockwise")
                    .font(JedaTypography.headline)
                    .foregroundStyle(JedaColor.textSecondary.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background {
                        Capsule()
                            .fill(JedaColor.elevatedBackground.opacity(0.16))
                    }
                    .jedaGlassEffect(tint: nil, in: Capsule())
                    .overlay {
                        Capsule()
                            .strokeBorder(JedaColor.separator, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)

            Button {
            } label: {
                Text("Simpan")
                    .frame(maxWidth: .infinity)
            }
            .jedaProminentButtonStyle(tint: JedaColor.sage)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .font(JedaTypography.headline)
        }
    }

    private func resultSection(_ result: EmotionClassificationResult) -> some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.10)) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                HStack(spacing: JedaSpacing.xs) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 10, weight: .semibold))
                    Text("Hasil Analisis Emosi")
                        .font(JedaTypography.caption)
                }
                .foregroundStyle(JedaColor.textSecondary)

                Divider()

                HStack(spacing: JedaSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(JedaColor.sage.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: result.label.systemImageName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(JedaColor.sage)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.label.displayName)
                            .font(JedaTypography.headline)
                            .foregroundStyle(JedaColor.textPrimary)
                        Text(result.confidence.formatted(.percent.precision(.fractionLength(0))) + " keyakinan")
                            .font(JedaTypography.caption)
                            .foregroundStyle(JedaColor.textSecondary)
                    }

                    Spacer()
                }

                Divider()

                HStack {
                    Spacer()
                    HStack(spacing: JedaSpacing.xs) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 10, weight: .semibold))
                        Text("AI Bisa Salah")
                            .font(JedaTypography.caption)
                    }
                    .foregroundStyle(JedaColor.textSecondary)
                }
            }
        }
    }

    private func reflectionSection(_ question: String) -> some View {
        JedaGlassSurface(tint: JedaColor.dustyBlue.opacity(0.12)) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                HStack(spacing: JedaSpacing.xs) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 10, weight: .semibold))
                    Text("Refleksi")
                        .font(JedaTypography.caption)
                }
                .foregroundStyle(JedaColor.textSecondary)

                Divider()

                Text(question)
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func errorSection(_ message: String) -> some View {
        JedaGlassSurface(tint: JedaColor.terracotta.opacity(0.12)) {
            Text(message)
                .font(JedaTypography.body)
                .foregroundStyle(JedaColor.terracotta)
        }
    }

    private func analyze() async {
        isAnalyzing = true
        errorMessage = nil
        reflectionQuestion = nil
        defer { isAnalyzing = false }

        do {
            let classified = try await emotionService.classify(journalText)
            result = classified
            reflectionQuestion = JedaOnDeviceReflection.generate(from: journalText, emotion: classified.label)
            withAnimation(.easeInOut(duration: 0.35)) {
                isShowingResult = true
            }
        } catch {
            result = nil
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    EmotionClassificationDemoView()
}
