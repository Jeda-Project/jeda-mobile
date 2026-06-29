/**
 * Scope: JedaEntryRowCard.swift
 * Purpose: Card component displaying a single journal entry row in History feature lists.
 */
import SwiftUI

struct JedaEntryRowCard: View {
    let entry: JournalEntry
    var body: some View {
        JedaGlassSurface(
            cornerRadius: JedaRadius.control,
            tint: JedaColor.sage.opacity(0.08),
            isInteractive: true,
            padding: JedaSpacing.lg
        ) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                HStack(spacing: JedaSpacing.sm) {
                    JedaMoodBadge(mood: entry.mood, size: 36)
                    Text(HistoryFormatting.fullDateTimeString(for: entry.timestamp)).font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)
                    Spacer()
                }
                VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                    Text(
                        entry.reflectionQuestion
                            ?? JedaOnDeviceReflection.generate(from: entry.snippet, mood: entry.mood)
                    )
                    .font(JedaTypography.headline).foregroundStyle(JedaColor.textPrimary).lineLimit(2)
                    Text(entry.snippet).font(JedaTypography.body).foregroundStyle(JedaColor.textSecondary).lineLimit(2)

                    Divider()
                        .overlay(JedaColor.separator)
                        .padding(.vertical, JedaSpacing.xs)

                    HStack {
                        Spacer()
                        Text("Lihat Selengkapnya")
                            .font(JedaTypography.caption)
                            .foregroundStyle(JedaColor.sage)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(JedaColor.sage)
                            .accessibilityHidden(true)
                    }
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        JedaEntryRowCard(entry: PreviewStubs.entry)
            .padding()
    }.background { JedaScreenBackground() }
}
