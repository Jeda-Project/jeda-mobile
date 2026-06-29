/**
 * Scope: WeeklySummaryDetailSections.swift
 * Purpose: SwiftUI section components composing the weekly summary detail screen.
 */

import SwiftUI

extension WeeklySummaryView {
    var topicChartSection: some View {
        JedaTopicBarChartCard(
            title: "Topik Utama",
            subtitle: "Frekuensi topik dalam entri minggu ini.",
            items: week.topicChartItems
        )
    }

    var moodBreakdownSection: some View {
        JedaSection("Rincian Mood") {
            JedaGlassSurface(tint: JedaColor.dustyBlue.opacity(0.12)) {
                JedaMoodBreakdownView(items: week.moodBreakdown)
            }
        }
    }

    var memorableMomentsSection: some View {
        JedaSection("Momen Berkesan") {
            if viewModel.isLoadingAI {
                JedaStateCard(kind: .loading)
            } else {
                VStack(spacing: JedaSpacing.md) {
                    ForEach(week.memorableMoments) { entry in
                        NavigationLink(value: HistoryDestination.entryDetail(entryID: entry.id, weekID: week.id)) {
                            JedaEntryRowCard(entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    var improvementsSection: some View {
        JedaSection("Peningkatanmu") {
            if viewModel.isLoadingAI {
                JedaStateCard(kind: .loading)
            } else if week.improvements.isEmpty {
                EmptyView()
            } else {
                JedaGlassSurface(tint: JedaColor.sage.opacity(0.10)) {
                    VStack(alignment: .leading, spacing: JedaSpacing.sm) {
                        ForEach(week.improvements, id: \.self) { item in
                            Label {
                                Text(item)
                                    .font(JedaTypography.body)
                                    .foregroundStyle(JedaColor.textPrimary)
                            } icon: {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(JedaColor.sage)
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder var quoteSection: some View {
        if viewModel.isLoadingAI {
            JedaSection("Kutipan Minggu Ini") {
                JedaStateCard(kind: .loading)
            }
        } else if let quote = week.quoteOfWeek {
            JedaSection("Kutipan Minggu Ini") {
                JedaGlassSurface(tint: JedaColor.sage.opacity(0.12)) {
                    HStack(alignment: .top, spacing: JedaSpacing.md) {
                        Image(systemName: "leaf")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundStyle(JedaColor.sage)
                            .accessibilityHidden(true)
                        Text(quote)
                            .font(.system(.title3, design: .rounded, weight: .medium))
                            .foregroundStyle(JedaColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    var statsSection: some View {
        JedaSection("Statistik") {
            JedaStatsGrid(stats: week.stats)
        }
    }

    var wordCloudSection: some View {
        JedaSection("Kata Sering Muncul") {
            JedaGlassSurface(tint: JedaColor.dustyBlue.opacity(0.10)) {
                JedaWordCloudView(words: week.wordCloud)
            }
        }
    }

    var rhythmSection: some View {
        JedaSection("Ritme Kontemplasi") {
            JedaGlassSurface(tint: JedaColor.sage.opacity(0.10)) {
                VStack(alignment: .leading, spacing: JedaSpacing.md) {
                    Text("Emosi paling sering muncul")
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)

                    HStack(spacing: JedaSpacing.md) {
                        ForEach(week.frequentEmotions, id: \.self) { symbol in
                            if let mood = JedaMood.allCases.first(where: { $0.symbol == symbol }) {
                                VStack(spacing: 4) {
                                    Image(systemName: symbol)
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                        .foregroundStyle(JedaColor.onAccent)
                                        .frame(width: 36, height: 36)
                                        .background(Circle().fill(mood.tint))
                                        .accessibilityLabel("Mood \(mood.title)")

                                    Text(mood.title)
                                        .font(.system(size: 10, weight: .medium, design: .rounded))
                                        .foregroundStyle(JedaColor.textSecondary)
                                }
                            } else {
                                Image(systemName: symbol)
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundStyle(JedaColor.dustyBlue)
                                    .frame(width: 36, height: 36)
                                    .jedaGlassEffect(
                                        tint: JedaColor.dustyBlue.opacity(0.12),
                                        in: Circle()
                                    )
                                    .accessibilityHidden(true)
                            }
                        }
                    }

                    JedaCheckInRhythmView(rhythm: week.checkInRhythm, weekStart: week.startDate)
                }
            }
        }
    }
}
