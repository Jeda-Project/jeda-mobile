//
//  JedaGlassSurface.swift
//  Jeda
//
//  Created by Codex on 27/06/26.
//

import SwiftUI

struct JedaGlassSurface<Content: View>: View {
    let cornerRadius: CGFloat
    let tint: Color?
    let isInteractive: Bool
    let padding: CGFloat
    @ViewBuilder let content: Content

    init(
        cornerRadius: CGFloat = JedaRadius.card,
        tint: Color? = JedaColor.sage.opacity(0.10),
        isInteractive: Bool = false,
        padding: CGFloat = JedaSpacing.lg,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.isInteractive = isInteractive
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(JedaColor.elevatedBackground.opacity(0.16))
            }
            .glassEffect(effect, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var effect: Glass {
        let base = Glass.regular.tint(tint)
        return isInteractive ? base.interactive() : base
    }
}

struct JedaSection<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder let content: Content

    init(
        _ title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: JedaSpacing.md) {
            VStack(alignment: .leading, spacing: JedaSpacing.xs) {
                Text(title)
                    .font(JedaTypography.title)
                    .foregroundStyle(JedaColor.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(JedaTypography.body)
                        .foregroundStyle(JedaColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
