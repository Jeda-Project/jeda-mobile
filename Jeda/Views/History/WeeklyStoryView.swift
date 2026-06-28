//
//  WeeklyStoryView.swift
//  Jeda
//

import SwiftUI

struct WeeklyStoryView: View {
    let week: WeekSummary
    @State private var currentPage = 0

    var body: some View {
        VStack(spacing: JedaSpacing.lg) {
            TabView(selection: $currentPage) {
                ForEach(Array(week.storyPages.enumerated()), id: \.element.id) { index, page in
                    storyPage(page, index: index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            if currentPage < week.storyPages.count - 1 {
                JedaButton("Next", systemImage: "arrow.right", kind: .secondary) {
                    withAnimation {
                        currentPage += 1
                    }
                }
                .padding(.horizontal, JedaSpacing.lg)
            }
        }
        .padding(.vertical, JedaSpacing.lg)
        .background { JedaScreenBackground() }
        .navigationTitle("Refleksi Mingguan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("\(currentPage + 1)/\(week.storyPages.count)")
                    .font(JedaTypography.caption)
                    .foregroundStyle(JedaColor.textSecondary)
                    .accessibilityLabel("Halaman \(currentPage + 1) dari \(week.storyPages.count)")
            }
        }
    }

    private func storyPage(_ page: WeeklyStoryPage, index: Int) -> some View {
        ScrollView {
            JedaGlassSurface(tint: JedaColor.sage.opacity(0.12)) {
                VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                    HStack(spacing: JedaSpacing.md) {
                        Image(systemName: page.symbol)
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundStyle(JedaColor.sage)
                            .frame(width: 44, height: 44)
                            .jedaGlassEffect(
                                tint: JedaColor.sage.opacity(0.16),
                                in: Circle()
                            )

                        Text(page.title)
                            .font(JedaTypography.title)
                            .foregroundStyle(JedaColor.textPrimary)
                    }

                    Text(page.body)
                        .font(.system(.title3, design: .rounded))
                        .foregroundStyle(JedaColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(6)
                }
            }
            .padding(.horizontal, JedaSpacing.lg)
            .padding(.top, JedaSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(page.title). \(page.body)")
    }
}

#Preview {
    NavigationStack {
        WeeklyStoryView(week: HistorySampleData.currentWeek)
    }
}
