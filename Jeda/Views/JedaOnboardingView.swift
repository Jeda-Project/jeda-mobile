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

                Button {
                    goForward()
                } label: {
                    Text(selectedPage == pages.index(before: pages.endIndex) ? "Mulai" : "Lanjut")
                        .font(JedaTypography.headline)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(JedaColor.clay)
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
        .background {
            JedaScreenBackground()
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

            Image(systemName: page.symbolName)
                .font(.system(size: 96, weight: .semibold, design: .rounded))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(page.tint)
                .frame(width: 168, height: 168)
                .background {
                    Circle()
                        .fill(page.tint.opacity(0.14))
                }
                .accessibilityHidden(true)

            VStack(spacing: JedaSpacing.sm) {
                Text(page.title)
                    .font(JedaTypography.display)
                    .foregroundStyle(JedaColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(page.subtitle)
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
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
