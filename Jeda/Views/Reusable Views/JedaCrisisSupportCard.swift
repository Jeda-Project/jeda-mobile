/**
 * Scope: JedaCrisisSupportCard.swift
 * Purpose: Crisis-support card that surfaces a professional mental-health hotline when deterministic crisis signals are detected.
 */

import SwiftUI

struct JedaCrisisSupportCard: View {
    var resource: CrisisSupportResource = .sejiwa

    @Environment(\.openURL)
    private var openURL

    var body: some View {
        JedaGlassSurface(tint: JedaColor.terracotta.opacity(0.14)) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                HStack(alignment: .top, spacing: JedaSpacing.md) {
                    Image(systemName: "lifepreserver")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(JedaColor.terracotta)
                        .frame(width: 42, height: 42)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                        Text(resource.title)
                            .font(JedaTypography.headline)
                            .foregroundStyle(JedaColor.textPrimary)

                        Text(resource.message)
                            .font(JedaTypography.body)
                            .foregroundStyle(JedaColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(resource.title). \(resource.message)")

                JedaButton(
                    "Hubungi \(resource.displayNumber)",
                    systemImage: "phone.fill",
                    kind: .warning
                ) {
                    if let url = URL(string: "tel://\(resource.dialNumber)") {
                        openURL(url)
                    }
                }
                .accessibilityHint("Membuka aplikasi telepon untuk menghubungi hotline kesehatan jiwa")
            }
        }
    }
}

#Preview {
    JedaCrisisSupportCard()
        .padding()
        .background { JedaScreenBackground() }
}
