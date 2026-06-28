//
//  WeeklySummaryView.swift
//  Jeda
//

import SwiftUI

struct WeeklySummaryView: View {
    let week: WeekSummary

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JedaSpacing.xl) {
                overallMoodSection
                moodTrendSection
                topTopicsSection
                checkInSection
                aiReflectionSection

                NavigationLink(value: HistoryDestination.weeklyStory(week.id)) {
                    JedaButton("Lihat Refleksi Lengkap", systemImage: "arrow.right", kind: .primary) {}
                }
                .buttonStyle(.plain)

                moodBreakdownSection
                topicChartSection
                memorableMomentsSection
                improvementsSection
                quoteSection
                statsSection
                wordCloudSection
                rhythmSection

                NavigationLink(value: HistoryDestination.dailyEntries(week.id)) {
                    JedaButton("Lihat Semua Entry dalam Minggu Ini", systemImage: "list.bullet", kind: .secondary) {}
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, JedaSpacing.lg)
            .padding(.vertical, JedaSpacing.xl)
        }
        .background { JedaScreenBackground() }
        .navigationTitle("Week \(week.weekNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Week \(week.weekNumber)")
                        .font(JedaTypography.headline)
                        .foregroundStyle(JedaColor.textPrimary)

                    Text(week.dateRangeText)
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(JedaColor.sage)
                }
                .accessibilityLabel("Bagikan ringkasan minggu")
            }
        }
    }

    private var shareText: String {
        "Ringkasan Week \(week.weekNumber) di Jeda: \(week.moodLabel) — \(week.aiReflectionSummary)"
    }

    private var overallMoodSection: some View {
        JedaGlassSurface(tint: week.overallMood.tint.opacity(0.14)) {
            VStack(spacing: JedaSpacing.md) {
                JedaMoodBadge(mood: week.overallMood, size: 72)

                Text(week.moodLabel)
                    .font(JedaTypography.display)
                    .foregroundStyle(JedaColor.textPrimary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var moodTrendSection: some View {
        JedaMoodTrendChartCard(
            title: "Mood Trend",
            subtitle: "Perjalanan mood 7 hari terakhir.",
            points: week.moodTrendPoints
        )
    }

    private var topTopicsSection: some View {
        JedaSection("Top Topics") {
            FlowLayout(spacing: JedaSpacing.sm) {
                ForEach(week.topTopics, id: \.self) { topic in
                    JedaTopicChip(title: topic)
                }
            }
        }
    }

    private var checkInSection: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.10)) {
            JedaProgressBar(
                progress: week.checkInProgress,
                label: "Check-ins",
                valueText: "\(week.checkInCount) dari \(week.totalDays) hari"
            )
        }
    }

    private var aiReflectionSection: some View {
        JedaSection("AI Reflection", subtitle: "Ringkasan") {
            JedaGlassSurface(tint: JedaColor.sage.opacity(0.12)) {
                VStack(alignment: .leading, spacing: JedaSpacing.md) {
                    Text(week.aiReflectionSummary)
                        .font(JedaTypography.body)
                        .foregroundStyle(JedaColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(week.aiReflectionLong)
                        .font(.system(.title3, design: .rounded, weight: .medium))
                        .foregroundStyle(JedaColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var topicChartSection: some View {
        JedaTopicBarChartCard(
            title: "Top Topics",
            subtitle: "Frekuensi topik dalam entry minggu ini.",
            items: week.topicChartItems
        )
    }

    private var moodBreakdownSection: some View {
        JedaSection("Mood Breakdown") {
            JedaGlassSurface(tint: JedaColor.dustyBlue.opacity(0.12)) {
                JedaMoodBreakdownView(items: week.moodBreakdown)
            }
        }
    }

    private var memorableMomentsSection: some View {
        JedaSection("Memorable Moments") {
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

    private var improvementsSection: some View {
        JedaSection("Things You Improved") {
            JedaGlassSurface(tint: JedaColor.clay.opacity(0.10)) {
                VStack(alignment: .leading, spacing: JedaSpacing.sm) {
                    ForEach(week.improvements, id: \.self) { item in
                        Label {
                            Text(item)
                                .font(JedaTypography.body)
                                .foregroundStyle(JedaColor.textPrimary)
                        } icon: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(JedaColor.sage)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var quoteSection: some View {
        if let quote = week.quoteOfWeek {
            JedaSection("Quote of the Week") {
                JedaGlassSurface(tint: JedaColor.clay.opacity(0.12)) {
                    HStack(alignment: .top, spacing: JedaSpacing.md) {
                        Image(systemName: "leaf")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundStyle(JedaColor.sage)

                        Text(quote)
                            .font(.system(.title3, design: .rounded, weight: .medium))
                            .foregroundStyle(JedaColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private var statsSection: some View {
        JedaSection("Stats") {
            JedaStatsGrid(stats: week.stats)
        }
    }

    private var wordCloudSection: some View {
        JedaSection("Word Cloud") {
            JedaGlassSurface(tint: JedaColor.dustyBlue.opacity(0.10)) {
                JedaWordCloudView(words: week.wordCloud)
            }
        }
    }

    private var rhythmSection: some View {
        JedaSection("Ritme Check-in") {
            JedaGlassSurface(tint: JedaColor.sage.opacity(0.10)) {
                VStack(alignment: .leading, spacing: JedaSpacing.md) {
                    Text("Emosi paling sering muncul")
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)

                    HStack(spacing: JedaSpacing.sm) {
                        ForEach(week.frequentEmotions, id: \.self) { symbol in
                            Image(systemName: symbol)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundStyle(JedaColor.dustyBlue)
                                .frame(width: 36, height: 36)
                                .jedaGlassEffect(
                                    tint: JedaColor.dustyBlue.opacity(0.12),
                                    in: Circle()
                                )
                        }
                    }

                    JedaCheckInRhythmView(rhythm: week.checkInRhythm, weekStart: week.startDate)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        WeeklySummaryView(week: HistorySampleData.currentWeek)
    }
}
