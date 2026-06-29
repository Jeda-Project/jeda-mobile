/**
 * Scope: DeeperReflectionViewModel.swift
 * Purpose: Manages AI reply state, send/retry/save operations for the deeper reflection flow.
 */

import Foundation
import Observation

enum AIReplyState {
    case idle
    case loading
    case loaded(String)
    case failed(String)
}

@Observable
@MainActor
final class DeeperReflectionViewModel {
    private(set) var aiReplyState: AIReplyState = .idle
    private(set) var submittedText: String?
    private(set) var isSaving = false
    private(set) var isRetrying = false

    private let aiService: (any AICompleting)?
    private let consentStore: any ReflectionAIConsentPersisting

    init(aiService: (any AICompleting)?, consentStore: any ReflectionAIConsentPersisting) {
        self.aiService = aiService
        self.consentStore = consentStore
    }

    var showsAIReply: Bool {
        switch aiReplyState {
        case .idle: false
        case .loading, .loaded, .failed: true
        }
    }

    var hasSubmitted: Bool {
        submittedText != nil
    }

    var isAIReplying: Bool {
        if isRetrying { return true }
        if case .loading = aiReplyState { return true }
        return false
    }

    func handleSendTapped(reflectionText: String, emotion: Emotion) -> Bool {
        if consentStore.status() == .granted {
            sendReflection(text: reflectionText, emotion: emotion)
            return false
        }
        return true
    }

    func sendReflection(text: String, emotion: Emotion) {
        guard let aiService else {
            submittedText = text
            aiReplyState = .failed("Layanan AI belum tersedia.")
            return
        }

        submittedText = text
        aiReplyState = .loading
        Task {
            do {
                let reply = try await aiService.generateReflection(
                    for: text,
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

    func retryReflection(text: String, emotion: Emotion) {
        guard let aiService else { return }
        isRetrying = true
        Task {
            do {
                let reply = try await aiService.generateReflection(
                    for: text,
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

    func saveEntry(
        reflectionText: String,
        journalExcerpt: String,
        mood: JedaMood,
        emotion: Emotion,
        confidence: Double,
        reflectionQuestion: String,
        onSave: (ReflectionEntry) -> Void,
        dismiss: () -> Void
    ) async {
        isSaving = true
        defer { isSaving = false }

        try? await Task.sleep(for: .milliseconds(600))

        let aiReplyText: String? = {
            if case let .loaded(text) = aiReplyState { return text }
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
}
