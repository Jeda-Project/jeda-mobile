/**
 * Scope: EmotionResultSections.swift
 * Purpose: SwiftUI section components that display emotion classification results to the user.
 */

import SwiftUI

extension EmotionClassificationDemoView {
    var deeperReflectionButton: some View {
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

    var resetButton: some View {
        HStack(spacing: JedaSpacing.sm) {
            Button {
                resetForm()
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
            .allowsHitTesting(!isSaving)

            Button {
                Task { await saveEntry() }
            } label: {
                Text("Simpan")
                    .frame(maxWidth: .infinity)
                    .opacity(isSaving ? 0.001 : 1)
                    .background(alignment: .center) {
                        if isSaving {
                            ProgressView()
                                .tint(JedaColor.onAccent)
                                .scaleEffect(0.7)
                        }
                    }
            }
            .jedaProminentButtonStyle(tint: JedaColor.sage)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .font(JedaTypography.headline)
            .allowsHitTesting(!isSaving)
        }
    }

    func resultSection(_ result: EmotionClassificationResult) -> some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.10)) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                HStack(spacing: JedaSpacing.xs) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 10, weight: .semibold)).accessibilityHidden(true)
                    Text("Hasil Analisis Emosi").font(JedaTypography.caption)
                }.foregroundStyle(JedaColor.textSecondary)
                Divider()
                HStack(spacing: JedaSpacing.sm) {
                    ZStack {
                        Circle().fill(JedaColor.sage.opacity(0.15)).frame(width: 40, height: 40)
                        Image(systemName: result.label.systemImageName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(JedaColor.sage).accessibilityHidden(true)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.label.displayName)
                            .font(JedaTypography.headline).foregroundStyle(JedaColor.textPrimary)
                        Text(result.confidence.formatted(.percent.precision(.fractionLength(0))) + " keyakinan")
                            .font(JedaTypography.caption).foregroundStyle(JedaColor.textSecondary)
                    }
                    Spacer()
                }
                Divider()
                HStack {
                    Spacer()
                    HStack(spacing: JedaSpacing.xs) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 10, weight: .semibold)).accessibilityHidden(true)
                        Text("AI Bisa Salah").font(JedaTypography.caption)
                    }.foregroundStyle(JedaColor.textSecondary)
                }
            }
        }
    }

    func reflectionSection(_ question: String) -> some View {
        JedaGlassSurface(tint: JedaColor.dustyBlue.opacity(0.12)) {
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

                Text(question)
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    func errorSection(_ message: String) -> some View {
        JedaGlassSurface(tint: JedaColor.terracotta.opacity(0.12)) {
            Text(message)
                .font(JedaTypography.body)
                .foregroundStyle(JedaColor.terracotta)
        }
    }
}
