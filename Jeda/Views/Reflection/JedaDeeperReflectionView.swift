/**
 * Scope: JedaDeeperReflectionView.swift
 * Purpose: Screen presenting the AI-guided deeper reflection flow after initial emotion kontemplasi.
 */

import SwiftUI

struct JedaDeeperReflectionView: View {
    let journalExcerpt: String
    let mood: JedaMood
    let emotion: Emotion
    let confidence: Double
    let reflectionQuestion: String
    let onSave: (ReflectionEntry) -> Void

    @State var reflectionText = ""
    @State var showConsentSheet = false
    @State var viewModel: DeeperReflectionViewModel
    @Environment(\.dismiss)
    var dismiss
    @Environment(\.aiService)
    private var aiService
    @Environment(\.reflectionAIConsentStore)
    private var consentStore

    init(
        journalExcerpt: String,
        mood: JedaMood,
        emotion: Emotion,
        confidence: Double,
        reflectionQuestion: String,
        onSave: @escaping (ReflectionEntry) -> Void
    ) {
        self.journalExcerpt = journalExcerpt
        self.mood = mood
        self.emotion = emotion
        self.confidence = confidence
        self.reflectionQuestion = reflectionQuestion
        self.onSave = onSave
        _viewModel = State(
            initialValue: DeeperReflectionViewModel(aiService: nil, consentStore: ReflectionAIConsentStore())
        )
    }

    var canSubmit: Bool {
        !reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                headerSection
                excerptSection
                aiQuestionSection
                conversationSection
                inputSection
            }
            .padding(.horizontal, JedaSpacing.lg)
            .padding(.top, JedaSpacing.md)
            .padding(.bottom, JedaSpacing.xl)
        }
        .background(JedaColor.background.ignoresSafeArea())
        .jedaHideTabBar()
        .tint(JedaColor.textPrimary)
        .sheet(isPresented: $showConsentSheet) {
            ReflectionAIConsentSheet(
                onGrant: {
                    consentStore.setStatus(.granted)
                    showConsentSheet = false
                    viewModel.sendReflection(text: reflectionText, emotion: emotion)
                },
                onDeny: {
                    consentStore.setStatus(.denied)
                    showConsentSheet = false
                }
            )
        }
        .task {
            viewModel = DeeperReflectionViewModel(aiService: aiService, consentStore: consentStore)
        }
    }

    private var headerSection: some View {
        Text("Refleksi")
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(JedaColor.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder var aiReplyContent: some View {
        switch viewModel.aiReplyState {
        case .idle:
            EmptyView()
        case .loading:
            HStack(spacing: JedaSpacing.sm) {
                ProgressView()
                Text("Sedang membalas...")
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textSecondary)
            }
        case let .loaded(text):
            Text(text)
                .font(JedaTypography.body)
                .foregroundStyle(JedaColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        case let .failed(message):
            VStack(alignment: .leading, spacing: JedaSpacing.sm) {
                Text(message)
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textSecondary)
                JedaButton("Coba lagi", kind: .secondary, tint: JedaColor.terracotta, isLoading: viewModel.isRetrying) {
                    viewModel.retryReflection(text: reflectionText, emotion: emotion)
                }
                .disabled(viewModel.isRetrying)
                .accessibilityLabel("Coba kirim ulang refleksi ke AI")
            }
        }
    }
}

#Preview("Deeper reflection page") {
    NavigationStack {
        JedaDeeperReflectionView(
            journalExcerpt: "Sempat kepikiran soal review code yang tadi...",
            mood: .neutral,
            emotion: .fear,
            confidence: 0.82,
            reflectionQuestion: "Apa yang paling challenging dari proses itu?",
            onSave: { _ in }
        )
    }
}

#Preview("Deeper reflection – consent sheet") {
    ReflectionAIConsentSheet(onGrant: {}, onDeny: {})
}
