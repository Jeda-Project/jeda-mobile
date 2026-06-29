/**
 * Scope: WeeklySummaryView.swift
 * Purpose: Weekly summary screen showing mood, trends, topics, kontemplasi, and AI reflection.
 */

import SwiftUI

struct WeeklySummaryView: View {
    @State var viewModel: WeeklySummaryViewModel
    @EnvironmentObject private var reflectionStore: ReflectionStore
    @Environment(\.aiServiceFast)
    private var aiService
    @Environment(\.summaryRepository)
    private var summaryRepository

    init(week: WeekSummary) {
        _viewModel = State(initialValue: WeeklySummaryViewModel(week: week))
    }

    var week: WeekSummary { viewModel.week }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JedaSpacing.xl) {
                overallMoodSection
                moodTrendSection
                topTopicsSection
                checkInSection
                aiReflectionSection

                moodBreakdownSection
                topicChartSection
                memorableMomentsSection
                improvementsSection
                quoteSection
                statsSection
                wordCloudSection
                rhythmSection
            }.padding(.horizontal, JedaSpacing.lg).padding(.vertical, JedaSpacing.xl)
        }.background { JedaScreenBackground() }.navigationTitle("Minggu \(week.weekNumber)")
            .navigationBarTitleDisplayMode(.inline).toolbar {
                ToolbarItem(placement: .principal) {
                    Text(week.dateRangeText).font(JedaTypography.headline).foregroundStyle(JedaColor.textPrimary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: shareText) {
                        Image(systemName: "square.and.arrow.up").foregroundStyle(JedaColor.textPrimary)
                            .accessibilityHidden(true)
                    }.accessibilityLabel("Bagikan ringkasan minggu")
                }
            }.task {
                await viewModel.loadIfNeeded(
                    reflectionStore: reflectionStore,
                    aiService: aiService,
                    summaryRepository: summaryRepository
                )
            }.onChange(of: reflectionStore.entriesFingerprint) { _, _ in
                guard week.isCurrentWeek else { return }
                Task {
                    await viewModel.reloadIfStale(
                        reflectionStore: reflectionStore,
                        aiService: aiService,
                        summaryRepository: summaryRepository
                    )
                }
            }
    }

    private var shareText: String {
        "Ringkasan Minggu \(week.weekNumber) di Jeda: \(week.moodLabel) — \(week.aiReflectionSummary)"
    }

    private var overallMoodSection: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.14)) {
            VStack(spacing: JedaSpacing.md) {
                JedaMoodBadge(mood: week.overallMood, size: 72)
                Text(week.moodLabel).font(JedaTypography.display).foregroundStyle(JedaColor.textPrimary)
                    .redacted(reason: viewModel.isLoadingAI ? .placeholder : [])
            }.frame(maxWidth: .infinity)
        }
    }

    private var moodTrendSection: some View {
        JedaMoodTrendChartCard(
            title: "Tren Mood",
            subtitle: "Perjalanan mood 7 hari terakhir.",
            points: week.moodTrendPoints
        )
    }

    private var topTopicsSection: some View {
        JedaSection("Topik Utama") {
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
                label: "Kontemplasi",
                valueText: "\(week.checkInCount) dari \(week.totalDays) hari"
            )
        }
    }

    private var aiReflectionSection: some View {
        JedaSection("Refleksi AI", subtitle: "Diringkas dengan bantuan AI") {
            if viewModel.isLoadingAI {
                JedaStateCard(kind: .loading)
            } else if viewModel.aiLoadFailed {
                JedaStateCard(
                    kind: .error,
                    message: viewModel.aiErrorMessage,
                    actionTitle: "Coba lagi"
                ) {
                    Task {
                        await viewModel.retry(
                            reflectionStore: reflectionStore,
                            aiService: aiService,
                            summaryRepository: summaryRepository
                        )
                    }
                }
            } else {
                JedaGlassSurface(tint: JedaColor.sage.opacity(0.12)) {
                    VStack(alignment: .leading, spacing: JedaSpacing.md) {
                        Text(week.aiReflectionSummary).font(JedaTypography.body).foregroundStyle(JedaColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("\"\(week.aiReflectionLong)\"").font(.system(.title3, design: .rounded, weight: .medium))
                            .italic().foregroundStyle(JedaColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        WeeklySummaryView(week: PreviewStubs.week).environmentObject(ReflectionStore())
    }
}
