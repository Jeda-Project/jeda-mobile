//
//  JedaWeeklyPatternCard.swift
//  Jeda
//
//  Created by Codex on 27/06/26.
//

import SwiftUI

struct JedaWeeklyPatternCard: View {
    let topics: [String]
    let moodTrend: String
    let reliefNote: String

    var body: some View {
        JedaGlassSurface(tint: JedaColor.clay.opacity(0.12)) {
            VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                HStack {
                    Label("Pattern Tracker", systemImage: "chart.line.uptrend.xyaxis")
                        .font(JedaTypography.headline)
                        .foregroundStyle(JedaColor.textPrimary)

                    Spacer()
                }

                VStack(alignment: .leading, spacing: JedaSpacing.sm) {
                    Text("Topik yang muncul")
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)

                    FlowLayout(spacing: JedaSpacing.sm) {
                        ForEach(topics, id: \.self) { topic in
                            Text(topic)
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
                }

                VStack(spacing: JedaSpacing.md) {
                    patternRow(
                        title: "Mood minggu ini",
                        value: moodTrend,
                        symbol: "waveform.path.ecg",
                        tint: JedaColor.dustyBlue
                    )

                    patternRow(
                        title: "Hal yang bikin lega",
                        value: reliefNote,
                        symbol: "leaf",
                        tint: JedaColor.sage
                    )
                }
            }
        }
    }

    private func patternRow(title: String, value: String, symbol: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: JedaSpacing.md) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                Text(title)
                    .font(JedaTypography.caption)
                    .foregroundStyle(JedaColor.textSecondary)

                Text(value)
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        let maxWidth = proposal.width ?? 0
        let rows = rows(for: subviews, maxWidth: maxWidth)
        let height = rows.reduce(CGFloat.zero) { partial, row in
            partial + row.height
        } + CGFloat(max(rows.count - 1, 0)) * spacing

        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        let rows = rows(for: subviews, maxWidth: bounds.width)
        var y = bounds.minY

        for row in rows {
            var x = bounds.minX

            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(item.size)
                )
                x += item.size.width + spacing
            }

            y += row.height + spacing
        }
    }

    private func rows(for subviews: Subviews, maxWidth: CGFloat) -> [FlowRow] {
        guard maxWidth > 0 else { return [] }

        var rows: [FlowRow] = []
        var currentItems: [FlowItem] = []
        var currentWidth: CGFloat = 0
        var currentHeight: CGFloat = 0

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let itemWidth = currentItems.isEmpty ? size.width : size.width + spacing

            if currentWidth + itemWidth > maxWidth, !currentItems.isEmpty {
                rows.append(FlowRow(items: currentItems, height: currentHeight))
                currentItems = []
                currentWidth = 0
                currentHeight = 0
            }

            currentItems.append(FlowItem(index: index, size: size))
            currentWidth += currentItems.count == 1 ? size.width : size.width + spacing
            currentHeight = max(currentHeight, size.height)
        }

        if !currentItems.isEmpty {
            rows.append(FlowRow(items: currentItems, height: currentHeight))
        }

        return rows
    }

    private struct FlowItem {
        let index: Int
        let size: CGSize
    }

    private struct FlowRow {
        let items: [FlowItem]
        let height: CGFloat
    }
}
