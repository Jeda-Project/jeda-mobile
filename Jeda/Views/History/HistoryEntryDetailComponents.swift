/**
 * Scope: HistoryEntryDetailComponents.swift
 * Purpose: Sub-view components for the history entry detail screen.
 */
import SwiftUI

struct EntryBodyCard: View {
    let entry: JournalEntry
    var body: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.08)) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                HStack(spacing: JedaSpacing.xs) {
                    Image(systemName: "doc.text").font(.system(size: 10, weight: .semibold)).accessibilityHidden(true)
                    Text("Kontemplasi Harianmu").font(JedaTypography.caption)
                }.foregroundStyle(JedaColor.textSecondary)
                Divider()
                HStack(spacing: JedaSpacing.sm) {
                    ZStack {
                        Circle().fill(entry.mood.tint.opacity(0.15)).frame(width: 40, height: 40)
                        Image(systemName: entry.mood.symbol).font(.system(size: 16, weight: .medium))
                            .foregroundStyle(entry.mood.tint).accessibilityHidden(true)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mood hari itu").font(JedaTypography.caption).foregroundStyle(JedaColor.textSecondary)
                        Text(entry.mood.title).font(JedaTypography.headline).foregroundStyle(JedaColor.textPrimary)
                    }
                }
                Divider()
                Text(entry.body).font(JedaTypography.body).foregroundStyle(JedaColor.textPrimary).lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct EntryEmotionResultCard: View {
    let entry: JournalEntry

    private var emotion: Emotion {
        switch entry.mood {
        case .heavy: .sadness
        case .low: .fear
        case .neutral: .love
        case .okay, .light: .happy
        }
    }

    var body: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.10)) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                HStack(spacing: JedaSpacing.xs) {
                    Image(systemName: "waveform.path.ecg").font(.system(size: 10, weight: .semibold))
                        .accessibilityHidden(true)
                    Text("Hasil Analisis Emosi").font(JedaTypography.caption)
                }.foregroundStyle(JedaColor.textSecondary)
                Divider()
                HStack(spacing: JedaSpacing.sm) {
                    ZStack {
                        Circle().fill(JedaColor.sage.opacity(0.15)).frame(width: 40, height: 40)
                        Image(systemName: emotion.systemImageName).font(.system(size: 18, weight: .medium))
                            .foregroundStyle(JedaColor.sage).accessibilityHidden(true)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(emotion.displayName).font(JedaTypography.headline).foregroundStyle(JedaColor.textPrimary)
                        Text("85% keyakinan").font(JedaTypography.caption).foregroundStyle(JedaColor.textSecondary)
                    }
                    Spacer()
                }
                Divider()
                HStack {
                    Spacer()
                    HStack(spacing: JedaSpacing.xs) {
                        Image(systemName: "info.circle.fill").font(.system(size: 10, weight: .semibold))
                            .accessibilityHidden(true)
                        Text("AI Bisa Salah").font(JedaTypography.caption)
                    }.foregroundStyle(JedaColor.textSecondary)
                }
            }
        }
    }
}

struct EntryReflectionCard: View {
    let entry: JournalEntry
    var body: some View {
        if let question = entry.reflectionQuestion {
            JedaGlassSurface(tint: JedaColor.sage.opacity(0.12)) {
                VStack(alignment: .leading, spacing: JedaSpacing.md) {
                    HStack(spacing: JedaSpacing.xs) {
                        Image(systemName: "bubble.left.and.bubble.right").font(.system(size: 10, weight: .semibold))
                            .accessibilityHidden(true)
                        Text("Refleksi").font(JedaTypography.caption)
                    }.foregroundStyle(JedaColor.textSecondary)
                    Divider()
                    Text(question).font(JedaTypography.body).foregroundStyle(JedaColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    if let reflectionText = entry.reflectionText {
                        Divider()
                        Text("Refleksimu").font(JedaTypography.caption).foregroundStyle(JedaColor.textSecondary)
                        Text(reflectionText).font(JedaTypography.body).foregroundStyle(JedaColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if let aiReply = entry.aiReplyText, !aiReply.isEmpty {
                        Divider()
                        HStack(spacing: JedaSpacing.xs) {
                            Image(systemName: "sparkles").font(.system(size: 10, weight: .semibold))
                                .accessibilityHidden(true)
                            Text("Balasan Jeda").font(JedaTypography.caption)
                        }.foregroundStyle(JedaColor.sage)
                        Text(aiReply).font(JedaTypography.body).foregroundStyle(JedaColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}

struct EntryInsightCard: View {
    var body: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.08)) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                HStack(spacing: JedaSpacing.xs) {
                    Image(systemName: "lightbulb.fill").font(.system(size: 10, weight: .semibold))
                        .accessibilityHidden(true)
                    Text("Insight Jeda").font(JedaTypography.caption)
                }.foregroundStyle(JedaColor.textSecondary)
                Divider()
                Text(
                    "Kamu sering menyebut kata \"takut\" di awal minggu, "
                        + "lalu beralih ke \"lega\" setelah satu task kecil selesai."
                ).font(JedaTypography.body).foregroundStyle(JedaColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
