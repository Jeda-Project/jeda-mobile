/**
 * Scope: JedaMoodBreakdownViews.swift
 * Purpose: Components for mood breakdown donut chart, word cloud, and check-in rhythm visualization.
 */

import SwiftUI

struct JedaWordCloudView: View {
    let words: [String]

    var body: some View {
        FlowLayout(spacing: JedaSpacing.sm) {
            ForEach(words, id: \.self) { word in
                Text(word)
                    .font(.system(size: wordFontSize(for: word), weight: .semibold, design: .rounded))
                    .foregroundStyle(JedaColor.textPrimary)
                    .padding(.horizontal, JedaSpacing.sm)
                    .padding(.vertical, JedaSpacing.xs)
            }
        }
    }

    private func wordFontSize(for word: String) -> CGFloat {
        switch word.count {
        case ...4: 22
        case 5 ... 7: 18
        default: 15
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
                            .fill(checkedIn ? JedaColor.sage : JedaColor.separator.opacity(0.20))
                            .frame(width: 34, height: 34)

                        if checkedIn {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(JedaColor.onAccent)
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
                        Image(systemName: item.mood.symbol)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(item.mood.tint)
                            .frame(width: 20, height: 20)

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
