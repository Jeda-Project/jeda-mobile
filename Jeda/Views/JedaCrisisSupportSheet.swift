/**
 * Scope: JedaCrisisSupportSheet.swift
 * Purpose: Sheet shown when backend safety scan flags a crisis signal, listing professional support resources.
 */

import SwiftUI

struct JedaCrisisSupportSheet: View {
    let resources: [CrisisSupportResource]

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                    headerSection
                    resourceList
                }
                .padding(.horizontal, JedaSpacing.lg)
                .padding(.vertical, JedaSpacing.xl)
            }
            .background { JedaScreenBackground() }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tutup") { dismiss() }
                        .foregroundStyle(JedaColor.sage)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: JedaSpacing.sm) {
            Image(systemName: "heart.fill")
                .font(.title2)
                .foregroundStyle(JedaColor.sage)
                .accessibilityHidden(true)

            Text("Kamu tidak sendirian")
                .font(JedaTypography.title)
                .foregroundStyle(JedaColor.textPrimary)

            Text(
                "Kami dengar kamu sedang melalui masa yang berat. "
                    + "Ada orang-orang yang siap mendampingi — gratis dan rahasia."
            )
            .font(JedaTypography.body)
            .foregroundStyle(JedaColor.textSecondary)
        }
    }

    private var resourceList: some View {
        VStack(spacing: JedaSpacing.md) {
            ForEach(resources, id: \.title) { resource in
                ResourceCard(resource: resource)
            }
        }
    }
}

private struct ResourceCard: View {
    let resource: CrisisSupportResource

    var body: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.08)) {
            VStack(alignment: .leading, spacing: JedaSpacing.sm) {
                Text(resource.title)
                    .font(JedaTypography.headline)
                    .foregroundStyle(JedaColor.textPrimary)

                Text(resource.message)
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textSecondary)

                if !resource.displayNumber.isEmpty {
                    if let url = URL(string: "tel:\(resource.dialNumber)") {
                        Link(destination: url) {
                            HStack(spacing: JedaSpacing.xs) {
                                Image(systemName: "phone.fill")
                                    .accessibilityHidden(true)
                                Text(resource.displayNumber)
                            }
                            .font(JedaTypography.headline)
                            .foregroundStyle(JedaColor.sage)
                        }
                        .accessibilityLabel("Hubungi \(resource.title), nomor \(resource.displayNumber)")
                    }
                }
            }
        }
    }
}

#Preview {
    JedaCrisisSupportSheet(resources: [.sejiwa])
}
