/**
 * Scope: JedaWeeklyPatternCard.swift
 * Purpose: Card component visualizing a user's weekly emotion pattern summary.
 */

import SwiftUI

struct JedaWeeklyPatternCard: View {
    let topics: [String]
    let moodTrend: String
    let reliefNote: String

    var body: some View {
        JedaGlassSurface(tint: JedaColor.clay.opacity(0.12)) {
            VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                HStack {
                    Label("Pattern Tracker", systemImage: "chart.line.uptrend.xyaxis")
                        .font(JedaTypography.headline)
                        .foregroundStyle(JedaColor.textPrimary)

                    Spacer()
                }

                VStack(alignment: .leading, spacing: JedaSpacing.sm) {
                    Text("Topik yang muncul")
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)

                    FlowLayout(spacing: JedaSpacing.sm) {
                        ForEach(topics, id: \.self) { topic in
                            Text(topic)
                                .font(JedaTypography.caption)
                                .foregroundStyle(JedaColor.textPrimary)
                                .padding(.horizontal, JedaSpacing.md)
                                .padding(.vertical, JedaSpacing.sm)
                                .jedaGlassEffect(
                                    tint: JedaColor.sage.opacity(0.14),
                                    in: Capsule()
                                )
                                .shadow(color: .clear, radius: 0)
                        }
                    }
                }

                VStack(spacing: JedaSpacing.md) {
                    patternRow(
                        title: "Mood minggu ini",
                        value: moodTrend,
                        symbol: "waveform.path.ecg",
                        tint: JedaColor.sage
                    )

                    patternRow(
                        title: "Hal yang bikin lega",
                        value: reliefNote,
                        symbol: "leaf",
                        tint: JedaColor.sage
                    )
                }
            }
        }
    }

    private func patternRow(title: String, value: String, symbol: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: JedaSpacing.md) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                Text(title)
                    .font(JedaTypography.caption)
                    .foregroundStyle(JedaColor.textSecondary)

                Text(value)
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}
