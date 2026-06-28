//
//  JedaHistoryComponents.swift
//  Jeda
//

import SwiftUI

struct JedaProgressBar: View {
    let progress: Double
    let label: String
    let valueText: String

    var body: some View {
        VStack(alignment: .leading, spacing: JedaSpacing.sm) {
            HStack {
                Text(label)
                    .font(JedaTypography.caption)
                    .foregroundStyle(JedaColor.textSecondary)

                Spacer()

                Text(valueText)
                    .font(JedaTypography.caption)
                    .foregroundStyle(JedaColor.textPrimary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(JedaColor.separator.opacity(0.35))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [JedaColor.sage, JedaColor.clay.opacity(0.85)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, proxy.size.width * min(max(progress, 0), 1)))
                }
            }
            .frame(height: 8)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityValue(valueText)
        }
    }
}

struct JedaTopicChip: View {
    let title: String

    var body: some View {
        Text(title)
            .font(JedaTypography.caption)
            .foregroundStyle(JedaColor.textPrimary)
            .padding(.horizontal, JedaSpacing.md)
            .padding(.vertical, JedaSpacing.sm)
            .jedaGlassEffect(
                tint: JedaColor.dustyBlue.opacity(0.14),
                in: Capsule()
            )
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
        Image(systemName: mood.symbol)
            .font(.system(size: size * 0.42, weight: .semibold, design: .rounded))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(mood.tint)
            .frame(width: size, height: size)
            .jedaGlassEffect(
                tint: mood.tint.opacity(0.18),
                in: Circle()
            )
            .accessibilityLabel("Mood \(mood.historyLabel)")
    }
}

struct JedaThisWeekCard: View {
    let week: WeekSummary

    var body: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.14)) {
            VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                HStack {
                    Label("Minggu Ini", systemImage: "calendar")
                        .font(JedaTypography.headline)
                        .foregroundStyle(JedaColor.textPrimary)

                    Spacer()

                    Text(week.dateRangeText)
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)
                }

                HStack(spacing: JedaSpacing.lg) {
                    JedaMoodBadge(mood: week.overallMood, size: 64)

                    VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                        Text(week.moodLabel)
                            .font(JedaTypography.title)
                            .foregroundStyle(JedaColor.textPrimary)

                        Text(week.summaryPhrase)
                            .font(JedaTypography.body)
                            .foregroundStyle(JedaColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                JedaProgressBar(
                    progress: week.checkInProgress,
                    label: "Check-ins",
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
            tint: JedaColor.dustyBlue.opacity(0.10),
            isInteractive: true,
            padding: JedaSpacing.md
        ) {
            HStack(spacing: JedaSpacing.md) {
                JedaMoodBadge(mood: week.overallMood, size: 44)

                VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                    Text(week.dateRangeText)
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)

                    Text(week.summaryPhrase)
                        .font(JedaTypography.headline)
                        .foregroundStyle(JedaColor.textPrimary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: JedaSpacing.xs) {
                    Text("Week \(week.weekNumber)")
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)

                    Text("\(week.checkInCount)/\(week.totalDays)")
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.sage)
                }
            }
        }
    }
}

struct JedaEntryRowCard: View {
    let entry: JournalEntry

    var body: some View {
        JedaGlassSurface(
            cornerRadius: JedaRadius.control,
            tint: entry.mood.tint.opacity(0.10),
            isInteractive: true,
            padding: JedaSpacing.md
        ) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                HStack(spacing: JedaSpacing.sm) {
                    JedaMoodBadge(mood: entry.mood, size: 36)

                    Text(entry.formattedTime)
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)

                    Spacer()
                }

                Text(entry.title)
                    .font(JedaTypography.headline)
                    .foregroundStyle(JedaColor.textPrimary)

                Text(entry.snippet)
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                if let question = entry.reflectionQuestion {
                    VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                        Text("AI Reflection")
                            .font(JedaTypography.caption)
                            .foregroundStyle(JedaColor.sage)

                        Text(question)
                            .font(JedaTypography.body)
                            .foregroundStyle(JedaColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(JedaSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: JedaRadius.chip, style: .continuous)
                            .fill(JedaColor.sage.opacity(0.08))
                    }
                }
            }
        }
    }
}

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
            statCell(title: "Check-ins", value: "\(stats.checkIns)", symbol: "checkmark.circle")
            statCell(title: "Kata ditulis", value: "\(stats.wordsWritten)", symbol: "text.word.spacing")
            statCell(title: "Refleksi AI", value: "\(stats.aiReflections)", symbol: "sparkles")
        }
    }

    private func statCell(title: String, value: String, symbol: String) -> some View {
        JedaGlassSurface(cornerRadius: JedaRadius.control, tint: JedaColor.clay.opacity(0.10), padding: JedaSpacing.md) {
            VStack(alignment: .leading, spacing: JedaSpacing.sm) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(JedaColor.clay)

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

struct JedaWordCloudView: View {
    let words: [String]

    var body: some View {
        FlowLayout(spacing: JedaSpacing.sm) {
            ForEach(words, id: \.self) { word in
                Text(word)
                    .font(.system(size: wordFontSize(for: word), weight: .semibold, design: .rounded))
                    .foregroundStyle(wordColor(for: word))
                    .padding(.horizontal, JedaSpacing.sm)
                    .padding(.vertical, JedaSpacing.xs)
            }
        }
    }

    private func wordFontSize(for word: String) -> CGFloat {
        switch word.count {
        case ...4: 22
        case 5...7: 18
        default: 15
        }
    }

    private func wordColor(for word: String) -> Color {
        switch word {
        case "takut", "deadline": JedaColor.terracotta.opacity(0.85)
        case "lega", "deploy": JedaColor.sage
        default: JedaColor.dustyBlue
        }
    }
}

struct JedaCheckInRhythmView: View {
    let rhythm: [Bool]
    let weekStart: Date

    var body: some View {
        HStack(spacing: JedaSpacing.sm) {
            ForEach(Array(rhythm.enumerated()), id: \.offset) { index, checkedIn in
                VStack(spacing: JedaSpacing.xs) {
                    Text(dayLabel(for: index))
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(JedaColor.textSecondary)

                    ZStack {
                        Circle()
                            .fill(checkedIn ? JedaColor.sage.opacity(0.18) : JedaColor.separator.opacity(0.20))
                            .frame(width: 34, height: 34)

                        if checkedIn {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(JedaColor.sage)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func dayLabel(for index: Int) -> String {
        guard let date = Calendar.current.date(byAdding: .day, value: index, to: weekStart) else {
            return "-"
        }
        return HistoryFormatting.dayAbbreviation(for: date).prefix(3).uppercased()
    }
}

struct JedaMoodBreakdownView: View {
    let items: [MoodBreakdownItem]

    private var total: Int {
        max(items.map(\.count).reduce(0, +), 1)
    }

    var body: some View {
        HStack(spacing: JedaSpacing.lg) {
            ZStack {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    Circle()
                        .trim(from: trimStart(for: index), to: trimEnd(for: index))
                        .stroke(item.mood.tint, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
            }
            .frame(width: 96, height: 96)

            VStack(alignment: .leading, spacing: JedaSpacing.sm) {
                ForEach(items) { item in
                    HStack(spacing: JedaSpacing.sm) {
                        Circle()
                            .fill(item.mood.tint)
                            .frame(width: 10, height: 10)

                        Text(item.mood.historyLabel)
                            .font(JedaTypography.caption)
                            .foregroundStyle(JedaColor.textPrimary)

                        Spacer()

                        Text("\(item.count)")
                            .font(JedaTypography.caption)
                            .foregroundStyle(JedaColor.textSecondary)
                    }
                }
            }
        }
    }

    private func trimStart(for index: Int) -> CGFloat {
        let preceding = items.prefix(index).map(\.count).reduce(0, +)
        return CGFloat(preceding) / CGFloat(total)
    }

    private func trimEnd(for index: Int) -> CGFloat {
        let including = items.prefix(index + 1).map(\.count).reduce(0, +)
        return CGFloat(including) / CGFloat(total)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: JedaSpacing.md) {
            JedaThisWeekCard(week: HistorySampleData.currentWeek)
            JedaWeekRowCard(week: HistorySampleData.weeks[1])
            JedaEntryRowCard(entry: HistorySampleData.currentWeek.entries[0])
            JedaStatsGrid(stats: HistorySampleData.currentWeek.stats)
        }
        .padding()
    }
    .background { JedaScreenBackground() }
}
