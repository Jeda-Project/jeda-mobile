//
//  JedaCharts.swift
//  Jeda
//
//  Created by Codex on 28/06/26.
//

import Charts
import SwiftUI

struct JedaMoodTrendPoint: Identifiable {
    let day: String
    let score: Double

    var id: String { day }
}

struct JedaTopicChartItem: Identifiable {
    let topic: String
    let count: Int

    var id: String { topic }
}

struct JedaMoodTrendChartCard: View {
    let title: String
    let subtitle: String
    let points: [JedaMoodTrendPoint]

    var body: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.14)) {
            VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                chartHeader(
                    title: title,
                    subtitle: subtitle,
                    symbol: "chart.line.uptrend.xyaxis",
                    tint: JedaColor.sage
                )

                Chart(points) { point in
                    AreaMark(
                        x: .value("Hari", point.day),
                        yStart: .value("Batas bawah", 1),
                        yEnd: .value("Mood", point.score)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                JedaColor.sage.opacity(0.30),
                                JedaColor.sage.opacity(0.04)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    LineMark(
                        x: .value("Hari", point.day),
                        y: .value("Mood", point.score)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(JedaColor.sage)

                    PointMark(
                        x: .value("Hari", point.day),
                        y: .value("Mood", point.score)
                    )
                    .symbolSize(64)
                    .foregroundStyle(point.score >= 4 ? JedaColor.clay : JedaColor.dustyBlue)
                }
                .chartYScale(domain: 1...5)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.system(.caption2, design: .rounded, weight: .medium))
                            .foregroundStyle(JedaColor.textSecondary)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: [1, 3, 5]) { value in
                        AxisGridLine()
                            .foregroundStyle(JedaColor.separator)
                        AxisValueLabel {
                            if let score = value.as(Int.self) {
                                Text(label(for: score))
                                    .font(.system(.caption2, design: .rounded, weight: .medium))
                                    .foregroundStyle(JedaColor.textSecondary)
                            }
                        }
                    }
                }
                .chartPlotStyle { plotArea in
                    plotArea
                        .background(JedaColor.elevatedBackground.opacity(0.16))
                        .clipShape(RoundedRectangle(cornerRadius: JedaRadius.chip, style: .continuous))
                }
                .frame(height: 196)
                .accessibilityLabel(title)
                .accessibilityValue(accessibilitySummary)
            }
        }
    }

    private var accessibilitySummary: String {
        guard let first = points.first, let last = points.last else {
            return "Belum ada data mood"
        }

        return "Mood dari \(first.day) ke \(last.day), skor terakhir \(last.score.formatted()) dari 5"
    }

    private func label(for score: Int) -> String {
        switch score {
        case 1: "Berat"
        case 3: "Netral"
        case 5: "Ringan"
        default: "\(score)"
        }
    }
}

struct JedaTopicBarChartCard: View {
    let title: String
    let subtitle: String
    let items: [JedaTopicChartItem]

    var body: some View {
        JedaGlassSurface(tint: JedaColor.dustyBlue.opacity(0.14)) {
            VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                chartHeader(
                    title: title,
                    subtitle: subtitle,
                    symbol: "text.bubble",
                    tint: JedaColor.dustyBlue
                )

                Chart(items) { item in
                    BarMark(
                        x: .value("Jumlah", item.count),
                        y: .value("Topik", item.topic)
                    )
                    .cornerRadius(JedaRadius.chip)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                JedaColor.dustyBlue,
                                JedaColor.sage.opacity(0.78)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .annotation(position: .trailing, alignment: .leading) {
                        Text("\(item.count)x")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundStyle(JedaColor.textSecondary)
                    }
                }
                .chartXScale(domain: 0...maxCount)
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(JedaColor.textSecondary)
                    }
                }
                .chartPlotStyle { plotArea in
                    plotArea
                        .background(JedaColor.elevatedBackground.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: JedaRadius.chip, style: .continuous))
                }
                .frame(height: chartHeight)
                .accessibilityLabel(title)
                .accessibilityValue(accessibilitySummary)
            }
        }
    }

    private var maxCount: Int {
        (items.map(\.count).max() ?? 1) + 1
    }

    private var chartHeight: CGFloat {
        max(180, CGFloat(items.count) * 46)
    }

    private var accessibilitySummary: String {
        guard let topItem = items.max(by: { $0.count < $1.count }) else {
            return "Belum ada data topik"
        }

        return "Topik paling sering \(topItem.topic), \(topItem.count) kali"
    }
}

private func chartHeader(
    title: String,
    subtitle: String,
    symbol: String,
    tint: Color
) -> some View {
    HStack(alignment: .top, spacing: JedaSpacing.md) {
        Image(systemName: symbol)
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundStyle(tint)
            .frame(width: 38, height: 38)
            .jedaGlassEffect(
                tint: tint.opacity(0.16),
                in: Circle()
            )

        VStack(alignment: .leading, spacing: JedaSpacing.xs) {
            Text(title)
                .font(JedaTypography.headline)
                .foregroundStyle(JedaColor.textPrimary)

            Text(subtitle)
                .font(JedaTypography.body)
                .foregroundStyle(JedaColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }

        Spacer(minLength: 0)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: JedaSpacing.md) {
            JedaMoodTrendChartCard(
                title: "Mood 7 hari",
                subtitle: "Baca arah minggu, bukan nilai sempurna.",
                points: [
                    .init(day: "Sen", score: 2.0),
                    .init(day: "Sel", score: 2.4),
                    .init(day: "Rab", score: 3.0),
                    .init(day: "Kam", score: 2.7),
                    .init(day: "Jum", score: 3.5),
                    .init(day: "Sab", score: 4.0),
                    .init(day: "Min", score: 3.8)
                ]
            )

            JedaTopicBarChartCard(
                title: "Topik sering muncul",
                subtitle: "Kata yang berulang dari entry minggu ini.",
                items: [
                    .init(topic: "backlog", count: 5),
                    .init(topic: "fokus", count: 4),
                    .init(topic: "energi", count: 3),
                    .init(topic: "review", count: 2)
                ]
            )
        }
        .padding()
    }
    .background {
        JedaScreenBackground()
    }
}
