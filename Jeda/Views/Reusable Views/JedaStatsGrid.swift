/**
 * Scope: JedaStatsGrid.swift
 * Purpose: Grid component displaying weekly statistics for check-ins, words written, and AI reflections.
 */

import SwiftUI

struct JedaStatsGrid: View {
    let stats: WeeklyStats

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: JedaSpacing.md),
                GridItem(.flexible(), spacing: JedaSpacing.md),
                GridItem(.flexible(), spacing: JedaSpacing.md)
            ],
            spacing: JedaSpacing.md
        ) {
            statCell(title: "Kontemplasi", value: "\(stats.checkIns)", symbol: "checkmark.circle")
            statCell(title: "Kata ditulis", value: "\(stats.wordsWritten)", symbol: "text.word.spacing")
            statCell(title: "Refleksi AI", value: "\(stats.aiReflections)", symbol: "sparkles")
        }
    }

    private func statCell(title: String, value: String, symbol: String) -> some View {
        JedaGlassSurface(
            cornerRadius: JedaRadius.control,
            tint: JedaColor.sage.opacity(0.10),
            padding: JedaSpacing.md
        ) {
            VStack(alignment: .leading, spacing: JedaSpacing.sm) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(JedaColor.sage)
                    .accessibilityHidden(true)

                Text(value)
                    .font(JedaTypography.title)
                    .foregroundStyle(JedaColor.textPrimary)

                Text(title)
                    .font(JedaTypography.caption)
                    .foregroundStyle(JedaColor.textSecondary)
            }
        }
    }
}
