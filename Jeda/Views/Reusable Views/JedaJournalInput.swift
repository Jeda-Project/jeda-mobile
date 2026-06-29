/**
 * Scope: JedaJournalInput.swift
 * Purpose: Reusable text input component for journal and reflection entry screens.
 */

import SwiftUI

struct JedaJournalInput: View {
    let title: String
    let prompt: String
    @Binding var text: String

    var body: some View {
        JedaGlassSurface(tint: JedaColor.dustyBlue.opacity(0.12)) {
            VStack(alignment: .leading, spacing: JedaSpacing.md) {
                VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                    Text(title)
                        .font(JedaTypography.headline)
                        .foregroundStyle(JedaColor.textPrimary)

                    Text(prompt)
                        .font(JedaTypography.body)
                        .foregroundStyle(JedaColor.textSecondary)
                }

                TextEditor(text: $text)
                    .font(JedaTypography.body)
                    .foregroundStyle(JedaColor.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 132)
                    .padding(JedaSpacing.sm)
                    .background {
                        RoundedRectangle(cornerRadius: JedaRadius.control, style: .continuous)
                            .fill(JedaColor.background.opacity(0.55))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: JedaRadius.control, style: .continuous)
                            .stroke(JedaColor.separator, lineWidth: 1)
                    }
                    .accessibilityLabel(title)

                HStack {
                    Spacer()
                    Text("\(text.count) karakter")
                        .font(JedaTypography.caption)
                        .foregroundStyle(JedaColor.textSecondary)
                }
            }
        }
    }
}
