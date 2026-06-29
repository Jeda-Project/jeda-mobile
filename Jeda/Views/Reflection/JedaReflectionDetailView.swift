/**
 * Scope: JedaReflectionDetailView.swift
 * Purpose: Detail screen showing the full content and emotion result of a saved reflection entry.
 */

import SwiftUI

struct JedaReflectionDetailView: View {
    let entry: ReflectionEntry
    @Environment(\.dismiss)
    private var dismiss

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
        .tint(JedaColor.textPrimary)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: JedaSpacing.xs) {
            Text("Hasil Analisis")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(JedaColor.textPrimary)

            Text(entry.formattedDate)
                .font(JedaTypography.caption)
                .foregroundStyle(JedaColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
