/**
 * Scope: ReflectionAIConsentSheet.swift
 * Purpose: One-time consent sheet shown before reflection text is sent to a cloud AI service.
 */

import SwiftUI

struct ReflectionAIConsentSheet: View {
    let onGrant: () -> Void
    let onDeny: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: JedaSpacing.lg) {
            Image(systemName: "cloud.fill")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(JedaColor.sage)
                .accessibilityHidden(true)

            Text("Kirim ke AI cloud?")
                .font(.system(.title2, design: .rounded, weight: .semibold))
                .foregroundStyle(JedaColor.textPrimary)

            Text("Refleksimu akan dikirim ke layanan AI di cloud untuk dianalisis dan dibalas. Teks ini tidak disimpan dengan namamu dan hanya digunakan untuk memberi balasan refleksi.")
                .font(JedaTypography.body)
                .foregroundStyle(JedaColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: JedaSpacing.md) {
                JedaButton("Setuju, kirim", kind: .primary) {
                    onGrant()
                }
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Setuju mengirim refleksi ke AI cloud")

                JedaButton("Tidak sekarang", kind: .secondary) {
                    onDeny()
                }
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Tidak mengirim refleksi ke AI cloud")
            }
            .padding(.top, JedaSpacing.sm)
        }
        .padding(JedaSpacing.lg)
        .presentationDetents([.medium])
    }
}

#Preview {
    ReflectionAIConsentSheet(onGrant: {}, onDeny: {})
}
