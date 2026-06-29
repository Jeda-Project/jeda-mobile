/**
 * Scope: JedaReflectionRowView.swift
 * Purpose: List row component displaying a brief preview of a single reflection entry.
 */

import SwiftUI

struct ReflectionRowView: View {
    let entry: ReflectionEntry

    var body: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.10)) {
            VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                HStack {
                    Text(entry.formattedDate)
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(JedaColor.sage)
                        .accessibilityHidden(true)
                }

                Text(entry.reflectionQuestion)
                    .font(JedaTypography.headline)
                    .foregroundStyle(JedaColor.textPrimary)
                    .lineLimit(2)

                if let reflectionText = entry.reflectionText {
                    Text(reflectionText)
                        .font(JedaTypography.body)
                        .foregroundStyle(JedaColor.textSecondary)
                        .lineLimit(2)
                }
            }
        }
    }
}

struct ReflectionSkeletonRow: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.05)) {
            VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                HStack {
                    Text(" ")
                        .font(JedaTypography.caption)
                        .frame(width: 90, alignment: .leading)
                        .overlay { bar(width: 90) }
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .hidden()
                        .accessibilityHidden(true)
                        .overlay { bar(width: 16) }
                }

                twoLineBars(longWidth: .infinity, shortWidth: 200, font: JedaTypography.headline)

                twoLineBars(longWidth: .infinity, shortWidth: 160, font: JedaTypography.body)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                phase = 1
            }
        }
    }

    private func twoLineBars(longWidth: CGFloat, shortWidth: CGFloat, font: Font) -> some View {
        Text("Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore")
            .font(font)
            .lineLimit(2)
            .hidden()
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay {
                VStack(spacing: 0) {
                    bar(width: longWidth)
                    bar(width: shortWidth)
                }
            }
    }

    private func skeletonBar(width: CGFloat, font: Font) -> some View {
        Text("A")
            .font(font)
            .hidden()
            .frame(maxWidth: width == .infinity ? .infinity : width, alignment: .leading)
            .overlay { bar(width: width) }
    }

    private func bar(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(JedaColor.textSecondary.opacity(0.12 + 0.08 * phase))
            .frame(maxWidth: width == .infinity ? .infinity : width, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 2)
    }
}
