/**
 * Scope: ReflectionAIConsentSheet.swift
 * Purpose: One-time consent sheet shown before reflection text is sent to a cloud AI service.
 */

import SwiftUI

struct ReflectionAIConsentSheet: View {
    let onGrant: () -> Void
    let onDeny: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(JedaColor.sage.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "icloud.and.arrow.up.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(JedaColor.sage)
                    .accessibilityHidden(true)
            }
            .padding(.top, 32)

            VStack(spacing: 12) {
                Text("Kirim ke AI cloud?")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(JedaColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text(
                    "Refleksimu akan dikirim ke layanan AI di cloud untuk dianalisis dan dibalas. "
                        + "Teks ini tidak disimpan dengan namamu dan hanya digunakan untuk memberi balasan refleksi."
                )
                .font(JedaTypography.body)
                .foregroundStyle(JedaColor.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 8)

            Spacer(minLength: 16)

            VStack(spacing: JedaSpacing.md) {
                JedaButton("Setuju, Kirim", kind: .primary) {
                    onGrant()
                }
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Setuju mengirim refleksi ke AI cloud")

                JedaButton("Tidak Sekarang", kind: .secondary) {
                    onDeny()
                }
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Tidak mengirim refleksi ke AI cloud")
            }
        }
        .padding(.horizontal, JedaSpacing.lg)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(32)
        .presentationBackground(JedaColor.background)
    }
}

#Preview {
    ReflectionAIConsentSheet(onGrant: {}, onDeny: {})
}
