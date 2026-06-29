/**
 * Scope: JedaDeeperReflectionSections.swift
 * Purpose: SwiftUI section components composing the deeper reflection guided flow screens.
 */

import SwiftUI

extension JedaDeeperReflectionView {
    var excerptSection: some View {
        JedaGlassSurface(tint: nil) {
            VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                Label("Dari jurnal kamu hari ini:", systemImage: "book.closed")
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

    var aiQuestionSection: some View {
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
                        Text("Kamu menyebut \"\(JedaOnDeviceReflection.keyword(from: journalExcerpt))\" beberapa kali.")
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

    var conversationSection: some View {
        VStack(alignment: .leading, spacing: JedaSpacing.md) {
            if let submittedText = viewModel.submittedText {
                userMessageBubble(submittedText)
            }
            if viewModel.showsAIReply {
                aiMessageBubble
            }
        }
    }

    func userMessageBubble(_ text: String) -> some View {
        HStack {
            Spacer(minLength: JedaSpacing.xl)
            Text(text)
                .font(JedaTypography.body)
                .foregroundStyle(JedaColor.onAccent)
                .padding(.horizontal, JedaSpacing.md)
                .padding(.vertical, JedaSpacing.sm + 2)
                .background(JedaColor.sage)
                .clipShape(RoundedRectangle(cornerRadius: JedaRadius.card, style: .continuous))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Kamu menulis: \(text)")
    }

    var aiMessageBubble: some View {
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
                    Text("Jeda · AI Cloud")
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)

                    aiReplyContent
                        .padding(.top, 2)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}
