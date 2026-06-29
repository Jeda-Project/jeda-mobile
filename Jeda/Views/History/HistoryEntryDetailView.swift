/**
 * Scope: HistoryEntryDetailView.swift
 * Purpose: Detail screen displaying the full content of a single historical journal entry.
 */

import SwiftUI

struct HistoryEntryDetailView: View {
    let entry: JournalEntry
    let relatedEntries: [JournalEntry]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JedaSpacing.xl) {
                pageTitleSection
                EntryBodyCard(entry: entry)
                EntryEmotionResultCard(entry: entry)
                EntryReflectionCard(entry: entry)

                if !relatedEntries.isEmpty {
                    relatedMomentsSection
                }

                EntryInsightCard()
            }
            .padding(.horizontal, JedaSpacing.lg)
            .padding(.vertical, JedaSpacing.xl)
        }
        .background { JedaScreenBackground() }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var pageTitleSection: some View {
        VStack(alignment: .leading, spacing: JedaSpacing.xs) {
            Text("Hasil Analisis")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(JedaColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(HistoryFormatting.fullDateTimeString(for: entry.timestamp))
                .font(JedaTypography.caption)
                .foregroundStyle(JedaColor.textSecondary)
        }
    }

    private var relatedMomentsSection: some View {
        JedaSection("Momen Terkait") {
            VStack(spacing: JedaSpacing.md) {
                ForEach(relatedEntries) { related in
                    JedaEntryRowCard(entry: related)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HistoryEntryDetailView(
            entry: PreviewStubs.entry,
            relatedEntries: [PreviewStubs.entry]
        )
    }
}
