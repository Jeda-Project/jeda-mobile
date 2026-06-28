/**
 * Scope: JedaReflectionView.swift
 * Purpose: Tab-level reflection history list, detail view, and deeper reflection input sheet.
 */

import SwiftUI

struct JedaReflectionView: View {
    @Environment(\.reflectionStore) private var store

    var onSaveCompleted: () -> Void = {}

    @State private var showDeeperReflection = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                headerSection
                    .padding(.horizontal, JedaSpacing.lg)
                    .padding(.top, JedaSpacing.md)

                if let pending = store.pendingReflection {
                    pendingReflectionSection(pending)
                        .padding(.horizontal, JedaSpacing.lg)
                }

                if store.entries.isEmpty && store.pendingReflection == nil {
                    emptyState
                } else if !store.entries.isEmpty {
                    entryList
                } else {
                    Spacer()
                }
            }
            .background { JedaScreenBackground() }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showDeeperReflection) {
                if let pending = store.pendingReflection {
                    JedaDeeperReflectionView(
                        journalExcerpt: pending.journalExcerpt,
                        mood: pending.mood,
                        emotion: pending.emotion,
                        confidence: pending.confidence,
                        reflectionQuestion: pending.reflectionQuestion,
                        onSave: { entry in
                            store.add(entry)
                            store.clearPending()
                            onSaveCompleted()
                        }
                    )
                }
            }
        }
    }

    private var headerSection: some View {
        Text("Refleksi")
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(Color.black)
    }

    private func pendingReflectionSection(_ pending: PendingReflection) -> some View {
        JedaReflectionCard(
            phrase: pending.highlightedPhrase,
            question: pending.reflectionQuestion
        ) {
            showDeeperReflection = true
        }
    }

    private var emptyState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                Text("Mari kita pelajari lebih dalam")
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textSecondary)

                JedaStateCard(kind: .empty)
            }
            .padding(.horizontal, JedaSpacing.lg)
            .padding(.bottom, JedaSpacing.xl)
        }
    }

    private var entryList: some View {
        ScrollView {
            VStack(spacing: JedaSpacing.md) {
                ForEach(store.entries) { entry in
                    NavigationLink(value: entry) {
                        ReflectionRowView(entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, JedaSpacing.lg)
            .padding(.bottom, JedaSpacing.xl)
        }
        .navigationDestination(for: ReflectionEntry.self) { entry in
            JedaReflectionDetailView(entry: entry)
        }
    }
}

private struct ReflectionRowView: View {
    let entry: ReflectionEntry

    var body: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.10)) {
            VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                HStack {
                    Text(entry.date, style: .date)
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(JedaColor.sage)
                }

                Text(entry.reflectionQuestion)
                    .font(JedaTypography.headline)
                    .foregroundStyle(JedaColor.textPrimary)
                    .lineLimit(2)

                Text(entry.reflectionText)
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textSecondary)
                    .lineLimit(2)
            }
        }
    }
}

struct JedaReflectionDetailView: View {
    let entry: ReflectionEntry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                headerSection
                summarySection
                resultSection
                reflectionSection
            }
            .padding(.horizontal, JedaSpacing.lg)
            .padding(.top, JedaSpacing.md)
            .padding(.bottom, JedaSpacing.xl)
        }
        .background { JedaScreenBackground() }
        .jedaHideTabBar()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: JedaSpacing.md) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.black)
                    .frame(width: 40, height: 40)
                    .background(JedaColor.elevatedBackground, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Kembali")
            
            Text("Hasil Analisis")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }



    private var summarySection: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.08)) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                HStack(spacing: JedaSpacing.xs) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 10, weight: .semibold))
                    Text("Kontemplasi Harianmu")
                        .font(JedaTypography.caption)
                }
                .foregroundStyle(JedaColor.textSecondary)

                Divider()

                HStack(spacing: JedaSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(JedaColor.sage.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: entry.mood.symbol)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(JedaColor.sage)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mood hari itu")
                            .font(JedaTypography.caption)
                            .foregroundStyle(JedaColor.textSecondary)
                        Text(entry.mood.title)
                            .font(JedaTypography.headline)
                            .foregroundStyle(JedaColor.textPrimary)
                    }
                }

                Divider()

                Text(entry.journalExcerpt)
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textPrimary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var resultSection: some View {
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
                        Image(systemName: entry.emotion.systemImageName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(JedaColor.sage)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.emotion.displayName)
                            .font(JedaTypography.headline)
                            .foregroundStyle(JedaColor.textPrimary)
                        Text(entry.confidence.formatted(.percent.precision(.fractionLength(0))) + " keyakinan")
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

    private var reflectionSection: some View {
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

                Text(entry.reflectionQuestion)
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if !entry.reflectionText.isEmpty {
                    Divider()

                    Text("Refleksimu")
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)

                    Text(entry.reflectionText)
                        .font(JedaTypography.body)
                        .foregroundStyle(JedaColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let aiReply = entry.aiReplyText, !aiReply.isEmpty {
                    Divider()

                    HStack(spacing: JedaSpacing.xs) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10, weight: .semibold))
                        Text("Balasan Jeda")
                            .font(JedaTypography.caption)
                    }
                    .foregroundStyle(JedaColor.sage)

                    Text(aiReply)
                        .font(JedaTypography.body)
                        .foregroundStyle(JedaColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

private enum AIReplyState {
    case idle
    case loading
    case loaded(String)
    case failed(String)
}

struct JedaDeeperReflectionView: View {
    let journalExcerpt: String
    let mood: JedaMood
    let emotion: Emotion
    let confidence: Double
    let reflectionQuestion: String
    let onSave: (ReflectionEntry) -> Void

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
    }

    @State private var reflectionText = ""
    @State private var submittedText: String?
    @State private var aiReplyState: AIReplyState = .idle
    @State private var showConsentSheet = false
    @State private var isSaving = false
    @State private var isRetrying = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.aiService) private var aiService
    @Environment(\.reflectionAIConsentStore) private var consentStore

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
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showConsentSheet) {

            ReflectionAIConsentSheet(
                onGrant: {
                    consentStore.setStatus(.granted)
                    showConsentSheet = false
                    sendReflection()
                },
                onDeny: {
                    consentStore.setStatus(.denied)
                    showConsentSheet = false
                }
            )
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: JedaSpacing.md) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.black)
                    .frame(width: 40, height: 40)
                    .background(JedaColor.elevatedBackground, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Kembali")
            
            Text("Refleksi")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var excerptSection: some View {
        JedaGlassSurface(tint: nil) {
            VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                Label("Dari Jurnal Kamu Hari Ini:", systemImage: "book.closed")
                    .font(JedaTypography.caption)
                    .foregroundStyle(JedaColor.textSecondary)
                
                Text(journalExcerpt)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(JedaColor.textPrimary)
                    .italic()
                    .lineSpacing(4)
            }
        }
    }

    private var aiQuestionSection: some View {
        JedaGlassSurface(tint: nil) {
            HStack(alignment: .top, spacing: JedaSpacing.md) {
                ZStack {
                    Circle()
                        .fill(JedaColor.sage.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(JedaColor.sage)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                    Text("Jeda · On-Device")
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)

                    VStack(alignment: .leading, spacing: JedaSpacing.sm) {
                        Text("Kamu menyebut \"\(highlightedKeyword)\" beberapa kali.")
                            .font(JedaTypography.body)
                            .foregroundStyle(JedaColor.textPrimary)

                        Text(reflectionQuestion)
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .foregroundStyle(JedaColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private var showsAIReply: Bool {
        switch aiReplyState {
        case .idle: false
        case .loading, .loaded, .failed: true
        }
    }

    private var conversationSection: some View {
        VStack(alignment: .leading, spacing: JedaSpacing.md) {
            if let submittedText {
                userMessageBubble(submittedText)
            }
            if showsAIReply {
                aiMessageBubble
            }
        }
    }

    private func userMessageBubble(_ text: String) -> some View {
        HStack {
            Spacer(minLength: JedaSpacing.xl)

            Text(text)
                .font(JedaTypography.body)
                .foregroundStyle(Color.white)
                .padding(.horizontal, JedaSpacing.md)
                .padding(.vertical, JedaSpacing.sm + 2)
                .background(JedaColor.sage)
                .clipShape(RoundedRectangle(cornerRadius: JedaRadius.card, style: .continuous))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Kamu menulis: \(text)")
    }

    private var aiMessageBubble: some View {
        HStack(alignment: .top, spacing: JedaSpacing.sm) {
            ZStack {
                Circle()
                    .fill(JedaColor.sage.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(JedaColor.sage)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                Text("Jeda · AI Cloud")
                    .font(JedaTypography.caption)
                    .foregroundStyle(JedaColor.textSecondary)

                aiReplyContent
                    .padding(.horizontal, JedaSpacing.md)
                    .padding(.vertical, JedaSpacing.sm + 2)
                    .background(JedaColor.elevatedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: JedaRadius.card, style: .continuous))
            }

            Spacer(minLength: JedaSpacing.xl)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var aiReplyContent: some View {
        switch aiReplyState {
        case .idle:
            EmptyView()
        case .loading:
            HStack(spacing: JedaSpacing.sm) {
                ProgressView()
                Text("Sedang membalas...")
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textSecondary)
            }
        case .loaded(let text):
            Text(text)
                .font(JedaTypography.body)
                .foregroundStyle(JedaColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        case .failed(let message):
            VStack(alignment: .leading, spacing: JedaSpacing.sm) {
                Text(message)
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textSecondary)

                JedaButton("Coba lagi", kind: .secondary, isLoading: isRetrying) {
                    retryReflection()
                }
                .disabled(isRetrying)
                .accessibilityLabel("Coba kirim ulang refleksi ke AI")
            }
        }
    }

    private var canSubmit: Bool {
        !reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var hasSubmitted: Bool {
        submittedText != nil
    }

    private var isAIReplying: Bool {
        if isRetrying { return true }
        if case .loading = aiReplyState { return true }
        return false
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: JedaSpacing.md) {
            if !hasSubmitted {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $reflectionText)
                        .font(JedaTypography.body)
                        .foregroundStyle(JedaColor.textPrimary)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 200)
                        .padding(JedaSpacing.md)
                        .background(JedaColor.elevatedBackground)
                        .clipShape(RoundedRectangle(cornerRadius: JedaRadius.card, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: JedaRadius.card, style: .continuous)
                                .stroke(JedaColor.separator, lineWidth: 1)
                        }
                        .accessibilityLabel("Tulis refleksimu di sini")

                    if reflectionText.isEmpty {
                        Text("Lanjut cerita...")
                            .font(JedaTypography.body)
                            .foregroundStyle(JedaColor.textSecondary)
                            .padding(.top, JedaSpacing.md + 8)
                            .padding(.leading, JedaSpacing.md + 4)
                            .allowsHitTesting(false)
                    }
                }
            }

            if hasSubmitted {
                if !isAIReplying {
                    JedaButton("Simpan", kind: .primary, isLoading: isSaving) {
                        handleSaveTapped()
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                HStack(spacing: JedaSpacing.md) {
                    JedaButton("Simpan", kind: .secondary, isLoading: isSaving) {
                        handleSaveTapped()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!canSubmit)

                    JedaButton("Kirim", kind: .primary) {
                        handleSendTapped()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!canSubmit)
                }
            }
        }
    }

    private func handleSendTapped() {
        if consentStore.status() == .granted {
            sendReflection()
        } else {
            showConsentSheet = true
        }
    }

    private func sendReflection() {
        guard let aiService else {
            submittedText = reflectionText
            aiReplyState = .failed("Layanan AI belum tersedia.")
            return
        }

        let textToSend = reflectionText
        submittedText = textToSend
        aiReplyState = .loading
        Task {
            do {
                let reply = try await aiService.generateReflection(
                    for: textToSend,
                    detectedEmotion: emotion.rawValue
                )
                aiReplyState = .loaded(reply)
            } catch {
                JedaAIReflectionLog.reflectionReplyFailed(error)
                let detail = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                aiReplyState = .failed(detail)
            }
        }
    }

    private func retryReflection() {
        guard let aiService else { return }
        isRetrying = true
        let textToSend = reflectionText
        Task {
            do {
                let reply = try await aiService.generateReflection(
                    for: textToSend,
                    detectedEmotion: emotion.rawValue
                )
                aiReplyState = .loaded(reply)
            } catch {
                JedaAIReflectionLog.reflectionReplyFailed(error)
                let detail = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                aiReplyState = .failed(detail)
            }
            isRetrying = false
        }
    }

    private func handleSaveTapped() {
        Task { await saveAndDismiss() }
    }

    private func saveAndDismiss() async {
        isSaving = true
        defer { isSaving = false }

        try? await Task.sleep(for: .milliseconds(600))

        let aiReplyText: String? = {
            if case .loaded(let text) = aiReplyState { return text }
            return nil
        }()

        let entry = ReflectionEntry(
            journalExcerpt: journalExcerpt,
            mood: mood,
            emotion: emotion,
            confidence: confidence,
            reflectionQuestion: reflectionQuestion,
            reflectionText: reflectionText,
            aiReplyText: aiReplyText
        )
        onSave(entry)
        dismiss()
    }

    private var highlightedKeyword: String {
        JedaOnDeviceReflection.keyword(from: journalExcerpt)
    }
}

#Preview("Tab – empty state") {
    JedaReflectionView()
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
