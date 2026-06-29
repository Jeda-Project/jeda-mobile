/**
 * Scope: JedaReflectionDetailSections.swift
 * Purpose: SwiftUI section components composing the reflection entry detail screen.
 */

import SwiftUI

extension JedaReflectionDetailView {
    var summarySection: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.08)) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                HStack(spacing: JedaSpacing.xs) {
                    Image(systemName: "doc.text").font(.system(size: 10, weight: .semibold)).accessibilityHidden(true)
                    Text("Kontemplasi Harianmu").font(JedaTypography.caption)
                }
                .foregroundStyle(JedaColor.textSecondary)
                Divider()
                HStack(spacing: JedaSpacing.sm) {
                    ZStack {
                        Circle().fill(JedaColor.sage.opacity(0.15)).frame(width: 40, height: 40)
                        Image(systemName: entry.mood.symbol)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(JedaColor.sage).accessibilityHidden(true)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mood hari itu").font(JedaTypography.caption).foregroundStyle(JedaColor.textSecondary)
                        Text(entry.mood.title).font(JedaTypography.headline).foregroundStyle(JedaColor.textPrimary)
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

    var resultSection: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.10)) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                HStack(spacing: JedaSpacing.xs) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 10, weight: .semibold))
                        .accessibilityHidden(true)
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
                            .accessibilityHidden(true)
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
                            .accessibilityHidden(true)
                        Text("AI Bisa Salah")
                            .font(JedaTypography.caption)
                    }
                    .foregroundStyle(JedaColor.textSecondary)
                }
            }
        }
    }

    var reflectionSection: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.12)) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                HStack(spacing: JedaSpacing.xs) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 10, weight: .semibold))
                        .accessibilityHidden(true)
                    Text("Refleksi")
                        .font(JedaTypography.caption)
                }
                .foregroundStyle(JedaColor.textSecondary)

                Divider()

                Text(entry.reflectionQuestion)
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if let reflectionText = entry.reflectionText {
                    Divider()
                    Text("Refleksimu")
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)
                    Text(reflectionText)
                        .font(JedaTypography.body)
                        .foregroundStyle(JedaColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let aiReply = entry.aiReplyText, !aiReply.isEmpty {
                    Divider()
                    HStack(spacing: JedaSpacing.xs) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10, weight: .semibold))
                            .accessibilityHidden(true)
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
