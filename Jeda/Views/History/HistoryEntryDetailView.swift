//
//  HistoryEntryDetailView.swift
//  Jeda
//

import SwiftUI

struct HistoryEntryDetailView: View {
    let entry: JournalEntry
    let relatedEntries: [JournalEntry]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JedaSpacing.xl) {
                headerSection
                bodySection
                reflectionSection
                topicsSection
                actionsSection

                if !relatedEntries.isEmpty {
                    relatedMomentsSection
                }

                insightCard
            }
            .padding(.horizontal, JedaSpacing.lg)
            .padding(.vertical, JedaSpacing.xl)
        }
        .background { JedaScreenBackground() }
        .navigationBarTitleDisplayMode(.inline)
        .jedaHideTabBar()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {} label: {
                    Image(systemName: "bookmark")
                        .foregroundStyle(JedaColor.sage)
                }
                .accessibilityLabel("Simpan entry")
            }
        }
    }

    private var headerSection: some View {
        JedaGlassSurface(tint: entry.mood.tint.opacity(0.12)) {
            HStack(alignment: .top, spacing: JedaSpacing.md) {
                JedaMoodBadge(mood: entry.mood, size: 56)

                VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                    Text(entry.title)
                        .font(JedaTypography.title)
                        .foregroundStyle(JedaColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(entry.formattedDate)
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)

                    Text(entry.formattedTime)
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)
                }
            }
        }
    }

    private var bodySection: some View {
        JedaSection("Entry") {
            Text(entry.body)
                .font(JedaTypography.body)
                .foregroundStyle(JedaColor.textPrimary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var reflectionSection: some View {
        if let question = entry.reflectionQuestion {
            JedaSection("AI Reflection") {
                JedaReflectionCard(
                    phrase: entry.topics.first ?? "entry",
                    question: question
                ) {}
            }
        }
    }

    private var topicsSection: some View {
        JedaSection("Tags") {
            FlowLayout(spacing: JedaSpacing.sm) {
                ForEach(entry.topics, id: \.self) { topic in
                    JedaTopicChip(title: topic)
                }
            }
        }
    }

    private var actionsSection: some View {
        HStack(spacing: JedaSpacing.md) {
            actionButton(title: "Edit", symbol: "square.and.pencil") {}
            actionButton(title: "Share", symbol: "square.and.arrow.up") {}
            actionButton(title: "Hapus", symbol: "trash", isDestructive: true) {}
        }
    }

    private var relatedMomentsSection: some View {
        JedaSection("Related Moments") {
            VStack(spacing: JedaSpacing.md) {
                ForEach(relatedEntries) { related in
                    JedaEntryRowCard(entry: related)
                }
            }
        }
    }

    private var insightCard: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.14)) {
            HStack(alignment: .top, spacing: JedaSpacing.md) {
                Image(systemName: "lightbulb")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(JedaColor.sage)

                Text("Kamu sering menyebut kata \"takut\" di awal minggu, lalu beralih ke \"lega\" setelah satu task kecil selesai.")
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func actionButton(
        title: String,
        symbol: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(JedaTypography.caption)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.bordered)
        .tint(isDestructive ? JedaColor.terracotta : JedaColor.sage)
        .accessibilityLabel(title)
    }
}

#Preview {
    NavigationStack {
        HistoryEntryDetailView(
            entry: HistorySampleData.currentWeek.entries[5],
            relatedEntries: Array(HistorySampleData.currentWeek.entries.prefix(3))
        )
    }
}
