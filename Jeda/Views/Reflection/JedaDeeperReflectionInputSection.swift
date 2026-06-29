/**
 * Scope: JedaDeeperReflectionInputSection.swift
 * Purpose: Input section component for the deeper reflection journal text entry step.
 */

import SwiftUI

extension JedaDeeperReflectionView {
    var inputSection: some View {
        VStack(alignment: .leading, spacing: JedaSpacing.md) {
            if !viewModel.hasSubmitted {
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
                            .foregroundStyle(JedaColor.textSecondary.opacity(0.5))
                            .padding(.top, JedaSpacing.md + 8)
                            .padding(.leading, JedaSpacing.md + 4)
                            .allowsHitTesting(false)
                    }
                }
            }

            if viewModel.hasSubmitted {
                if !viewModel.isAIReplying {
                    JedaButton("Simpan", kind: .primary, isLoading: viewModel.isSaving) {
                        Task {
                            await viewModel.saveEntry(
                                reflectionText: reflectionText,
                                journalExcerpt: journalExcerpt,
                                mood: mood,
                                emotion: emotion,
                                confidence: confidence,
                                reflectionQuestion: reflectionQuestion,
                                onSave: onSave,
                                dismiss: { dismiss() }
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                HStack(spacing: JedaSpacing.md) {
                    JedaButton("Simpan", kind: .secondary, isLoading: viewModel.isSaving) {
                        Task {
                            await viewModel.saveEntry(
                                reflectionText: reflectionText,
                                journalExcerpt: journalExcerpt,
                                mood: mood,
                                emotion: emotion,
                                confidence: confidence,
                                reflectionQuestion: reflectionQuestion,
                                onSave: onSave,
                                dismiss: { dismiss() }
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(canSubmit == false)

                    JedaButton("Kirim", kind: .primary) {
                        let needsConsent = viewModel.handleSendTapped(reflectionText: reflectionText, emotion: emotion)
                        if needsConsent { showConsentSheet = true }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(canSubmit == false)
                }
            }
        }
    }
}
