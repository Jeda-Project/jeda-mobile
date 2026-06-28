//
//  JedaSafetyBanner.swift
//  Jeda
//
//  Created by Codex on 27/06/26.
//

import SwiftUI

struct JedaSafetyBanner: View {
    let action: () -> Void

    var body: some View {
        JedaGlassSurface(
            tint: JedaColor.terracotta.opacity(0.14),
            isInteractive: true
        ) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                HStack(alignment: .top, spacing: JedaSpacing.md) {
                    Image(systemName: "lifepreserver")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(JedaColor.terracotta)
                        .frame(width: 42, height: 42)

                    VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                        Text("Safety Guardrail")
                            .font(JedaTypography.headline)
                            .foregroundStyle(JedaColor.textPrimary)

                        Text("Jika ada sinyal krisis, Jeda langsung menampilkan resource bantuan profesional.")
                            .font(JedaTypography.body)
                            .foregroundStyle(JedaColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                JedaButton("Lihat bantuan", systemImage: "phone", kind: .warning, action: action)
            }
        }
    }
}
