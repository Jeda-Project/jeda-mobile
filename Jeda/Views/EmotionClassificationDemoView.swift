/**
 * Scope: EmotionClassificationDemoView.swift
 * Purpose: Kontemplasi screen for journal entry and on-device emotion classification.
 */

import SwiftUI

struct EmotionClassificationDemoView: View {
    @Environment(\.emotionService)
    private var emotionService
    @EnvironmentObject private var reflectionStore: ReflectionStore
    @Environment(\.crisisDetector)
    private var crisisDetector

    @State var journalText = ""
    @State var moodStep: Int = 2
    @State var result: EmotionClassificationResult?
    @State var errorMessage: String?
    @State var isAnalyzing = false
    @State var reflectionQuestion: String?
    @State var showDeeperReflection = false
    @State var isShowingResult = false
    @State var isSaving = false
    @State var crisisDetected = false
    var selectedMood: JedaMood { JedaMood.mood(forCheckInStep: moodStep) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                    headerSection

                    if isShowingResult {
                        if crisisDetected { JedaCrisisSupportCard() }
                        if let result {
                            summarySection
                            resultSection(result)
                        }
                        if let question = reflectionQuestion {
                            reflectionSection(question)
                            deeperReflectionButton
                        }
                        if let errorMessage { errorSection(errorMessage) }
                        resetButton
                    } else {
                        moodSliderSection
                        journalSection
                        analyzeButton
                    }
                }.padding(.horizontal, JedaSpacing.lg).padding(.top, JedaSpacing.md)
                    .padding(.bottom, JedaSpacing.xl + JedaSpacing.floatingTabBarClearance)
                    .animation(.easeInOut(duration: 0.35), value: isShowingResult)
            }.background { JedaScreenBackground() }.toolbar {
                if isShowingResult {
                    ToolbarItem(placement: .topBarLeading) {
                        Button { resetForm() } label: {
                            Image(systemName: "chevron.backward").fontWeight(.semibold).accessibilityHidden(true)
                        }.tint(JedaColor.textPrimary).accessibilityLabel("Kembali")
                    }
                }
            }.navigationDestination(isPresented: $showDeeperReflection) {
                if let result {
                    JedaDeeperReflectionView(
                        journalExcerpt: String(journalText.prefix(120)),
                        mood: selectedMood,
                        emotion: result.label,
                        confidence: result.confidence,
                        reflectionQuestion: reflectionQuestion ?? "Apa yang paling kamu rasakan saat ini?",
                        onSave: { entry in
                            reflectionStore.add(entry)
                            reflectionStore.clearPending()
                            resetForm()
                        }
                    )
                }
            }
        }.jedaHideTabBar(isShowingResult).onChange(of: reflectionStore.completedSaveCount) { resetForm() }
    }

    private var headerSection: some View {
        Text(isShowingResult ? "Hasil Analisis" : "Kontemplasi Harian")
            .font(.largeTitle.weight(.bold)).foregroundStyle(JedaColor.textPrimary)
            .animation(.easeInOut(duration: 0.2), value: isShowingResult)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    func analyze() async {
        isAnalyzing = true
        errorMessage = nil
        reflectionQuestion = nil
        crisisDetected = crisisDetector.detect(in: journalText).isCrisis
        defer { isAnalyzing = false }

        do {
            let classified = try await emotionService.classify(journalText)
            result = classified
            let question = JedaOnDeviceReflection.generate(from: journalText, emotion: classified.label)
            reflectionQuestion = question
            reflectionStore.setPending(
                PendingReflection(
                    journalExcerpt: String(journalText.prefix(120)),
                    mood: selectedMood,
                    emotion: classified.label,
                    confidence: classified.confidence,
                    reflectionQuestion: question,
                    highlightedPhrase: JedaOnDeviceReflection.keyword(from: journalText)
                )
            )
            withAnimation(.easeInOut(duration: 0.35)) { isShowingResult = true }
        } catch {
            result = nil
            errorMessage = error.localizedDescription
        }
    }

    func saveEntry() async {
        guard let result else { return }
        isSaving = true
        defer { isSaving = false }
        let question = reflectionQuestion
            ?? JedaOnDeviceReflection.generate(from: journalText, emotion: result.label)
        let entry = ReflectionEntry(
            journalExcerpt: String(journalText.prefix(120)),
            mood: selectedMood,
            emotion: result.label,
            confidence: result.confidence,
            reflectionQuestion: question
        )

        reflectionStore.add(entry)
        reflectionStore.clearPending()
        resetForm()
    }

    func resetForm() {
        withAnimation(.easeInOut(duration: 0.35)) {
            isShowingResult = false
            result = nil
            reflectionQuestion = nil
            errorMessage = nil
            crisisDetected = false
            journalText = ""
            moodStep = 2
        }
    }
}

#Preview {
    EmotionClassificationDemoView().environmentObject(ReflectionStore())
}
