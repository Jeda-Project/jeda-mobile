/**
 * Scope: EmotionCheckInSections.swift
 * Purpose: SwiftUI section components for the emotion check-in step of the reflection flow.
 */

import SwiftUI

extension EmotionClassificationDemoView {
    var summarySection: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.08)) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                HStack(spacing: JedaSpacing.xs) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 10, weight: .semibold))
                        .accessibilityHidden(true)
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
                            .accessibilityHidden(true)
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

    var moodSliderSection: some View {
        JedaMoodCheckInSlider(step: $moodStep)
    }

    var journalSection: some View {
        JedaJournalInput(
            title: "Jurnal",
            prompt: "Bagaimana perasaanmu hari ini?",
            text: $journalText
        )
    }

    var analyzeButton: some View {
        Button {
            Task { await analyze() }
        } label: {
            Label("Pahami Perasaanku", systemImage: "sparkles")
                .frame(maxWidth: .infinity)
                .opacity(isAnalyzing ? 0.001 : 1)
                .background(alignment: .center) {
                    if isAnalyzing {
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
        .disabled(journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .allowsHitTesting(!isAnalyzing)
        .frame(maxWidth: .infinity)
    }
}
