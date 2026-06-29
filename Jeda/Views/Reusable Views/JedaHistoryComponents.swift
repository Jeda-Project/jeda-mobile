/**
 * Scope: JedaHistoryComponents.swift
 * Purpose: Shared UI components reused across History feature screens.
 */
import SwiftUI

struct JedaProgressBar: View {
    let progress: Double
    let label: String
    let valueText: String
    var body: some View {
        VStack(alignment: .leading, spacing: JedaSpacing.sm) {
            HStack {
                Text(label).font(JedaTypography.caption).foregroundStyle(JedaColor.textSecondary)
                Spacer()
                Text(valueText).font(JedaTypography.caption).foregroundStyle(JedaColor.textPrimary)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(JedaColor.separator.opacity(0.35))
                    Capsule().fill(
                        LinearGradient(
                            colors: [JedaColor.sage, JedaColor.clay.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    ).frame(width: max(8, proxy.size.width * min(max(progress, 0), 1)))
                }
            }.frame(height: 8).accessibilityElement(children: .ignore)
                .accessibilityLabel(label).accessibilityValue(valueText)
        }
    }
}

struct JedaTopicChip: View {
    let title: String
    var body: some View {
        Text(title).font(JedaTypography.caption).foregroundStyle(JedaColor.textPrimary)
            .padding(.horizontal, JedaSpacing.md).padding(.vertical, JedaSpacing.sm)
            .jedaGlassEffect(tint: JedaColor.sage.opacity(0.14), in: Capsule()).shadow(color: .clear, radius: 0)
    }
}

struct JedaMoodBadge: View {
    let mood: JedaMood
    let size: CGFloat
    init(mood: JedaMood, size: CGFloat = 52) {
        self.mood = mood
        self.size = size
    }

    var body: some View {
        Image(systemName: mood.symbol).font(.system(size: size * 0.42, weight: .semibold, design: .rounded))
            .symbolRenderingMode(.hierarchical).foregroundStyle(mood.tint).frame(width: size, height: size)
            .jedaGlassEffect(tint: mood.tint.opacity(0.18), in: Circle())
            .accessibilityLabel("Mood \(mood.historyLabel)")
    }
}

struct JedaThisWeekCard: View {
    let week: WeekSummary
    var body: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.14)) {
            VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                HStack {
                    Label("Minggu Ini", systemImage: "calendar").font(JedaTypography.headline)
                        .foregroundStyle(JedaColor.textPrimary)
                    Spacer()
                    Text(week.dateRangeText).font(JedaTypography.caption).foregroundStyle(JedaColor.textSecondary)
                }
                HStack(spacing: JedaSpacing.lg) {
                    JedaMoodBadge(mood: week.overallMood, size: 64)
                    VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                        Text(week.moodLabel).font(JedaTypography.title).foregroundStyle(JedaColor.textPrimary)
                        Text(week.summaryPhrase).font(JedaTypography.body).foregroundStyle(JedaColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                JedaProgressBar(
                    progress: week.checkInProgress,
                    label: "Kontemplasi",
                    valueText: "\(week.checkInCount)/\(week.totalDays)"
                )
            }
        }
    }
}

struct JedaWeekRowCard: View {
    let week: WeekSummary
    var body: some View {
        JedaGlassSurface(
            cornerRadius: JedaRadius.control,
            tint: JedaColor.sage.opacity(0.10),
            isInteractive: true,
            padding: JedaSpacing.md
        ) {
            HStack(spacing: JedaSpacing.md) {
                JedaMoodBadge(mood: week.overallMood, size: 44)
                VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                    Text(week.dateRangeText).font(JedaTypography.caption).foregroundStyle(JedaColor.textSecondary)
                    Text("\(week.checkInCount) Kontemplasi").font(JedaTypography.headline)
                        .foregroundStyle(JedaColor.textPrimary).lineLimit(2)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: JedaSpacing.md) {
            JedaThisWeekCard(week: PreviewStubs.week)
            JedaWeekRowCard(week: PreviewStubs.week)
            JedaEntryRowCard(entry: PreviewStubs.entry)
            JedaStatsGrid(stats: PreviewStubs.stats)
        }.padding()
    }.background { JedaScreenBackground() }
}
