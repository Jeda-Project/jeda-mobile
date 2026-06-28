//
//  JedaOnboardingView.swift
//  Jeda
//
//  Created by Codex on 28/06/26.
//

import SwiftUI

struct JedaOnboardingView: View {
    private let pages = JedaOnboardingPage.placeholderPages
    let onFinish: () -> Void

    @State private var selectedPage = 0

    var body: some View {
        ZStack {
            JedaScreenBackground()

            Circle()
                .fill(pages[selectedPage].tint.opacity(0.3))
                .blur(radius: 120)
                .frame(width: 300, height: 300)
                .offset(y: -100)
                .animation(.easeInOut(duration: 0.6), value: selectedPage)

            VStack(spacing: JedaSpacing.lg) {
                TabView(selection: $selectedPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        JedaOnboardingPageView(page: page)
                            .padding(.horizontal, JedaSpacing.lg)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.snappy, value: selectedPage)
                .accessibilityElement(children: .contain)

            VStack(spacing: JedaSpacing.md) {
                JedaOnboardingIndicator(
                    pageCount: pages.count,
                    selectedPage: selectedPage
                )

                JedaButton(
                    selectedPage == pages.index(before: pages.endIndex) ? "Mulai" : "Lanjut",
                    kind: .primary
                ) {
                    goForward()
                }
                .frame(maxWidth: .infinity)
                .accessibilityLabel(
                    selectedPage == pages.index(before: pages.endIndex)
                    ? "Mulai menggunakan Jeda"
                    : "Lanjut ke halaman onboarding berikutnya"
                )
            }
            .padding(.horizontal, JedaSpacing.lg)
            .padding(.bottom, JedaSpacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func goForward() {
        if selectedPage == pages.index(before: pages.endIndex) {
            onFinish()
        } else {
            withAnimation(.snappy) {
                selectedPage += 1
            }
        }
    }
}

private struct JedaOnboardingPage: Identifiable {
    let id: String
    let symbolName: String
    let title: String
    let subtitle: String
    let tint: Color

    static let placeholderPages: [JedaOnboardingPage] = [
        .init(
            id: "check-in",
            symbolName: "leaf",
            title: "Ambil jeda sebentar",
            subtitle: "Mulai dengan check-in ringan untuk mencatat apa yang sedang kamu rasakan.",
            tint: JedaColor.sage
        ),
        .init(
            id: "reflection",
            symbolName: "sparkles",
            title: "Kenali emosi harian",
            subtitle: "Jeda membantu merapikan refleksi agar perasaanmu lebih mudah dipahami.",
            tint: JedaColor.clay
        ),
        .init(
            id: "patterns",
            symbolName: "chart.line.uptrend.xyaxis",
            title: "Lihat pola yang muncul",
            subtitle: "Pantau perubahan mood dan temukan ritme kecil yang mendukung hari-harimu.",
            tint: JedaColor.dustyBlue
        ),
    ]
}

private struct JedaOnboardingPageView: View {
    let page: JedaOnboardingPage

    var body: some View {
        VStack(spacing: JedaSpacing.xl) {
            Spacer(minLength: JedaSpacing.lg)

            ZStack {
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(page.tint.opacity(0.12))
                    .frame(width: 180, height: 180)
                    .overlay {
                        RoundedRectangle(cornerRadius: 36, style: .continuous)
                            .strokeBorder(page.tint.opacity(0.2), lineWidth: 1)
                    }

                Image(systemName: page.symbolName)
                    .font(.system(size: 80, weight: .semibold, design: .rounded))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(page.tint)
                    .accessibilityHidden(true)
            }
            .shadow(color: page.tint.opacity(0.1), radius: 20, x: 0, y: 10)

            VStack(spacing: JedaSpacing.md) {
                Text(page.title)
                    .font(JedaTypography.display)
                    .foregroundStyle(JedaColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(page.subtitle)
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 520)

            Spacer(minLength: JedaSpacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

private struct JedaOnboardingIndicator: View {
    let pageCount: Int
    let selectedPage: Int

    var body: some View {
        HStack(spacing: JedaSpacing.xs) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(index == selectedPage ? JedaColor.clay : JedaColor.separator)
                    .frame(width: index == selectedPage ? 24 : 8, height: 8)
            }
        }
        .frame(minHeight: 44)
        .accessibilityElement()
        .accessibilityLabel("Halaman \(selectedPage + 1) dari \(pageCount)")
    }
}

#Preview {
    JedaOnboardingView {}
}

#Preview("Large Dynamic Type") {
    JedaOnboardingView {}
        .dynamicTypeSize(.accessibility3)
}
