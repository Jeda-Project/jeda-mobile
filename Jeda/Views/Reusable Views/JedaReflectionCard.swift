//
//  JedaReflectionCard.swift
//  Jeda
//
//  Created by Codex on 27/06/26.
//

import SwiftUI

struct JedaReflectionCard: View {
    let phrase: String
    let question: String
    let action: () -> Void

    var body: some View {
        JedaGlassSurface(tint: JedaColor.sage.opacity(0.16)) {
            VStack(alignment: .leading, spacing: JedaSpacing.lg) {
                HStack(alignment: .top, spacing: JedaSpacing.md) {
                    Image(systemName: "sparkle.magnifyingglass")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(JedaColor.sage)
                        .frame(width: 44, height: 44)
                        .jedaGlassEffect(
                            tint: JedaColor.sage.opacity(0.18),
                            in: Circle()
                        )

                    VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                        Text("Refleksi ringan")
                            .font(JedaTypography.caption)
                            .foregroundStyle(JedaColor.textSecondary)

                        Text("Aku menangkap kata \(phrase).")
                            .font(JedaTypography.headline)
                            .foregroundStyle(JedaColor.textPrimary)
                    }
                }

                Text(question)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundStyle(JedaColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                JedaButton("Cerita Lebih Dalam", systemImage: "sparkles", kind: .primary, action: action)
            }
        }
    }
}
